//
//  FetchNatRankings.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 10/4/25.
//

import Combine
import Supabase
import SwiftUI
import SwiftData

@MainActor
class NationalRankingsModel: ObservableObject {
    @Published var error: Error?
    @Published var isLoading: Bool = false
    @Published var rankings: [AthleteResults] = []
    @Published var isUsingOfflineData = false

    private var modelContext: ModelContext?

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    private func hasOfflineRankings(age: String? = nil) -> Bool {
        guard let context = modelContext else { return false }

        var descriptor = FetchDescriptor<NatRankingsEntity>()

        if let age = age {
            descriptor.predicate = #Predicate<NatRankingsEntity> {
                $0.age == age
            }
        }

        descriptor.fetchLimit = 1
        let results = try? context.fetch(descriptor)
        return !(results?.isEmpty ?? true)
    }

    private func getOfflineLastSynced() -> Date? {
        guard let context = modelContext else { return nil }

        var descriptor = FetchDescriptor<NatRankingsEntity>()
        descriptor.fetchLimit = 1

        if let entities = try? context.fetch(descriptor),
           let firstEntity = entities.first {
            return firstEntity.lastSynced
        }
        return nil
    }

    private func loadRankingsFromSwiftData(age: String? = nil) throws -> [AthleteResults] {
        guard let context = modelContext else {
            throw NSError(domain: "National Rankings", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContext not set"])
        }

        var descriptor = FetchDescriptor<NatRankingsEntity>()

        if let age = age {
            descriptor.predicate = #Predicate<NatRankingsEntity> {
                $0.age == age
            }
        }

        let entities = try context.fetch(descriptor)

        let results = entities.map { entity in
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
                cj_best: entity.cj_best
            )
        }

        let maxTotalsByName = Dictionary(grouping: results) { $0.name }
            .compactMapValues { athleteResults in
                athleteResults.max { $0.total < $1.total }
            }
            .values
            .sorted { $0.total > $1.total }

        return Array(maxTotalsByName)
    }
    
    func saveNatRankingsToSwiftData() throws {
        guard let context = modelContext else {
            throw NSError(domain: "National Rankings", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContext not set"])
        }

        let fetchDescriptor = FetchDescriptor<NatRankingsEntity>()
        let existingRecords = try context.fetch(fetchDescriptor)
        for record in existingRecords {
            context.delete(record)
        }

        for ranking in rankings {
            let entity = NatRankingsEntity(
                id: ranking.id,
                meet : ranking.meet,
                date : ranking.date,
                name : ranking.name,
                age : ranking.age,
                body_weight : ranking.body_weight,
                total : ranking.total,
                snatch1 : ranking.snatch1,
                snatch2 : ranking.snatch2,
                snatch3 : ranking.snatch3,
                snatch_best : ranking.snatch_best,
                cj1 : ranking.cj1,
                cj2 : ranking.cj2,
                cj3 : ranking.cj3,
                cj_best: ranking.cj_best,
                lastSynced: Date()
            )
            context.insert(entity)
        }
        try context.save()
    }
    
    func loadWeightClasses(age: String) async {
        isLoading = true
        error = nil
        isUsingOfflineData = false

        let hasOffline = hasOfflineRankings(age: age)
        let lastSynced = getOfflineLastSynced()

        if OfflineManager.shared.shouldUseOfflineData(
            hasOfflineData: hasOffline,
            lastSynced: lastSynced
        ) {
            do {
                let offlineRankings = try loadRankingsFromSwiftData(age: age)
                self.rankings.append(contentsOf: offlineRankings)
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
                .eq("age", value: age)
                .order("total", ascending: false)
                .execute()

            let rows = try JSONDecoder().decode([AthleteResults].self, from: response.data)

            let maxTotalsByName = Dictionary(grouping: rows) { $0.name }
                .compactMapValues { athleteResults in
                    athleteResults.max { $0.total < $1.total }
                }
                .values
                .sorted { $0.total > $1.total }

            self.rankings.append(contentsOf: maxTotalsByName)
            self.isUsingOfflineData = false
        } catch {
            if hasOffline {
                do {
                    let offlineRankings = try loadRankingsFromSwiftData(age: age)
                    self.rankings.append(contentsOf: offlineRankings)
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

