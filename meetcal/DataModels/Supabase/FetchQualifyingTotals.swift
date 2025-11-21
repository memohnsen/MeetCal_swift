//
//  FetchQualifyingTotals.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/7/25.
//

import SwiftUI
import Supabase
import Combine
import SwiftData

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

private struct AgeRow: Decodable {
    let age_category: String
}

private struct EventRow: Decodable {
    let event_name: String
}

@MainActor
class QualifyingTotalModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var totals: [QualifyingTotal] = []
    @Published var ageGroups: [String] = []
    @Published var meets: [String] = []
    @Published var isUsingOfflineData = false

    private var modelContext: ModelContext?

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    private func hasOfflineTotals(gender: String? = nil, ageCategory: String? = nil, eventName: String? = nil) -> Bool {
        guard let context = modelContext else { return false }

        var descriptor = FetchDescriptor<QTEntity>()

        if let gender = gender, let ageCategory = ageCategory, let eventName = eventName {
            descriptor.predicate = #Predicate<QTEntity> {
                $0.gender == gender &&
                $0.age_category == ageCategory &&
                $0.event_name == eventName
            }
        }

        descriptor.fetchLimit = 1
        let results = try? context.fetch(descriptor)
        return !(results?.isEmpty ?? true)
    }

    private func getOfflineLastSynced() -> Date? {
        guard let context = modelContext else { return nil }

        var descriptor = FetchDescriptor<QTEntity>()
        descriptor.fetchLimit = 1

        if let entities = try? context.fetch(descriptor),
           let firstEntity = entities.first {
            return firstEntity.lastSynced
        }
        return nil
    }

    private func loadTotalsFromSwiftData(gender: String? = nil, ageCategory: String? = nil, eventName: String? = nil) throws -> [QualifyingTotal] {
        guard let context = modelContext else {
            throw NSError(domain: "Qualifying Totals", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContext not set"])
        }

        var descriptor = FetchDescriptor<QTEntity>()

        if let gender = gender, let ageCategory = ageCategory, let eventName = eventName {
            descriptor.predicate = #Predicate<QTEntity> {
                $0.gender == gender &&
                $0.age_category == ageCategory &&
                $0.event_name == eventName
            }
        }

        let entities = try context.fetch(descriptor)

        return entities.map { entity in
            QualifyingTotal(
                id: entity.id,
                event_name: entity.event_name,
                gender: entity.gender,
                age_category: entity.age_category,
                weight_class: entity.weight_class,
                qualifying_total: entity.qualifying_total
            )
        }.sorted { (a: QualifyingTotal, b: QualifyingTotal) -> Bool in
            if a.isPlusClass != b.isPlusClass {
                return a.isPlusClass == false
            }
            if a.numericWeight != b.numericWeight {
                return a.numericWeight < b.numericWeight
            }
            return a.weight_class < b.weight_class
        }
    }
    
    func saveQTToSwiftData() throws {
        guard let context = modelContext else {
            throw NSError(domain: "Qualifying Totals", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContext not set"])
        }

        let fetchDescriptor = FetchDescriptor<QTEntity>()
        let existingRecords = try context.fetch(fetchDescriptor)
        for record in existingRecords {
            context.delete(record)
        }

        for total in totals {
            let entity = QTEntity(
                id: total.id,
                event_name: total.event_name,
                gender: total.gender,
                age_category: total.age_category,
                weight_class: total.weight_class,
                qualifying_total: total.qualifying_total,
                lastSynced: Date()
            )
            context.insert(entity)
        }
        try context.save()
    }
    
    func loadTotals(gender: String, age_category: String, event_name: String) async {
        isLoading = true
        error = nil
        isUsingOfflineData = false

        let hasOffline = hasOfflineTotals(gender: gender, ageCategory: age_category, eventName: event_name)
        let lastSynced = getOfflineLastSynced()

        if OfflineManager.shared.shouldUseOfflineData(
            hasOfflineData: hasOffline,
            lastSynced: lastSynced
        ) {
            do {
                let offlineTotals = try loadTotalsFromSwiftData(
                    gender: gender,
                    ageCategory: age_category,
                    eventName: event_name
                )
                self.totals.append(contentsOf: offlineTotals)
                self.isUsingOfflineData = true
            } catch {
                self.error = error
            }
            isLoading = false
            return
        }

        do {
            let response = try await supabase
                .from("qualifying_totals")
                .select()
                .eq("gender", value: gender)
                .eq("age_category", value: age_category)
                .eq("event_name", value: event_name)
                .execute()

            let decoder = JSONDecoder()
            let totalData = try decoder.decode([QualifyingTotal].self, from: response.data)
            self.totals.append(contentsOf: totalData.sorted { (a: QualifyingTotal, b: QualifyingTotal) -> Bool in
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
                    let offlineTotals = try loadTotalsFromSwiftData(
                        gender: gender,
                        ageCategory: age_category,
                        eventName: event_name
                    )
                    self.totals.append(contentsOf: offlineTotals)
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
    
    func loadAgeGroup(for gender: String, event_name: String) async {
        isLoading = true
        error = nil

        let hasOffline = hasOfflineTotals(gender: gender, ageCategory: nil, eventName: event_name)
        let lastSynced = getOfflineLastSynced()

        if OfflineManager.shared.shouldUseOfflineData(
            hasOfflineData: hasOffline,
            lastSynced: lastSynced
        ) {
            if let ageGroups = try? loadAgeGroupsFromSwiftData(gender: gender, eventName: event_name), !ageGroups.isEmpty {
                self.ageGroups = ageGroups
            }
            isLoading = false
            return
        }

        do {
            let response = try await supabase
                .from("qualifying_totals")
                .select("age_category")
                .eq("gender", value: gender)
                .eq("event_name", value: event_name)
                .execute()

            let rows = try JSONDecoder().decode([AgeRow].self, from: response.data)
            let unique = Array(Set(rows.map {$0.age_category}))

            let order: [String] = ["U11", "U13", "U15", "U17", "Junior", "University", "U23", "U25", "Senior", "Masters 30", "Masters 35", "Masters 40", "Masters 45", "Masters 50", "Masters 55", "Masters 60", "Masters 65", "Masters 70", "Masters 75", "Masters 80", "Masters 85"]
            let rank = Dictionary(uniqueKeysWithValues: order.enumerated().map{($1, $0)})
            let ordered = unique.sorted{
                let l = rank[$0] ?? Int.max
                let r = rank[$1] ?? Int.max

                if l != r { return l < r}

                return $0 < $1
            }

            self.ageGroups = ordered
        } catch {
            if hasOffline {
                if let ageGroups = try? loadAgeGroupsFromSwiftData(gender: gender, eventName: event_name), !ageGroups.isEmpty {
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

    private func loadAgeGroupsFromSwiftData(gender: String, eventName: String) throws -> [String] {
        guard let context = modelContext else {
            throw NSError(domain: "Qualifying Totals", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContext not set"])
        }

        let descriptor = FetchDescriptor<QTEntity>(
            predicate: #Predicate<QTEntity> {
                $0.gender == gender && $0.event_name == eventName
            }
        )

        let entities = try context.fetch(descriptor)
        let unique = Array(Set(entities.map { $0.age_category }))

        let order: [String] = ["U11", "U13", "U15", "U17", "Junior", "University", "U23", "U25", "Senior", "Masters 30", "Masters 35", "Masters 40", "Masters 45", "Masters 50", "Masters 55", "Masters 60", "Masters 65", "Masters 70", "Masters 75", "Masters 80", "Masters 85"]
        let rank = Dictionary(uniqueKeysWithValues: order.enumerated().map{($1, $0)})

        return unique.sorted{
            let l = rank[$0] ?? Int.max
            let r = rank[$1] ?? Int.max

            if l != r { return l < r}

            return $0 < $1
        }
    }

    func loadMeets() async {
        isLoading = true
        error = nil

        let hasOffline = hasOfflineTotals()
        let lastSynced = getOfflineLastSynced()

        if OfflineManager.shared.shouldUseOfflineData(
            hasOfflineData: hasOffline,
            lastSynced: lastSynced
        ) {
            if let meets = try? loadMeetsFromSwiftData(), !meets.isEmpty {
                self.meets = meets
            }
            isLoading = false
            return
        }

        do {
            let response = try await supabase
                .from("qualifying_totals")
                .select("event_name")
                .execute()

            let rows = try JSONDecoder().decode([EventRow].self, from: response.data)
            let unique = Array(Set(rows.map { $0.event_name }))
            self.meets = unique.sorted()
        } catch {
            if hasOffline {
                if let meets = try? loadMeetsFromSwiftData(), !meets.isEmpty {
                    self.meets = meets
                } else {
                    self.error = error
                }
            } else {
                self.error = OfflineManager.FetchError.noOfflineDataAvailable
            }
        }
        isLoading = false
    }

    private func loadMeetsFromSwiftData() throws -> [String] {
        guard let context = modelContext else {
            throw NSError(domain: "Qualifying Totals", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContext not set"])
        }

        let descriptor = FetchDescriptor<QTEntity>()
        let entities = try context.fetch(descriptor)
        let unique = Array(Set(entities.map { $0.event_name }))
        return unique.sorted()
    }
}
