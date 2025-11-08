//
//  FetchWrapped.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 10/4/25.
//

import SwiftUI
import Combine
import Supabase

@MainActor
class WrappedModel: ObservableObject {
    @Published var error: Error?
    @Published var isLoading: Bool = false
    @Published var athleteResults: [AthleteResults] = []
    @Published var classRankings: [AthleteResults] = []
    
    var currentYearResults: [AthleteResults] {
        return athleteResults.filter { result in
            guard let date = dateFromString(result.date) else { return false }
            let calendar = Calendar.current
            let year = calendar.component(.year, from: date)
            return year == 2025
        }
    }
    
    var previousYearResults: [AthleteResults] {
        return athleteResults.filter { result in
            guard let date = dateFromString(result.date) else { return false }
            let calendar = Calendar.current
            let year = calendar.component(.year, from: date)
            return year == 2024
        }
    }
    
    private func dateFromString(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: dateString)
    }
    
    func loadResults(name: String) async {
        isLoading = true
        error = nil
        
        // Clear all previous data for new search
        self.athleteResults.removeAll()
        self.classRankings.removeAll()
        
        do {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let startOf2024 = "2024-01-01"
            
            let response = try await supabase
                .from("lifting_results")
                .select()
                .eq("federation", value: "USAW")
                .eq("name", value: name.capitalized)
                .gte("date", value: startOf2024)
                .execute()
            
            let rows = try JSONDecoder().decode([AthleteResults].self, from: response.data)
            
            self.athleteResults.append(contentsOf: rows)
        } catch {
            print("Error loading results for \(name): \(error)")
            self.error = error
        }
        isLoading = false
    }
    
    func loadWeightClassRankings(age: String) async {
        isLoading = true
        error = nil

        print("Loading rankings for weight class: \(age)")

        do {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let startOf2024 = "2024-01-01"

            let response = try await supabase
                .from("lifting_results")
                .select()
                .eq("federation", value: "USAW")
                .eq("age", value: age)
                .gte("date", value: startOf2024)
                .execute()

            let rows = try JSONDecoder().decode([AthleteResults].self, from: response.data)

            print("Loaded \(rows.count) rankings for \(age)")

            self.classRankings.removeAll()
            self.classRankings.append(contentsOf: rows)
        } catch {
            print("Error loading rankings: \(error)")
            self.error = error
        }
        isLoading = false
    }

    func calculateNationalRanking(for athleteName: String, in weightClass: String, year: Int) -> Int? {
        let classResults = classRankings.filter { result in
            guard result.age == weightClass else { return false }
            guard let date = dateFromString(result.date) else { return false }
            let resultYear = Calendar.current.component(.year, from: date)
            return resultYear == year
        }

        var athleteMaxTotals: [String: Float] = [:]

        for result in classResults {
            let currentMax = athleteMaxTotals[result.name] ?? 0
            if result.total > currentMax {
                athleteMaxTotals[result.name] = result.total
            }
        }

        let sortedAthletes = athleteMaxTotals.sorted { $0.value > $1.value }

        if let ranking = sortedAthletes.firstIndex(where: { $0.key.lowercased() == athleteName.lowercased() }) {
            return ranking + 1
        }

        return nil
    }
}
