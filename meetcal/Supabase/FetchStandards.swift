//
//  FetchStandards.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/7/25.
//

import SwiftUI
import Supabase
import Combine

struct Standard: Identifiable, Hashable, Decodable, Sendable {
    let id: Int
    let age_category: String
    let gender: String
    let weight_class: String
    let standard_a: Int
    let standard_b: Int
    
    var isPlusClass: Bool {
        weight_class.contains("+")
    }

    var numericWeight: Int {
        let digits = weight_class.unicodeScalars.filter { CharacterSet.decimalDigits.contains($0) }
        return Int(String(String.UnicodeScalarView(digits))) ?? 0
    }
}

@MainActor
class StandardsViewModel: ObservableObject {
    @Published var standards: [Standard] = []
    @Published var isLoading = false
    @Published var error: Error?

    func loadStandards(gender: String, ageCategory: String) async {
        isLoading = true
        error = nil
        do {
            let response = try await supabase
                .from("standards")
                .select()
                .eq("gender", value: gender.lowercased())
                .eq("age_category", value: ageCategory.lowercased())
                .execute()
            
            let decoder = JSONDecoder()
            let standardsData = try decoder.decode([Standard].self, from: response.data)
            self.standards = standardsData.sorted { (a: Standard, b: Standard) -> Bool in
                if a.isPlusClass != b.isPlusClass {
                    return a.isPlusClass == false
                }
                if a.numericWeight != b.numericWeight {
                    return a.numericWeight < b.numericWeight
                }
                return a.weight_class < b.weight_class
            }
            
        } catch {
            print("Error loading standards: \(error)")
            self.error = error
        }
        isLoading = false
    }
}
