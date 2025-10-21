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
}
    
@MainActor
class ScheduleDetailsModel: ObservableObject {
    @Published var athletes: [AthleteRow] = []
    @Published var athleteResults: [AthleteResults] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private var modelContext: ModelContext?
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
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
        } catch {
            self.error = error
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
                .in("name", values: athleteNames)
                .execute()
            
            let rows = try JSONDecoder().decode([AthleteResults].self, from: response.data)
            self.athleteResults.append(contentsOf: rows)
        } catch {
            self.error = error
        }
        isLoading = false
    }
    
    func loadResults(name: String) async {
        isLoading = true
        error = nil
        do {
            let response = try await supabase
                .from("lifting_results")
                .select()
                .eq("name", value: name)
                .order("date", ascending: false)
                .execute()
            
            let rows = try JSONDecoder().decode([AthleteResults].self, from: response.data)
            
            self.athleteResults.removeAll { $0.name == name }
            self.athleteResults.append(contentsOf: rows)
        } catch {
            print("Error loading results for \(name): \(error)")
            self.error = error
        }
        isLoading = false
    }
}
