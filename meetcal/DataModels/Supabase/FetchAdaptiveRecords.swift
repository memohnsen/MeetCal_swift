//
//  FetchAdaptiveRecords.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 10/7/25.
//

import Supabase
import Combine
import Foundation

// Helper struct to display grouped records by weight class
struct AdaptiveRecord: Hashable, Identifiable {
    let id = UUID()
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

        do {
            let response = try await supabase
                .from("lifting_results")
                .select()
                .eq("adaptive", value: true)
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

            // Convert to display format and sort by weight class
            let records = weightClassRecords.map { (weightClass, result) in
                AdaptiveRecord(
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
            self.groupedRecords = records
        } catch {
            #if DEBUG
            print("Error: \(error)")
            #endif
            self.error = error
        }
        isLoading = false
    }
}
