//
//  FetchWSORecords.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/7/25.
//

import SwiftUI
import Supabase
import Combine

struct WSORecords: Identifiable, Hashable, Decodable, Sendable {
    let id: Int
    let wso: String
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
class WSOViewModel: ObservableObject {
    @Published var wsoRecords: [WSORecords] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    func loadRecords(gender: String, ageCategory: String, wso: String) async {
        isLoading = true
        error = nil
        do {
            let response = try await supabase
                .from("wso_records")
                .select()
                .eq("gender", value: gender)
                .eq("age_category", value: ageCategory)
                .eq("wso", value: wso)
                .execute()
            
            print(response)
            
            let decoder = JSONDecoder()
            let wsoData = try decoder.decode([WSORecords].self, from: response.data)
            self.wsoRecords = wsoData.sorted { (a: WSORecords, b: WSORecords) -> Bool in
                if a.isPlusClass != b.isPlusClass {
                    return a.isPlusClass == false
                }
                if a.numericWeight != b.numericWeight {
                    return a.numericWeight < b.numericWeight
                }
                return a.weight_class < b.weight_class
            }
            
            print(wsoRecords)
        } catch {
            print("Error: \(error)")
            self.error = error
        }
        isLoading = false
    }
}
