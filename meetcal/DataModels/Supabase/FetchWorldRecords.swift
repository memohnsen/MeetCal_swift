//
//  FetchWorldRecords.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 11/7/25.
//

import Supabase
import Combine
import Foundation

struct WorldRecords: Identifiable, Hashable, Decodable, Sendable {
    let id: Int
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
class WorldRecordsModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var worldRecords: [WorldRecords] = []
    
    func loadRecords(gender: String, age_category: String) async {
        isLoading = true
        error = nil
        
        do {
            let response = try await supabase
                .from("world_records")
                .select()
                .eq("gender", value: gender)
                .eq("age_category", value: age_category)
                .execute()
            
            let rows = try JSONDecoder().decode([WorldRecords].self, from: response.data)
            
            self.worldRecords = rows.sorted { (a: WorldRecords, b: WorldRecords) -> Bool in
                if a.isPlusClass != b.isPlusClass {
                    return a.isPlusClass == false
                }
                if a.numericWeight != b.numericWeight {
                    return a.numericWeight < b.numericWeight
                }
                return a.weight_class < b.weight_class
            }
        } catch {
            print("Error: \(error)")
            self.error = error
        }
        isLoading = false
    }
}
