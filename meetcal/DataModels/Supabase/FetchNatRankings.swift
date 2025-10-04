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
    
    func loadWeightClasses(age: String, gender: String) async {
        isLoading = true
        error = nil

        do {
            let response = try await supabase
                .from("lifting_results")
                .select()
                .execute()

            let rows = try JSONDecoder().decode([AthleteResults].self, from: response.data)

            self.rankings.removeAll()
            self.rankings.append(contentsOf: rows)
        } catch {
            print("Error: \(error)")
            self.error = error
        }
        isLoading = false
    }
}

