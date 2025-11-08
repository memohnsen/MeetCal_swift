//
//  FetchScheduleDetails.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/23/25.
//

import SwiftUI
import Supabase
import Combine
import SwiftData

struct AthleteResults: Decodable, Hashable {
    let id: Int
    let meet: String
    let date: String
    let name: String
    let age: String
    let body_weight: Float
    let total: Float
    let snatch1: Float
    let snatch2: Float
    let snatch3: Float
    let snatch_best: Float
    let cj1: Float
    let cj2: Float
    let cj3: Float
    let cj_best: Float
    let federation: String
}
    
@MainActor
class ScheduleDetailsModel: ObservableObject {
    @Published var athletes: [AthleteRow] = []
    @Published var athleteResults: [AthleteResults] = []
    @Published var allAthletes: [AthleteResults] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var isUsingOfflineData = false

    private var modelContext: ModelContext?

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    private func hasOfflineResults(name: String? = nil) -> Bool {
        guard let context = modelContext else { return false }

        var descriptor = FetchDescriptor<ResultsEntity>()

        if let name = name {
            descriptor.predicate = #Predicate<ResultsEntity> {
                $0.name == name
            }
        }

        descriptor.fetchLimit = 1
        let results = try? context.fetch(descriptor)
        return !(results?.isEmpty ?? true)
    }

    private func getOfflineLastSynced() -> Date? {
        guard let context = modelContext else { return nil }

        var descriptor = FetchDescriptor<ResultsEntity>()
        descriptor.fetchLimit = 1

        if let entities = try? context.fetch(descriptor),
           let firstEntity = entities.first {
            return firstEntity.lastSynced
        }
        return nil
    }

    private func loadResultsFromSwiftData(name: String) throws -> [AthleteResults] {
        guard let context = modelContext else {
            throw NSError(domain: "Results", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContext not set"])
        }

        let descriptor = FetchDescriptor<ResultsEntity>(
            predicate: #Predicate<ResultsEntity> {
                $0.name == name
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        let entities = try context.fetch(descriptor)

        return entities.map { entity in
            AthleteResults(
                id: entity.id,
                meet: entity.meet,
                date: entity.date,
                name: entity.name,
                age: entity.age,
                body_weight: entity.body_weight,
                total: entity.total,
                snatch1: entity.snatch1,
                snatch2: entity.snatch2,
                snatch3: entity.snatch3,
                snatch_best: entity.snatch_best,
                cj1: entity.cj1,
                cj2: entity.cj2,
                cj3: entity.cj3,
                cj_best: entity.cj_best,
                federation: entity.federation
            )
        }
    }

    private func hasOfflineSchedDetails(meet: String, sessionID: Int) -> Bool {
        guard let context = modelContext else { return false }

        var descriptor = FetchDescriptor<SchedDetailsEntity>(
            predicate: #Predicate<SchedDetailsEntity> {
                $0.meet == meet && $0.session_number == sessionID
            }
        )
        descriptor.fetchLimit = 1
        let results = try? context.fetch(descriptor)
        return !(results?.isEmpty ?? true)
    }

    private func getOfflineSchedDetailsLastSynced(meet: String) -> Date? {
        guard let context = modelContext else { return nil }

        let descriptor = FetchDescriptor<SchedDetailsEntity>(
            predicate: #Predicate<SchedDetailsEntity> {
                $0.meet == meet
            }
        )

        if let entities = try? context.fetch(descriptor),
           let firstEntity = entities.first {
            return firstEntity.lastSynced
        }
        return nil
    }

    private func loadAthletesFromSwiftData(meet: String, sessionID: Int, platform: String) throws -> [AthleteRow] {
        guard let context = modelContext else {
            throw NSError(domain: "Schedule Details", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContext not set"])
        }

        var descriptor: FetchDescriptor<SchedDetailsEntity>

        if platform == "ALL" {
            descriptor = FetchDescriptor<SchedDetailsEntity>(
                predicate: #Predicate<SchedDetailsEntity> {
                    $0.meet == meet && $0.session_number == sessionID
                },
                sortBy: [SortDescriptor(\.entry_total, order: .reverse)]
            )
        } else {
            descriptor = FetchDescriptor<SchedDetailsEntity>(
                predicate: #Predicate<SchedDetailsEntity> {
                    $0.meet == meet && $0.session_number == sessionID && $0.session_platform == platform
                },
                sortBy: [SortDescriptor(\.entry_total, order: .reverse)]
            )
        }

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

    func saveResultsToSwiftData() throws {
        guard let context = modelContext else {
            throw NSError(domain: "Results", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContext not set"])
        }

        let uniqueNames = Set(athleteResults.map { $0.name })

        for name in uniqueNames {
            let fetchDescriptor = FetchDescriptor<ResultsEntity>(
                predicate: #Predicate { $0.name == name }
            )
            let existingRecords = try context.fetch(fetchDescriptor)
            for record in existingRecords {
                context.delete(record)
            }
        }

        for result in athleteResults {
            let entity = ResultsEntity(
                id: result.id,
                meet: result.meet,
                date: result.date,
                name: result.name,
                age: result.age,
                body_weight: result.body_weight,
                total: result.total,
                snatch1: result.snatch1,
                snatch2: result.snatch2,
                snatch3: result.snatch3,
                snatch_best: result.snatch_best,
                cj1: result.cj1,
                cj2: result.cj2,
                cj3: result.cj3,
                cj_best: result.cj_best,
                federation: result.federation,
                lastSynced: Date()
            )
            context.insert(entity)
        }
        try context.save()
    }
    
    func saveSchedDetailsToSwiftData() throws {
        guard let context = modelContext else {
            throw NSError(domain: "Schedule Details", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContext not set"])
        }

        // Get the meet name from the data we're about to save
        guard let meetName = athletes.first?.meet else {
            return // Nothing to save
        }

        // Delete ONLY this meet's schedule details
        let fetchDescriptor = FetchDescriptor<SchedDetailsEntity>(
            predicate: #Predicate { $0.meet == meetName }
        )
        let existingRecords = try context.fetch(fetchDescriptor)
        for record in existingRecords {
            context.delete(record)
        }

        // Insert the new data for this meet
        for athlete in athletes {
            let entity = SchedDetailsEntity(
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

    func loadAthletes(meet: String, sessionID: Int, platform: String) async {
        isLoading = true
        error = nil
        isUsingOfflineData = false

        let hasOffline = hasOfflineSchedDetails(meet: meet, sessionID: sessionID)
        let lastSynced = getOfflineSchedDetailsLastSynced(meet: meet)

        if OfflineManager.shared.shouldUseOfflineData(
            hasOfflineData: hasOffline,
            lastSynced: lastSynced
        ) {
            do {
                let offlineAthletes = try loadAthletesFromSwiftData(meet: meet, sessionID: sessionID, platform: platform)
                self.athletes.append(contentsOf: offlineAthletes)
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
                .eq("session_number", value: sessionID)
                .eq("session_platform", value: platform)
                .order("entry_total", ascending: false)
                .execute()

            let rows = try JSONDecoder().decode([AthleteRow].self, from: response.data)
            self.athletes.append(contentsOf: rows)
            self.isUsingOfflineData = false
        } catch {
            if hasOffline {
                do {
                    let offlineAthletes = try loadAthletesFromSwiftData(meet: meet, sessionID: sessionID, platform: platform)
                    self.athletes.append(contentsOf: offlineAthletes)
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
    
    func loadAllResults() async {
        guard !athletes.isEmpty else { 
            return
        }
        
        isLoading = true
        error = nil
        do {
            let athleteNames = athletes.map { $0.name }
            let response = try await supabase
                .from("lifting_results")
                .select()
                .eq("federation", value: "USAW")
                .in("name", values: athleteNames)
                .execute()
            
            let rows = try JSONDecoder().decode([AthleteResults].self, from: response.data)
            self.athleteResults.append(contentsOf: rows)
        } catch {
            self.error = error
        }
        isLoading = false
    }
    
    func loadAllAthleteResults() async {
        isLoading = true
        error = nil
        athleteResults.removeAll()

        do {
            print("Starting to load all athlete results...")
            let response = try await supabase
                .from("lifting_results")
                .select()
                .eq("federation", value: "USAW")
                .order("name")
                .execute()

            let rows = try JSONDecoder().decode([AthleteResults].self, from: response.data)
            self.allAthletes = rows
            print("Successfully loaded \(rows.count) athlete results")
        } catch {
            self.error = error
            print("Error loading athlete results: \(error.localizedDescription)")
        }
        isLoading = false
    }

    func searchAthletesByName(query: String) async {
        isLoading = true
        error = nil
        athleteResults.removeAll()

        do {
            let response = try await supabase
                .from("lifting_results")
                .select("name")
                .eq("federation", value: "USAW")
                .ilike("name", pattern: "%\(query)%")
                .limit(30)
                .execute()

            struct NameOnly: Decodable {
                let name: String
            }

            let rows = try JSONDecoder().decode([NameOnly].self, from: response.data)

            // Convert to AthleteResults format with just the name field
            // This is a workaround to match the expected type
            let uniqueNames = Array(Set(rows.map { $0.name }))

            // We'll just store the names in a simple format
            // The actual results will be loaded when user clicks on a name
            self.athleteResults = uniqueNames.map { name in
                AthleteResults(
                    id: 0,
                    meet: "",
                    date: "",
                    name: name,
                    age: "",
                    body_weight: 0,
                    total: 0,
                    snatch1: 0,
                    snatch2: 0,
                    snatch3: 0,
                    snatch_best: 0,
                    cj1: 0,
                    cj2: 0,
                    cj3: 0,
                    cj_best: 0,
                    federation: "USAW"
                )
            }
        } catch {
            self.error = error
        }
        isLoading = false
    }

    func loadResults(name: String) async {
        isLoading = true
        error = nil
        isUsingOfflineData = false

        let hasOffline = hasOfflineResults(name: name)
        let lastSynced = getOfflineLastSynced()

        if OfflineManager.shared.shouldUseOfflineData(
            hasOfflineData: hasOffline,
            lastSynced: lastSynced
        ) {
            do {
                let offlineResults = try loadResultsFromSwiftData(name: name)
                self.athleteResults.removeAll { $0.name == name }
                self.athleteResults.append(contentsOf: offlineResults)
                self.isUsingOfflineData = true
            } catch {
                self.error = error
            }
            isLoading = false
            return
        }

        do {
            let response = try await supabase
                .from("lifting_results")
                .select()
                .eq("federation", value: "USAW")
                .eq("name", value: name)
                .order("date", ascending: false)
                .execute()

            let rows = try JSONDecoder().decode([AthleteResults].self, from: response.data)

            self.athleteResults.removeAll { $0.name == name }
            self.athleteResults.append(contentsOf: rows)
            self.isUsingOfflineData = false
        } catch {
            if hasOffline {
                do {
                    let offlineResults = try loadResultsFromSwiftData(name: name)
                    self.athleteResults.removeAll { $0.name == name }
                    self.athleteResults.append(contentsOf: offlineResults)
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
}
