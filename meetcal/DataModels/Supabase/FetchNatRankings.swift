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
    
    private var modelContext: ModelContext?
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
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

        do {
            let response = try await supabase
                .from("lifting_results")
                .select()
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
        } catch {
            print("Error: \(error)")
            self.error = error
        }
        isLoading = false
    }
}

