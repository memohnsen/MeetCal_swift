//
//  FetchMeetsSchedule.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/12/25.
//

import SwiftUI
import Supabase
import Combine

private struct MeetsRow: Decodable {
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
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var schedule: [ScheduleRow] = []
    @Published var meetDetails: [MeetDetailsRow] = []
    
    private var loadMeetsTask: Task<Void, Never>?
    private var loadScheduleTask: Task<Void, Never>?
    private var loadDetailsTask: Task<Void, Never>?
    
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
                    self.meets = unique
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
                    self.schedule = row
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
                    self.meetDetails = row
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
