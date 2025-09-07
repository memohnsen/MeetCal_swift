//
//  FetchAmericanRecords.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/7/25.
//

import SwiftUI
import Supabase
import Combine

struct Records: Identifiable, Hashable, Decodable, Sendable {
    let id: Int
    let record_type: String
    let gender: String
    let age_category: String
    let weight_class: String
    let snatch_record: Int
    let cj_record: Int
    let total_record: Int

    var isPlusClass: Bool {
        weight_class.contains("+")
    }

    var numericWeight: Int {
        let digits = weight_class.unicodeScalars.filter { CharacterSet.decimalDigits.contains($0) }
        return Int(String(String.UnicodeScalarView(digits))) ?? 0
    }
}

@MainActor
class RecordsViewModel: ObservableObject {
    @Published var records: [Records] = []
    @Published var isLoading = false
    @Published var error: Error?

    func loadRecords(gender: String, ageCategory: String, federation: String) async {
        isLoading = true
        error = nil
        do {
            let response = try await supabase
                .from("records")
                .select()
                .eq("gender", value: gender.lowercased())
                .eq("age_category", value: ageCategory.lowercased())
                .eq("record_type", value: federation)
                .execute()
            
            let decoder = JSONDecoder()
            let recordsData = try decoder.decode([Records].self, from: response.data)
            
            self.records = recordsData.sorted { (a: Records, b: Records) -> Bool in
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
