//
//  FetchAmericanRecords.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/7/25.
//

import SwiftUI
import Supabase
import Combine
import SwiftData

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

private struct AgeRow: Decodable {
    let age_category: String
}

@MainActor
class RecordsViewModel: ObservableObject {
    @Published var records: [Records] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var ageGroups: [String] = []
    
    private var modelContext: ModelContext?
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    func saveAmRecordsToSwiftData() throws {
        guard let context = modelContext else {
            throw NSError(domain: "American Records", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContext not set"])
        }

        let fetchDescriptor = FetchDescriptor<AmericanRecordEntity>()
        let existingRecords = try context.fetch(fetchDescriptor)
        for record in existingRecords {
            context.delete(record)
        }

        for record in records {
            let entity = AmericanRecordEntity(
                id: record.id,
                record_type: record.record_type,
                gender: record.gender,
                age_category: record.age_category,
                weight_class: record.weight_class,
                snatch_record: record.snatch_record,
                cj_record: record.cj_record,
                total_record: record.total_record,
                lastSynced: Date()
            )
            context.insert(entity)
        }
        try context.save()
    }

    func loadRecords(gender: String, ageCategory: String, record_type: String) async {
        isLoading = true
        error = nil
        do {
            let response = try await supabase
                .from("records")
                .select()
                .eq("gender", value: gender.lowercased())
                .ilike("age_category", pattern: ageCategory.lowercased())
                .eq("record_type", value: record_type)
                .execute()
            
            let decoder = JSONDecoder()
            let recordsData = try decoder.decode([Records].self, from: response.data)
            
            self.records.append(contentsOf: recordsData.sorted { (a: Records, b: Records) -> Bool in
                if a.isPlusClass != b.isPlusClass {
                    return a.isPlusClass == false
                }
                if a.numericWeight != b.numericWeight {
                    return a.numericWeight < b.numericWeight
                }
                return a.weight_class < b.weight_class
            })
        } catch {
            print("Error loading standards: \(error)")
            self.error = error
        }
        isLoading = false
    }
    
    func loadAgeGroup(for gender: String, record_type: String) async {
        isLoading = true
        error = nil
        do {
            let response = try await supabase
                .from("records")
                .select("age_category")
                .eq("gender", value: gender.lowercased())
                .eq("record_type", value: record_type)
                .execute()
            
            let rows = try JSONDecoder().decode([AgeRow].self, from: response.data)
            let unique = Array(Set(rows.map { $0.age_category }))
            
            // sorting
            let order: [String] = [
                "u13", "u15", "u17", "junior", "university", "senior",
                "masters 30", "masters 35", "masters 40", "masters 45", "masters 50",
                "masters 55", "masters 60", "masters 65", "masters 70", "masters 75",
                "masters 80", "masters 85",
                "masters 35-39", "masters 40-44", "masters 45-49", "masters 50-54",
                "masters 55-59", "masters 60-64", "masters 65-69", "masters 70-74",
                "masters 75-79", "masters 80-84", "masters 85-89", "masters +90"
            ]
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
