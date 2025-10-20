//
//  FetchWSORecords.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/7/25.
//

import SwiftUI
import Supabase
import Combine
import SwiftData

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

private struct MeetRow: Decodable {
    let wso: String
}

private struct AgeRow: Decodable {
    let age_category: String
}

@MainActor
class WSOViewModel: ObservableObject {
    @Published var wsoRecords: [WSORecords] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var wso: [String] = []
    @Published var ageGroups: [String] = []
    
    private var modelContext: ModelContext?
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    func saveWSOToSwiftData() throws {
        guard let context = modelContext else {
            throw NSError(domain: "WSO Records", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContext not set"])
        }

        let fetchDescriptor = FetchDescriptor<WSOEntity>()
        let existingRecords = try context.fetch(fetchDescriptor)
        for record in existingRecords {
            context.delete(record)
        }

        for total in wsoRecords {
            let entity = WSOEntity(
                id: total.id,
                wso: total.wso,
                gender: total.gender,
                age_category: total.age_category,
                weight_class: total.weight_class,
                snatch_record: total.snatch_record,
                cj_record: total.cj_record,
                total_record: total.total_record,
                lastSynced: Date()
            )
            context.insert(entity)
        }
        try context.save()
    }
    
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
            self.wsoRecords.append(contentsOf: wsoData.sorted { (a: WSORecords, b: WSORecords) -> Bool in
                if a.isPlusClass != b.isPlusClass {
                    return a.isPlusClass == false
                }
                if a.numericWeight != b.numericWeight {
                    return a.numericWeight < b.numericWeight
                }
                return a.weight_class < b.weight_class
            })
        } catch {
            print("Error: \(error)")
            self.error = error
        }
        isLoading = false
    }
    
    func loadWSO() async {
        isLoading = true
        error = nil
        do {
            let response = try await supabase
                .from("wso_records")
                .select("wso")
                .execute()
            
            let row = try JSONDecoder().decode([MeetRow].self, from: response.data)
            let unique = Array(Set(row.map { $0.wso }))
            let sorted = unique.sorted()
            
            self.wso = sorted
        } catch {
            print("Error: \(error)")
            self.error = error
        }
        isLoading = false
    }
    
    func loadAgeGroups(gender: String, wso: String) async {
        isLoading = true
        error = nil
        do {
            let response = try await supabase
                .from("wso_records")
                .select("age_category")
                .eq("gender", value: gender)
                .eq("wso", value: wso)
                .execute()
            
            let row = try JSONDecoder().decode([AgeRow].self, from: response.data)
            let unique = Array(Set( row.map { $0.age_category }))
            
            let order: [String] = [
                "U11", "U13", "U15", "U17", "Youth", "Junior", "University", "Senior", "Masters", "Masters 30", "Masters 35", "Masters 40", "Masters 45", "Masters 50", "Masters 55", "Masters 60", "Masters 65", "Masters 70", "Masters 75", "Masters 80", "Masters 85", "Masters 35-39", "Masters 40-44", "Masters 45-49", "Masters 50-54", "Masters 55-59", "Masters 60-64", "Masters 65-69", "Masters 70-74", "Masters 75-79", "Masters 80-84", "Masters 85-89"
            ]
            let rank = Dictionary(uniqueKeysWithValues: order.enumerated().map { ($1, $0) })
            let ordered = unique.sorted {
                let l = rank[$0] ?? Int.max
                let r = rank[$1] ?? Int.max
                
                if l != r { return l < r }
                
                return $0 < $1
            }
            
            self.ageGroups = ordered
        } catch {
            print("error: \(error)")
            self.error = error
        }
        isLoading = false
    }
}
