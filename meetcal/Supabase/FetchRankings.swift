//
//  FetchRankings.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/9/25.
//

import SwiftUI
import Supabase
import Combine

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
    
    func loadRankings(gender: String, ageCategory: String, meet: String) async {
        isLoading = true
        error = nil
        do {
            let response = try await supabase
                .from("intl_rankings")
                .select()
                .eq("gender", value: gender)
                .eq("age_category", value: ageCategory)
                .eq("meet", value: meet)
                .order("ranking")
                .execute()
            print(response)
            let decoder = JSONDecoder()
            let rankingsData = try decoder.decode([Rankings].self, from: response.data)
            self.rankings = rankingsData
            print(rankings)
        } catch {
            print("Error: \(error)")
            self.error = error
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
            print("Error: \(error)")
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
            print("Error: \(error)")
            self.error = error
        }
        isLoading = false
    }
}


