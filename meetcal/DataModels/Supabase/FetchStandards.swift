//
//  FetchStandards.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/7/25.
//

import SwiftUI
import Supabase
import Combine
import SwiftData

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

private struct AgeRow: Decodable {
    let age_category: String
}

@MainActor
class StandardsViewModel: ObservableObject {
    @Published var standards: [Standard] = []
    @Published var ageGroups: [String] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private var modelContext: ModelContext?
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    func saveStandardsToSwiftData() throws {
        guard let context = modelContext else {
            throw NSError(domain: "Standards", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContext not set"])
        }

        // Delete existing records first (to avoid duplicates)
        let fetchDescriptor = FetchDescriptor<StandardsEntity>()
        let existingRecords = try context.fetch(fetchDescriptor)
        for record in existingRecords {
            context.delete(record)
        }

        // Insert new records
        for standard in standards {
              let entity = StandardsEntity(
                  id: standard.id,
                  age_category: standard.age_category,
                  gender: standard.gender,
                  weight_class: standard.weight_class,
                  standard_a: standard.standard_a,
                  standard_b: standard.standard_b,
                  lastSynced: Date()
            )
            context.insert(entity)
        }

        try context.save()
    }

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
            
            self.standards.append(contentsOf: standardsData.sorted { (a: Standard, b: Standard) -> Bool in
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
    
    func loadAgeGroups(for gender: String) async {
        isLoading = true
        error = nil
        do {
            let response = try await supabase
                .from("standards")
                .select("age_category")
                .eq("gender", value: gender.lowercased())
                .execute()
            
            let rows = try JSONDecoder().decode([AgeRow].self, from: response.data)
            
            //create unique set of items from column
            let lower = rows.map{ $0.age_category.lowercased()}
            let unique = Array(Set(lower))
            
            //sorting function
            let order: [String] = ["u15", "youth", "junior", "senior"]
            let rank = Dictionary(uniqueKeysWithValues: order.enumerated().map{($1, $0)})
            let ordered = unique.sorted{
                let l = rank[$0] ?? Int.max
                let r = rank[$1] ?? Int.max
                
                if l != r { return l < r}
                
                return $0 < $1
            }
            
            self.ageGroups = ordered.map{
                let upper = $0.uppercased()
                if upper == "U13" || upper == "U15" || upper == "U17" {
                    return upper
                } else {
                    return $0.capitalized
                }
            }
        } catch {
            print("Error: \(error)")
            self.error = error
        }
        isLoading = false
    }
}
