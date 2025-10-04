//
//  FetchNatRankings.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 10/4/25.
//

import Combine
import Supabase
import SwiftUI

@MainActor
class NationalRankingsModel: ObservableObject {
    @Published var error: Error?
    @Published var isLoading: Bool = false
    @Published var rankings: [AthleteResults] = []
    
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

            self.rankings.removeAll()
            self.rankings.append(contentsOf: maxTotalsByName)
        } catch {
            print("Error: \(error)")
            self.error = error
        }
        isLoading = false
    }
}

