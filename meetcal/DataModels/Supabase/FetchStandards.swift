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
    @Published var isUsingOfflineData = false

    private var modelContext: ModelContext?

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    private func hasOfflineStandards(gender: String? = nil, ageCategory: String? = nil) -> Bool {
        guard let context = modelContext else { return false }

        var descriptor = FetchDescriptor<StandardsEntity>()

        if let gender = gender, let ageCategory = ageCategory {
            let genderLower = gender.lowercased()
            let ageLower = ageCategory.lowercased()
            descriptor.predicate = #Predicate<StandardsEntity> {
                $0.gender == genderLower &&
                $0.age_category == ageLower
            }
        }

        descriptor.fetchLimit = 1
        let results = try? context.fetch(descriptor)
        return !(results?.isEmpty ?? true)
    }

    private func getOfflineLastSynced() -> Date? {
        guard let context = modelContext else { return nil }

        var descriptor = FetchDescriptor<StandardsEntity>()
        descriptor.fetchLimit = 1

        if let entities = try? context.fetch(descriptor),
           let firstEntity = entities.first {
            return firstEntity.lastSynced
        }
        return nil
    }

    private func loadStandardsFromSwiftData(gender: String? = nil, ageCategory: String? = nil) throws -> [Standard] {
        guard let context = modelContext else {
            throw NSError(domain: "Standards", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContext not set"])
        }

        var descriptor = FetchDescriptor<StandardsEntity>()

        if let gender = gender, let ageCategory = ageCategory {
            let genderLower = gender.lowercased()
            let ageLower = ageCategory.lowercased()
            descriptor.predicate = #Predicate<StandardsEntity> {
                $0.gender == genderLower &&
                $0.age_category == ageLower
            }
        }

        let entities = try context.fetch(descriptor)

        return entities.map { entity in
            Standard(
                id: entity.id,
                age_category: entity.age_category,
                gender: entity.gender,
                weight_class: entity.weight_class,
                standard_a: entity.standard_a,
                standard_b: entity.standard_b
            )
        }.sorted { (a: Standard, b: Standard) -> Bool in
            if a.isPlusClass != b.isPlusClass {
                return a.isPlusClass == false
            }
            if a.numericWeight != b.numericWeight {
                return a.numericWeight < b.numericWeight
            }
            return a.weight_class < b.weight_class
        }
    }
    
    func saveStandardsToSwiftData() throws {
        guard let context = modelContext else {
            throw NSError(domain: "Standards", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContext not set"])
        }

        let fetchDescriptor = FetchDescriptor<StandardsEntity>()
        let existingRecords = try context.fetch(fetchDescriptor)
        for record in existingRecords {
            context.delete(record)
        }

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
        isUsingOfflineData = false

        let hasOffline = hasOfflineStandards(gender: gender, ageCategory: ageCategory)
        let lastSynced = getOfflineLastSynced()

        if OfflineManager.shared.shouldUseOfflineData(
            hasOfflineData: hasOffline,
            lastSynced: lastSynced
        ) {
            do {
                let offlineStandards = try loadStandardsFromSwiftData(
                    gender: gender,
                    ageCategory: ageCategory
                )
                self.standards.append(contentsOf: offlineStandards)
                self.isUsingOfflineData = true
            } catch {
                self.error = error
            }
            isLoading = false
            return
        }

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

            self.isUsingOfflineData = false
        } catch {
            if hasOffline {
                do {
                    let offlineStandards = try loadStandardsFromSwiftData(
                        gender: gender,
                        ageCategory: ageCategory
                    )
                    self.standards.append(contentsOf: offlineStandards)
                    self.isUsingOfflineData = true
                } catch {
                    self.error = error
                }
            } else {
                self.error = OfflineManager.FetchError.noOfflineDataAvailable
            }
        }
        isLoading = false
    }
    
    func loadAgeGroups(for gender: String) async {
        isLoading = true
        error = nil

        let hasOffline = hasOfflineStandards(gender: gender, ageCategory: nil)
        let lastSynced = getOfflineLastSynced()

        if OfflineManager.shared.shouldUseOfflineData(
            hasOfflineData: hasOffline,
            lastSynced: lastSynced
        ) {
            if let ageGroups = try? loadAgeGroupsFromSwiftData(gender: gender), !ageGroups.isEmpty {
                self.ageGroups = ageGroups
            }
            isLoading = false
            return
        }

        do {
            let response = try await supabase
                .from("standards")
                .select("age_category")
                .eq("gender", value: gender.lowercased())
                .execute()

            let rows = try JSONDecoder().decode([AgeRow].self, from: response.data)

            let lower = rows.map{ $0.age_category.lowercased()}
            let unique = Array(Set(lower))

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
            if hasOffline {
                if let ageGroups = try? loadAgeGroupsFromSwiftData(gender: gender), !ageGroups.isEmpty {
                    self.ageGroups = ageGroups
                } else {
                    self.error = error
                }
            } else {
                self.error = OfflineManager.FetchError.noOfflineDataAvailable
            }
        }
        isLoading = false
    }

    private func loadAgeGroupsFromSwiftData(gender: String) throws -> [String] {
        guard let context = modelContext else {
            throw NSError(domain: "Standards", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContext not set"])
        }

        let genderLower = gender.lowercased()
        let descriptor = FetchDescriptor<StandardsEntity>(
            predicate: #Predicate<StandardsEntity> {
                $0.gender == genderLower
            }
        )

        let entities = try context.fetch(descriptor)
        let lower = entities.map { $0.age_category.lowercased() }
        let unique = Array(Set(lower))

        let order: [String] = ["u15", "youth", "junior", "senior"]
        let rank = Dictionary(uniqueKeysWithValues: order.enumerated().map{($1, $0)})
        let ordered = unique.sorted{
            let l = rank[$0] ?? Int.max
            let r = rank[$1] ?? Int.max

            if l != r { return l < r}

            return $0 < $1
        }

        return ordered.map{
            let upper = $0.uppercased()
            if upper == "U13" || upper == "U15" || upper == "U17" {
                return upper
            } else {
                return $0.capitalized
            }
        }
    }
}
