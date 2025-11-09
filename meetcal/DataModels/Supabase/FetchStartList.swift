//
//  FetchStartList.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/16/25.
//

import SwiftUI
import Supabase
import Combine
import SwiftData

struct AthleteRow: Decodable, Hashable {
    let member_id: String
    let name: String
    let age: Int
    let club: String
    let gender: String
    let weight_class: String
    let entry_total: Int
    let session_number: Int?
    let session_platform: String?
    let meet: String
    let adaptive: Bool
}

@MainActor
class StartListModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var athletes: [AthleteRow] = []
    @Published var schedule: [ScheduleRow] = []
    @Published var athleteBests: [AthleteResults] = []
    @Published var weightClass: [String] = []
    @Published var ages: [Int] = []
    @Published var club: [String] = []
    @Published var adaptiveBool: [Bool] = []
    @Published var isUsingOfflineData = false

    private func updateFilterArrays(from rows: [AthleteRow]) {
        let agesSet = Set(rows.map { $0.age })
        self.ages = agesSet.sorted()

        let weightClassesSet = Set(rows.map { $0.weight_class })
        self.weightClass = weightClassesSet.sorted { (a: String, b: String) -> Bool in
            let aPlus = a.contains("+")
            let bPlus = b.contains("+")
            if aPlus != bPlus {
                return aPlus == false
            }
            let aDigits = a.unicodeScalars.filter { CharacterSet.decimalDigits.contains($0) }
            let bDigits = b.unicodeScalars.filter { CharacterSet.decimalDigits.contains($0) }
            let aNum = Int(String(String.UnicodeScalarView(aDigits))) ?? 0
            let bNum = Int(String(String.UnicodeScalarView(bDigits))) ?? 0
            if aNum != bNum {
                return aNum < bNum
            }
            return a < b
        }

        let clubsSet = Set(rows.map { $0.club })
        self.club = clubsSet.sorted()

        let adaptiveSet = Set(rows.map { $0.adaptive })
        self.adaptiveBool = adaptiveSet.sorted { (lhs, rhs) in
            if lhs == rhs { return false }
            return lhs == false && rhs == true
        }
    }

    private var modelContext: ModelContext?

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    private func hasOfflineStartList(meet: String) -> Bool {
        guard let context = modelContext else { return false }

        var descriptor = FetchDescriptor<StartListEntity>(
            predicate: #Predicate<StartListEntity> {
                $0.meet == meet
            }
        )
        descriptor.fetchLimit = 1
        let results = try? context.fetch(descriptor)
        return !(results?.isEmpty ?? true)
    }

    private func getOfflineStartListLastSynced(meet: String) -> Date? {
        guard let context = modelContext else { return nil }

        let descriptor = FetchDescriptor<StartListEntity>(
            predicate: #Predicate<StartListEntity> {
                $0.meet == meet
            }
        )

        if let entities = try? context.fetch(descriptor),
           let firstEntity = entities.first {
            return firstEntity.lastSynced
        }
        return nil
    }

    private func loadStartListFromSwiftData(meet: String) throws -> [AthleteRow] {
        guard let context = modelContext else {
            throw NSError(domain: "Start List", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContext not set"])
        }

        let descriptor = FetchDescriptor<StartListEntity>(
            predicate: #Predicate<StartListEntity> {
                $0.meet == meet
            },
            sortBy: [SortDescriptor(\.name, order: .forward)]
        )

        let entities = try context.fetch(descriptor)

        return entities.map { entity in
            AthleteRow(
                member_id: entity.member_id,
                name: entity.name,
                age: entity.age,
                club: entity.club,
                gender: entity.gender,
                weight_class: entity.weight_class,
                entry_total: entity.entry_total,
                session_number: entity.session_number,
                session_platform: entity.session_platform,
                meet: entity.meet,
                adaptive: entity.adaptive
            )
        }
    }
    
    func saveStartListToSwiftData() throws {
        guard let context = modelContext else {
            throw NSError(domain: "Start List", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContext not set"])
        }

        // Get the meet name from the data we're about to save
        guard let meetName = athletes.first?.meet else {
            return // Nothing to save
        }

        // Delete ONLY this meet's start list
        let fetchDescriptor = FetchDescriptor<StartListEntity>(
            predicate: #Predicate { $0.meet == meetName }
        )
        let existingRecords = try context.fetch(fetchDescriptor)
        for record in existingRecords {
            context.delete(record)
        }

        // Insert the new data for this meet
        for athlete in athletes {
            let entity = StartListEntity(
                member_id: athlete.member_id,
                name: athlete.name,
                age: athlete.age,
                club: athlete.club,
                gender: athlete.gender,
                weight_class: athlete.weight_class,
                entry_total: athlete.entry_total,
                session_number: athlete.session_number,
                session_platform: athlete.session_platform,
                meet: athlete.meet,
                adaptive: athlete.adaptive,
                lastSynced: Date()
            )
            context.insert(entity)
        }
        try context.save()
    }
    
    func loadStartList(meet: String) async {
        isLoading = true
        error = nil
        isUsingOfflineData = false

        let hasOffline = hasOfflineStartList(meet: meet)
        let lastSynced = getOfflineStartListLastSynced(meet: meet)

        if OfflineManager.shared.shouldUseOfflineData(
            hasOfflineData: hasOffline,
            lastSynced: lastSynced
        ) {
            do {
                let offlineStartList = try loadStartListFromSwiftData(meet: meet)
                self.athletes.append(contentsOf: offlineStartList)
                self.updateFilterArrays(from: self.athletes)
                self.isUsingOfflineData = true
            } catch {
                self.error = error
            }
            isLoading = false
            return
        }

        do {
            let response = try await supabase
                .from("athletes")
                .select()
                .eq("meet", value: meet)
                .order("name")
                .execute()

            let row = try JSONDecoder().decode([AthleteRow].self, from: response.data)

            self.athletes.append(contentsOf: row)
            self.updateFilterArrays(from: self.athletes)
            self.isUsingOfflineData = false
        } catch {
            if hasOffline {
                do {
                    let offlineStartList = try loadStartListFromSwiftData(meet: meet)
                    self.athletes.append(contentsOf: offlineStartList)
                    self.updateFilterArrays(from: self.athletes)
                    self.isUsingOfflineData = true
                } catch {
                    self.error = error
                }
            } else {
                self.error = OfflineManager.FetchError.noOfflineDataAvailable
            }
        }
        isLoading = false
    }
    
    func loadFilteredStartList(
        meet: String,
        ageRange: ClosedRange<Int>? = nil,
        gender: String? = nil,
        weight_class: String? = nil,
        club: String? = nil,
        adaptive: Bool? = nil
    ) async {
        isLoading = true
        error = nil

        do {
            var query = supabase
                .from("athletes")
                .select()
                .eq("meet", value: meet)

            if let range = ageRange {
                query = query
                    .gte("age", value: range.lowerBound)
                    .lte("age", value: range.upperBound)
            }
            if let gender = gender {
                query = query.eq("gender", value: gender)
            }
            if let weight_class = weight_class {
                query = query.eq("weight_class", value: weight_class)
            }
            if let club = club {
                query = query.eq("club", value: club)
            }
            if let adaptive = adaptive {
                query = query.eq("adaptive", value: adaptive)
            }

            let response = try await query
                .order("name")
                .execute()

            let row = try JSONDecoder().decode([AthleteRow].self, from: response.data)

            self.athletes.append(contentsOf: row)
        } catch {
            print("Error: \(error)")
            self.error = error
        }
        isLoading = false
    }
    
    func loadMeetSchedule(meet: String) async {
        isLoading = true
        error = nil
        do {
            let response = try await supabase
                .from("session_schedule")
                .select()
                .eq("meet", value: meet)
                .order("session_id", ascending: true)
                .execute()
            
            let decoder = JSONDecoder.scheduleNoonDateDecoder()

            let row = try decoder.decode([ScheduleRow].self, from: response.data)
            self.schedule.append(contentsOf: row)
            
        } catch {
            print("Error: \(error)")
            self.error = error
        }
        isLoading = false
    }

    struct WeightOnlyRow: Decodable {
        let weight_class: String
    }

    func loadWeightClasses(
        meet: String,
        ageRange: ClosedRange<Int>? = nil,
        gender: String? = nil
    ) async {
        error = nil
        do {
            var query = supabase
                .from("athletes")
                .select("weight_class")
                .eq("meet", value: meet)

            if let range = ageRange {
                query = query
                    .gte("age", value: range.lowerBound)
                    .lte("age", value: range.upperBound)
            }
            if let gender = gender, !gender.isEmpty {
                query = query.eq("gender", value: gender)
            }

            let response = try await query.execute()
            let rows = try JSONDecoder().decode([WeightOnlyRow].self, from: response.data)
            let weightsSet = Set(rows.map { $0.weight_class })

            self.weightClass = weightsSet.sorted { (a: String, b: String) -> Bool in
                let aPlus = a.contains("+")
                let bPlus = b.contains("+")
                if aPlus != bPlus {
                    return aPlus == false
                }
                let aDigits = a.unicodeScalars.filter { CharacterSet.decimalDigits.contains($0) }
                let bDigits = b.unicodeScalars.filter { CharacterSet.decimalDigits.contains($0) }
                let aNum = Int(String(String.UnicodeScalarView(aDigits))) ?? 0
                let bNum = Int(String(String.UnicodeScalarView(bDigits))) ?? 0
                if aNum != bNum {
                    return aNum < bNum
                }
                return a < b
            }
        } catch {
            print("Error: \(error)")
            self.error = error
        }
    }
    
    func loadBestLifts(name: String) async {
        isLoading = true
        error = nil
        do {
            let oneYearAgo = Date().addingTimeInterval(-365 * 24 * 60 * 60)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let oneYearAgoString = dateFormatter.string(from: oneYearAgo)
            
            let response = try await supabase
                .from("lifting_results")
                .select()
                .neq("federation", value: "BWL")
                .eq("name", value: name)
                .gte("date", value: oneYearAgoString)
                .execute()
            
            let rows = try JSONDecoder().decode([AthleteResults].self, from: response.data)
            
            self.athleteBests.removeAll { $0.name == name }
            self.athleteBests.append(contentsOf: rows)
        } catch {
            print("Error loading results for \(name): \(error)")
            self.error = error
        }
        isLoading = false
    }
}

