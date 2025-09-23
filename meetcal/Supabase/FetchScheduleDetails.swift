//
//  FetchScheduleDetails.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/23/25.
//

import SwiftUI
import Supabase
import Combine

struct AthleteResults: Decodable {
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
}
    
@MainActor
class ScheduleDetailsModel: ObservableObject {
    @Published var athletes: [AthleteRow] = []
    @Published var athleteResults: [AthleteResults] = []
    @Published var isLoading = false
    @Published var error: Error?

    func loadAthletes(meet: String, sessionID: Int, platform: String) async {
        do {
            isLoading = true
            error = nil

            let response = try await supabase
                .from("athletes")
                .select()
                .eq("meet", value: meet)
                .eq("session_number", value: sessionID)
                .eq("session_platform", value: platform)
                .order("name")
                .execute()

            let rows = try JSONDecoder().decode([AthleteRow].self, from: response.data)
            self.athletes = rows
        } catch {
            self.error = error
        }
        isLoading = false
    }
    
    func loadResults(name: String) async {
        isLoading = false
        error = nil
        do {
            let response = try await supabase
                .from("lifting_results")
                .select()
                .eq("name", value: name)
                .execute()
            
            let rows = try JSONDecoder().decode([AthleteResults].self, from: response.data)
            
            self.athleteResults = rows
        } catch {
            print("Error: \(error)")
            self.error = error
        }
        isLoading = false
    }
}
