//
//  FetchRankings.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/9/25.
//

import SwiftUI
import Supabase
import Combine
import SwiftData

struct Rankings: Identifiable, Hashable, Decodable, Sendable {
    let id: Int
    let meet: String
    let name: String
    let weight_class: String
    let total: Int
    let percent_a: Float
    let gender: String
    let age_category: String
}

private struct MeetRow: Decodable {
    let meet: String
}

private struct AgeRow: Decodable {
    let age_category: String
}

@MainActor
class IntlRankingsViewModel: ObservableObject {
    @Published var rankings: [Rankings] = []
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var meets: [String] = []
    @Published var ageGroups: [String] = []
    @Published var isUsingOfflineData = false

    private var modelContext: ModelContext?

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    private func hasOfflineRankings(gender: String? = nil, ageCategory: String? = nil, meet: String? = nil) -> Bool {
        guard let context = modelContext else { return false }

        var descriptor = FetchDescriptor<RankingsEntity>()

        if let gender = gender, let ageCategory = ageCategory, let meet = meet {
            descriptor.predicate = #Predicate<RankingsEntity> {
                $0.gender == gender &&
                $0.age_category == ageCategory &&
                $0.meet == meet
            }
        }

        descriptor.fetchLimit = 1
        let results = try? context.fetch(descriptor)
        return !(results?.isEmpty ?? true)
    }

    private func getOfflineLastSynced() -> Date? {
        guard let context = modelContext else { return nil }

        var descriptor = FetchDescriptor<RankingsEntity>()
        descriptor.fetchLimit = 1

        if let entities = try? context.fetch(descriptor),
           let firstEntity = entities.first {
            return firstEntity.lastSynced
        }
        return nil
    }

    private func loadRankingsFromSwiftData(gender: String? = nil, ageCategory: String? = nil, meet: String? = nil) throws -> [Rankings] {
        guard let context = modelContext else {
            throw NSError(domain: "International Rankings", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContext not set"])
        }

        var descriptor = FetchDescriptor<RankingsEntity>()

        if let gender = gender, let ageCategory = ageCategory, let meet = meet {
            descriptor.predicate = #Predicate<RankingsEntity> {
                $0.gender == gender &&
                $0.age_category == ageCategory &&
                $0.meet == meet
            }
        }

        let entities = try context.fetch(descriptor)

        return entities.map { entity in
            Rankings(
                id: entity.id,
                meet: entity.meet,
                name: entity.name,
                weight_class: entity.weight_class,
                total: entity.total,
                percent_a: entity.percent_a,
                gender: entity.gender,
                age_category: entity.age_category
            )
        }
    }
    
    func saveIntlRankingsToSwiftData() throws {
        guard let context = modelContext else {
            throw NSError(domain: "International Rankings", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContext not set"])
        }

        let fetchDescriptor = FetchDescriptor<RankingsEntity>()
        let existingRecords = try context.fetch(fetchDescriptor)
        for record in existingRecords {
            context.delete(record)
        }

        for ranking in rankings {
            let entity = RankingsEntity(
                id: ranking.id,
                meet: ranking.meet,
                name: ranking.name,
                weight_class: ranking.weight_class,
                total: ranking.total,
                percent_a: ranking.percent_a,
                gender: ranking.gender,
                age_category: ranking.age_category,
                lastSynced: Date()
            )
            context.insert(entity)
        }
        try context.save()
    }
    
    func loadRankings(gender: String, ageCategory: String, meet: String) async {
        isLoading = true
        error = nil
        isUsingOfflineData = false

        let hasOffline = hasOfflineRankings(gender: gender, ageCategory: ageCategory, meet: meet)
        let lastSynced = getOfflineLastSynced()

        if OfflineManager.shared.shouldUseOfflineData(
            hasOfflineData: hasOffline,
            lastSynced: lastSynced
        ) {
            do {
                let offlineRankings = try loadRankingsFromSwiftData(
                    gender: gender,
                    ageCategory: ageCategory,
                    meet: meet
                )
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
                .from("intl_rankings")
                .select()
                .eq("gender", value: gender)
                .eq("age_category", value: ageCategory)
                .eq("meet", value: meet)
                .order("ranking")
                .execute()

            let decoder = JSONDecoder()
            let rankingsData = try decoder.decode([Rankings].self, from: response.data)
            self.rankings.append(contentsOf: rankingsData)
            self.isUsingOfflineData = false
        } catch {
            if hasOffline {
                do {
                    let offlineRankings = try loadRankingsFromSwiftData(
                        gender: gender,
                        ageCategory: ageCategory,
                        meet: meet
                    )
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
    
    func loadMeet(gender: String, ageCategory: String) async {
        isLoading = true
        error = nil
        do {
            let response = try await supabase
                .from("intl_rankings")
                .select("meet")
                .execute()

            let rows = try JSONDecoder().decode([MeetRow].self, from: response.data)
            let unique = Array(Set(rows.map {$0.meet}))

            self.meets = unique
        } catch {
            self.error = error
        }
        isLoading = false
    }

    func loadAgeGroups(meet: String, gender: String) async {
        isLoading = true
        error = nil
        do {
            let response = try await supabase
                .from("intl_rankings")
                .select("age_category")
                .eq("meet", value: meet)
                .eq("gender", value: gender)
                .execute()

            let row = try JSONDecoder().decode([AgeRow].self, from: response.data)
            let unique = Array(Set(row.map {$0.age_category}))

            let order: [String] = ["U15", "U17", "Junior", "Senior"]
            let rank = Dictionary(uniqueKeysWithValues: order.enumerated().map { ($1, $0) })
            let ordered = unique.sorted {
                let l = rank[$0.lowercased()] ?? Int.max
                let r = rank[$1.lowercased()] ?? Int.max

                if l != r { return l < r }

                return $0 < $1
            }

            self.ageGroups = ordered
        } catch {
            self.error = error
        }
        isLoading = false
    }
}


