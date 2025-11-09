//
//  FetchAdaptiveRecords.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 10/7/25.
//

import Supabase
import SwiftData
import Combine
import Foundation

struct AdaptiveRecord: Hashable, Identifiable {
    let id: Int
    let age: String
    let gender: String
    let weightClass: String
    let snatch_best: Float
    let cj_best: Float
    let total: Float
    let athleteName: String
}

@MainActor
class AdaptiveRecordsModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var results: [AthleteResults] = []
    @Published var groupedRecords: [AdaptiveRecord] = []
    @Published var isUsingOfflineData = false

    private var modelContext: ModelContext?

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    private func hasOfflineRecords(gender: String? = nil) -> Bool {
        guard let context = modelContext else { return false }

        var descriptor = FetchDescriptor<AdaptiveRecordEntity>()

        if let gender = gender {
            descriptor.predicate = #Predicate<AdaptiveRecordEntity> {
                $0.gender == gender
            }
        }

        descriptor.fetchLimit = 1
        let results = try? context.fetch(descriptor)
        return !(results?.isEmpty ?? true)
    }

    private func getOfflineLastSynced() -> Date? {
        guard let context = modelContext else { return nil }

        var descriptor = FetchDescriptor<AdaptiveRecordEntity>()
        descriptor.fetchLimit = 1

        if let entities = try? context.fetch(descriptor),
           let firstEntity = entities.first {
            return firstEntity.lastSynced
        }
        return nil
    }

    private func loadRecordsFromSwiftData(gender: String? = nil) throws -> [AdaptiveRecord] {
        guard let context = modelContext else {
            throw NSError(domain: "AdaptiveRecords", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContext not set"])
        }

        var descriptor = FetchDescriptor<AdaptiveRecordEntity>()

        if let gender = gender {
            descriptor.predicate = #Predicate<AdaptiveRecordEntity> {
                $0.gender == gender
            }
        }

        let entities = try context.fetch(descriptor)

        return entities.map { entity in
            AdaptiveRecord(
                id: entity.id,
                age: entity.age,
                gender: entity.gender,
                weightClass: entity.weight_class,
                snatch_best: entity.snatch_best,
                cj_best: entity.cj_best,
                total: entity.total,
                athleteName: entity.name
            )
        }.sorted { (record1, record2) in
            let num1 = Int(record1.weightClass.replacingOccurrences(of: #"[^\d]"#, with: "", options: .regularExpression)) ?? 0
            let num2 = Int(record2.weightClass.replacingOccurrences(of: #"[^\d]"#, with: "", options: .regularExpression)) ?? 0

            let has1Plus = record1.weightClass.contains("+")
            let has2Plus = record2.weightClass.contains("+")

            if has1Plus && !has2Plus {
                return false
            } else if !has1Plus && has2Plus {
                return true
            }

            return num1 < num2
        }
    }
    
    func saveAdapRecordsToSwiftData() throws {
        guard let context = modelContext else {
            throw NSError(domain: "AdaptiveRecords", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContext not set"])
        }

        // Delete existing records first (to avoid duplicates)
        let fetchDescriptor = FetchDescriptor<AdaptiveRecordEntity>()
        let existingRecords = try context.fetch(fetchDescriptor)
        for record in existingRecords {
            context.delete(record)
        }

        // Insert new records
        for record in groupedRecords {
            let entity = AdaptiveRecordEntity(
                id: record.id,
                age: record.age,
                gender: record.gender,
                weight_class: record.weightClass,
                snatch_best: record.snatch_best,
                cj_best: record.cj_best,
                total: record.total,
                name: record.athleteName,
                lastSynced: Date()
            )
            context.insert(entity)
        }

        try context.save()
    }

    // Extract weight class from age column (e.g., "Women's Masters (35-39) 69kg" -> "69kg")
    private func extractWeightClass(from ageString: String) -> String? {
        // Look for pattern like "69kg" or "86+kg" at the end
        let pattern = #"(\d+\+?kg)$"#
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: ageString, range: NSRange(ageString.startIndex..., in: ageString)) {
            if let range = Range(match.range(at: 1), in: ageString) {
                return String(ageString[range])
            }
        }
        return nil
    }

    func loadAdaptiveRecords(gender: String) async {
        isLoading = true
        error = nil
        isUsingOfflineData = false

        let hasOffline = hasOfflineRecords(gender: gender)
        let lastSynced = getOfflineLastSynced()

        if OfflineManager.shared.shouldUseOfflineData(
            hasOfflineData: hasOffline,
            lastSynced: lastSynced
        ) {
            do {
                let offlineRecords = try loadRecordsFromSwiftData(gender: gender)
                self.groupedRecords.append(contentsOf: offlineRecords)
                self.isUsingOfflineData = true
            } catch {
                self.error = error
            }
            isLoading = false
            return
        }

        do {
            let response = try await supabase
                .from("lifting_results")
                .select()
                .eq("adaptive", value: true)
                .neq("federation", value: "BWL")
                .like("age", pattern: "%\(gender)%")
                .order("total", ascending: false)
                .execute()

            let rows = try JSONDecoder().decode([AthleteResults].self, from: response.data)

            var weightClassRecords: [String: AthleteResults] = [:]

            for result in rows {
                guard let weightClass = extractWeightClass(from: result.age) else { continue }

                if let existingRecord = weightClassRecords[weightClass] {
                    if result.total > existingRecord.total {
                        weightClassRecords[weightClass] = result
                    }
                } else {
                    weightClassRecords[weightClass] = result
                }
            }

            let records = weightClassRecords.map { (weightClass, result) in
                AdaptiveRecord(
                    id: result.id,
                    age: result.age,
                    gender: gender,
                    weightClass: weightClass,
                    snatch_best: result.snatch_best,
                    cj_best: result.cj_best,
                    total: result.total,
                    athleteName: result.name
                )
            }.sorted { (record1, record2) in
                let num1 = Int(record1.weightClass.replacingOccurrences(of: #"[^\d]"#, with: "", options: .regularExpression)) ?? 0
                let num2 = Int(record2.weightClass.replacingOccurrences(of: #"[^\d]"#, with: "", options: .regularExpression)) ?? 0

                let has1Plus = record1.weightClass.contains("+")
                let has2Plus = record2.weightClass.contains("+")

                if has1Plus && !has2Plus {
                    return false
                } else if !has1Plus && has2Plus {
                    return true
                }

                return num1 < num2
            }

            self.results.removeAll()
            self.results.append(contentsOf: rows)
            self.groupedRecords.append(contentsOf: records)
            self.isUsingOfflineData = false
        } catch {
            if hasOffline {
                do {
                    let offlineRecords = try loadRecordsFromSwiftData(gender: gender)
                    self.groupedRecords.append(contentsOf: offlineRecords)
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
}
