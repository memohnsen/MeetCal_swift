//
//  FetchWorldRecords.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 11/7/25.
//

import Supabase
import Combine
import Foundation
import SwiftData

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
    @Published var isUsingOfflineData = false

    private var modelContext: ModelContext?

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    private func hasOfflineRecords(gender: String, age_category: String) -> Bool {
        guard let context = modelContext else { return false }

        var descriptor = FetchDescriptor<WorldRecordsEntity>()
        descriptor.predicate = #Predicate<WorldRecordsEntity> {
            $0.gender == gender && $0.age_category == age_category
        }
        descriptor.fetchLimit = 1
        let results = try? context.fetch(descriptor)
        return !(results?.isEmpty ?? true)
    }

    private func getOfflineLastSynced() -> Date? {
        guard let context = modelContext else { return nil }

        var descriptor = FetchDescriptor<WorldRecordsEntity>()
        descriptor.fetchLimit = 1

        if let entities = try? context.fetch(descriptor),
           let firstEntity = entities.first {
            return firstEntity.lastSynced
        }
        return nil
    }

    private func loadRecordsFromSwiftData(gender: String, age_category: String) throws -> [WorldRecords] {
        guard let context = modelContext else {
            throw NSError(domain: "IWF World Records", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContext not set"])
        }

        var descriptor = FetchDescriptor<WorldRecordsEntity>()
        descriptor.predicate = #Predicate<WorldRecordsEntity> {
            $0.gender == gender && $0.age_category == age_category
        }

        let entities = try context.fetch(descriptor)

        return entities.map { entity in
            WorldRecords(
                id: entity.id,
                gender: entity.gender,
                age_category: entity.age_category,
                weight_class: entity.weight_class,
                snatch_record: entity.snatch_record,
                cj_record: entity.cj_record,
                total_record: entity.total_record
            )
        }.sorted { (a: WorldRecords, b: WorldRecords) -> Bool in
            if a.isPlusClass != b.isPlusClass {
                return a.isPlusClass == false
            }
            if a.numericWeight != b.numericWeight {
                return a.numericWeight < b.numericWeight
            }
            return a.weight_class < b.weight_class
        }
    }

    func saveWorldRecordsToSwiftData() throws {
        guard let context = modelContext else {
            throw NSError(domain: "IWF World Records", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContext not set"])
        }

        let fetchDescriptor = FetchDescriptor<WorldRecordsEntity>()
        let existingRecords = try context.fetch(fetchDescriptor)
        for record in existingRecords {
            context.delete(record)
        }

        for record in worldRecords {
            let entity = WorldRecordsEntity(
                id: record.id,
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

    func loadRecords(gender: String, age_category: String) async {
        isLoading = true
        error = nil
        isUsingOfflineData = false

        let hasOffline = hasOfflineRecords(gender: gender, age_category: age_category)
        let lastSynced = getOfflineLastSynced()

        if OfflineManager.shared.shouldUseOfflineData(
            hasOfflineData: hasOffline,
            lastSynced: lastSynced
        ) {
            do {
                let offlineRecords = try loadRecordsFromSwiftData(
                    gender: gender,
                    age_category: age_category
                )
                self.worldRecords = offlineRecords
                self.isUsingOfflineData = true
            } catch {
                self.error = error
            }
            isLoading = false
            return
        }

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
