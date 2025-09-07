//
//  FetchQualifyingTotals.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/7/25.
//

import SwiftUI
import Supabase
import Combine

struct QualifyingTotal: Hashable, Decodable, Identifiable, Sendable {
    let id: Int
    let event_name: String
    let gender: String
    let age_category: String
    let weight_class: String
    let qualifying_total: Int
    
    var isPlusClass: Bool {
        weight_class.contains("+")
    }

    var numericWeight: Int {
        let digits = weight_class.unicodeScalars.filter { CharacterSet.decimalDigits.contains($0) }
        return Int(String(String.UnicodeScalarView(digits))) ?? 0
    }
}

@MainActor
class QualifyingTotalModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var totals: [QualifyingTotal] = []
    
    func loadTotals(gender: String, age_category: String, event_name: String) async {
        isLoading = true
        error = nil
        do {
            let response = try await supabase
                .from("qualifying_totals")
                .select()
                .eq("gender", value: gender)
                .eq("age_category", value: age_category)
                .eq("event_name", value: event_name)
                .execute()
            
            print(response)
            let decoder = JSONDecoder()
            let totalData = try decoder.decode([QualifyingTotal].self, from: response.data)
            self.totals = totalData.sorted { (a: QualifyingTotal, b: QualifyingTotal) -> Bool in
                if a.isPlusClass != b.isPlusClass {
                    return a.isPlusClass == false
                }
                if a.numericWeight != b.numericWeight {
                    return a.numericWeight < b.numericWeight
                }
                return a.weight_class < b.weight_class
            }
            print(totals)
        } catch {
            print("Error \(error)")
            self.error = error
        }
        isLoading = false
    }
}
