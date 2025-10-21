//
//  FetchMeetsSchedule.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/12/25.
//

import SwiftUI
import Supabase
import Combine
import SwiftData

struct MeetsRow: Decodable, Hashable {
    let name: String
}

struct ScheduleRow: Decodable {
    let id: Int
    let date: Date
    let session_id: Int
    let weight_class: String
    let start_time: String
    let platform: String
    let meet: String?
}

struct MeetDetailsRow: Decodable {
    let name: String
    let venue_name: String
    let venue_street: String
    let venue_city: String
    let venue_state: String
    let venue_zip: String
    let time_zone: String
    let start_date: String
    let end_date: String
}

@MainActor
class MeetsScheduleModel: ObservableObject {
    @Published var meets: [String] = []
    @Published var threeWeeksMeets: [MeetsRow] = []
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var schedule: [ScheduleRow] = []
    @Published var meetDetails: [MeetDetailsRow] = []
    
    private var loadMeetsTask: Task<Void, Never>?
    private var loadScheduleTask: Task<Void, Never>?
    private var loadDetailsTask: Task<Void, Never>?
    
    private var modelContext: ModelContext?
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    func saveMeetsToSwiftData() throws {
        guard let context = modelContext else {
            throw NSError(domain: "Meets", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContext not set"])
        }

        let fetchDescriptor = FetchDescriptor<MeetsEntity>()
        let existingRecords = try context.fetch(fetchDescriptor)
        for record in existingRecords {
            context.delete(record)
        }

        for meet in meets {
            let entity = MeetsEntity(
                name: meet,
                lastSynced: Date()
            )
            context.insert(entity)
        }
        try context.save()
    }
    
    func loadMeets() async {
        loadMeetsTask?.cancel()
        
        loadMeetsTask = Task {
            isLoading = true
            error = nil
            do {
                let response = try await supabase
                    .from("meets")
                    .select("name")
                    .neq("status", value: "completed")
                    .order("start_date", ascending: true)
                    .execute()
                
                try Task.checkCancellation()
                
                let row = try JSONDecoder().decode([MeetsRow].self, from: response.data)
                let unique = Array(row.map { $0.name })

                if !Task.isCancelled {
                    self.meets.append(contentsOf: unique)
                }
            } catch is CancellationError {
                return
            } catch {
                if !Task.isCancelled {
                    print("error: \(error)")
                    self.error = error
                }
            }
            
            if !Task.isCancelled {
                isLoading = false
            }
        }
        
        await loadMeetsTask?.value
    }
    
    func loadMeets3Weeks() async {
        isLoading = true
        error = nil
        do {
            let now = Date()
            let threeWeeks = now.addingTimeInterval(21 * 24 * 60 * 60)

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let todayString = dateFormatter.string(from: now)
            let threeWeeksString = dateFormatter.string(from: threeWeeks)

            let response = try await supabase
                .from("meets")
                .select("name")
                .neq("status", value: "completed")
                .gte("start_date", value: todayString)
                .lte("start_date", value: threeWeeksString)
                .order("start_date", ascending: true)
                .execute()
                            
            let row = try JSONDecoder().decode([MeetsRow].self, from: response.data)
            
            threeWeeksMeets = row
        } catch{
            print("error: \(error)")
            self.error = error
        }
        isLoading = false
    }
    
    func saveScheduleToSwiftData() throws {
        guard let context = modelContext else {
            throw NSError(domain: "Schedule", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContext not set"])
        }

        // Get the meet name from the data we're about to save
        guard let meetName = schedule.first?.meet else {
            return // Nothing to save
        }

        // Delete ONLY records for THIS specific meet
        let fetchDescriptor = FetchDescriptor<ScheduleEntity>(
            predicate: #Predicate { $0.meet == meetName }
        )
        let existingRecords = try context.fetch(fetchDescriptor)
        for record in existingRecords {
            context.delete(record)
        }

        // Insert the new data for this meet
        for meet in schedule {
            let entity = ScheduleEntity(
                id: meet.id,
                date: meet.date,
                session_id: meet.session_id,
                weight_class: meet.weight_class,
                start_time: meet.start_time,
                platform: meet.platform,
                meet: meet.meet,
                lastSynced: Date()
            )
            context.insert(entity)
        }
        try context.save()
    }
    
    func loadMeetSchedule(meet: String) async {
        loadScheduleTask?.cancel()
        
        loadScheduleTask = Task {
            isLoading = true
            error = nil
            do {
                let response = try await supabase
                    .from("session_schedule")
                    .select()
                    .eq("meet", value: meet)
                    .order("session_id", ascending: true)
                    .execute()
                
                try Task.checkCancellation()
                
                let decoder = JSONDecoder.scheduleNoonDateDecoder()
                
                let row = try decoder.decode([ScheduleRow].self, from: response.data)

                if !Task.isCancelled {
                    self.schedule.append(contentsOf: row)
                }
                
            } catch is CancellationError {
                return
            } catch {
                if !Task.isCancelled {
                    print("Error: \(error)")
                    self.error = error
                }
            }
            
            if !Task.isCancelled {
                isLoading = false
            }
        }
        
        await loadScheduleTask?.value
    }
    
    func saveMeetDetailsToSwiftData() throws {
        guard let context = modelContext else {
            throw NSError(domain: "Meets Details", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContext not set"])
        }

        // Get the meet name from the data we're about to save
        guard let meetName = meetDetails.first?.name else {
            return // Nothing to save
        }

        // Delete ONLY this specific meet's details
        let fetchDescriptor = FetchDescriptor<MeetDetailsEntity>(
            predicate: #Predicate { $0.name == meetName }
        )
        let existingRecords = try context.fetch(fetchDescriptor)
        for record in existingRecords {
            context.delete(record)
        }

        // Insert the new data for this meet
        for meet in meetDetails {
            let entity = MeetDetailsEntity(
                name: meet.name,
                venue_name: meet.venue_name,
                venue_street: meet.venue_street,
                venue_city: meet.venue_city,
                venue_state: meet.venue_state,
                venue_zip: meet.venue_zip,
                time_zone: meet.time_zone,
                start_date: meet.start_date,
                end_date: meet.end_date,
                lastSynced: Date()
            )
            context.insert(entity)
        }
        try context.save()
    }
    
    func loadMeetDetails(meetName: String) async {
        loadDetailsTask?.cancel()
        
        loadDetailsTask = Task {
            error = nil
            isLoading = true
            do {
                let response = try await supabase
                    .from("meets")
                    .select()
                    .eq("name", value: meetName)
                    .execute()
                
                try Task.checkCancellation()
                
                let row = try JSONDecoder().decode([MeetDetailsRow].self, from: response.data)

                if !Task.isCancelled {
                    self.meetDetails.append(contentsOf: row)
                }
            } catch is CancellationError {
                return
            } catch {
                if !Task.isCancelled {
                    print("Error: \(error)")
                    self.error = error
                }
            }
            
            if !Task.isCancelled {
                isLoading = false
            }
        }
        await loadDetailsTask?.value
    }
}

