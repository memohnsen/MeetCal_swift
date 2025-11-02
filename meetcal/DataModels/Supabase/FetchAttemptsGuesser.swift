//
//  FetchAttemptsGuesser.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 11/2/25.
//

import SwiftUI
import Foundation
import Combine

struct AthleteAttemptEstimate: Identifiable {
    let id = UUID()
    let athleteName: String
    let snatchEstimates: [Int]
    let cjEstimates: [Int]
    let snatchAttemptsOut: Int
    let cjAttemptsOut: Int
    let averageSnatchIncrease: (first: Int, second: Int)
    let averageCJIncrease: (first: Int, second: Int)
    let bestSnatch: Float?
    let bestCJ: Float?
    let snatchMakeRate: Double
    let cjMakeRate: Double
}

struct AttemptData: Comparable {
    let athleteName: String
    let weight: Int
    let attemptNumber: Int
    let liftType: String

    static func < (lhs: AttemptData, rhs: AttemptData) -> Bool {
        return lhs.weight < rhs.weight
    }
}

@MainActor
class AttemptsGuesserModel: ObservableObject {
    @Published var athleteEstimates: [AthleteAttemptEstimate] = []

    func calculateEstimates(athletes: [AthleteRow], athleteResults: [AthleteResults]) {
        var estimates: [AthleteAttemptEstimate] = []

        // Calculate two years ago date
        let twoYearsAgo = Calendar.current.date(byAdding: .year, value: -2, to: Date()) ?? Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let twoYearsAgoString = dateFormatter.string(from: twoYearsAgo)

        print("\n========================================")
        print("ATTEMPTS GUESSER CALCULATION")
        print("Two years ago cutoff: \(twoYearsAgoString)")
        print("========================================\n")

        for athlete in athletes {
            print("--- \(athlete.name) ---")

            // Get athlete's results from past 2 years
            let athleteHistory = athleteResults.filter { result in
                result.name == athlete.name && result.date >= twoYearsAgoString
            }

            print("Found \(athleteHistory.count) meets in past 2 years")
            for (index, result) in athleteHistory.enumerated() {
                print("  Meet \(index + 1): \(result.meet) (\(result.date))")
                print("    Snatch: \(Int(result.snatch1))/\(Int(result.snatch2))/\(Int(result.snatch3)) (best: \(Int(result.snatch_best)))")
                print("    CJ: \(Int(result.cj1))/\(Int(result.cj2))/\(Int(result.cj3)) (best: \(Int(result.cj_best)))")
            }

            // Get best snatch and CJ in past 2 years
            let bestSnatch = athleteHistory.map { $0.snatch_best }.max()
            let bestCJ = athleteHistory.map { $0.cj_best }.max()

            print("Best Snatch: \(bestSnatch != nil ? String(Int(bestSnatch!)) : "nil")")
            print("Best CJ: \(bestCJ != nil ? String(Int(bestCJ!)) : "nil")")

            // Calculate estimated attempts
            var snatchEstimates: [Int] = []
            var cjEstimates: [Int] = []
            var avgSnatchIncrease = (first: 0, second: 0)
            var avgCJIncrease = (first: 0, second: 0)

            if let bestSnatch = bestSnatch, bestSnatch > 0 {
                // Calculate average increases
                avgSnatchIncrease = calculateAverageIncrease(results: athleteHistory, liftType: .snatch)

                // 93% of best for first attempt
                let firstAttempt = Int(round(bestSnatch * 0.93))
                let secondAttempt = firstAttempt + avgSnatchIncrease.first
                let thirdAttempt = secondAttempt + avgSnatchIncrease.second

                snatchEstimates = [firstAttempt, secondAttempt, thirdAttempt]
                print("Snatch avg increases: 1→2: \(avgSnatchIncrease.first)kg, 2→3: \(avgSnatchIncrease.second)kg")
                print("Snatch estimates: \(snatchEstimates[0])/\(snatchEstimates[1])/\(snatchEstimates[2])")
            }

            if let bestCJ = bestCJ, bestCJ > 0 {
                // Calculate average increases
                avgCJIncrease = calculateAverageIncrease(results: athleteHistory, liftType: .cleanJerk)

                // 93% of best for first attempt
                let firstAttempt = Int(round(bestCJ * 0.93))
                let secondAttempt = firstAttempt + avgCJIncrease.first
                let thirdAttempt = secondAttempt + avgCJIncrease.second

                cjEstimates = [firstAttempt, secondAttempt, thirdAttempt]
                print("CJ avg increases: 1→2: \(avgCJIncrease.first)kg, 2→3: \(avgCJIncrease.second)kg")
                print("CJ estimates: \(cjEstimates[0])/\(cjEstimates[1])/\(cjEstimates[2])")
            }

            // Calculate make rates
            let (snatchMakeRate, cjMakeRate) = calculateMakeRates(results: athleteHistory)
            print("Make rates - Snatch: \(Int(snatchMakeRate * 100))%, CJ: \(Int(cjMakeRate * 100))%")

            let estimate = AthleteAttemptEstimate(
                athleteName: athlete.name,
                snatchEstimates: snatchEstimates,
                cjEstimates: cjEstimates,
                snatchAttemptsOut: 0, // Will calculate after all estimates
                cjAttemptsOut: 0, // Will calculate after all estimates
                averageSnatchIncrease: avgSnatchIncrease,
                averageCJIncrease: avgCJIncrease,
                bestSnatch: bestSnatch,
                bestCJ: bestCJ,
                snatchMakeRate: snatchMakeRate,
                cjMakeRate: cjMakeRate
            )

            estimates.append(estimate)
            print("")  // Empty line between athletes
        }

        // Calculate attempts out for each athlete
        print("========================================")
        print("CALCULATING ATTEMPTS OUT")
        print("========================================\n")
        estimates = calculateAttemptsOut(estimates: estimates)

        self.athleteEstimates = estimates
    }

    private func calculateAverageIncrease(results: [AthleteResults], liftType: LiftType) -> (first: Int, second: Int) {
        var firstToSecondIncreases: [Int] = []
        var secondToThirdIncreases: [Int] = []

        for result in results {
            switch liftType {
            case .snatch:
                // Only count positive increases (successful attempts)
                if result.snatch1 > 0 && result.snatch2 > 0 && result.snatch2 > result.snatch1 {
                    firstToSecondIncreases.append(Int(result.snatch2 - result.snatch1))
                }
                if result.snatch2 > 0 && result.snatch3 > 0 && result.snatch3 > result.snatch2 {
                    secondToThirdIncreases.append(Int(result.snatch3 - result.snatch2))
                }
            case .cleanJerk:
                // Only count positive increases (successful attempts)
                if result.cj1 > 0 && result.cj2 > 0 && result.cj2 > result.cj1 {
                    firstToSecondIncreases.append(Int(result.cj2 - result.cj1))
                }
                if result.cj2 > 0 && result.cj3 > 0 && result.cj3 > result.cj2 {
                    secondToThirdIncreases.append(Int(result.cj3 - result.cj2))
                }
            }
        }

        let avgFirstToSecond = firstToSecondIncreases.isEmpty ? 3 : Int(round(Double(firstToSecondIncreases.reduce(0, +)) / Double(firstToSecondIncreases.count)))
        let avgSecondToThird = secondToThirdIncreases.isEmpty ? 3 : Int(round(Double(secondToThirdIncreases.reduce(0, +)) / Double(secondToThirdIncreases.count)))

        return (avgFirstToSecond, avgSecondToThird)
    }

    private func calculateMakeRates(results: [AthleteResults]) -> (snatch: Double, cj: Double) {
        var snatchFirstAttempts = 0
        var snatchFirstMakes = 0
        var cjFirstAttempts = 0
        var cjFirstMakes = 0

        for result in results {
            if result.snatch1 > 0 {
                snatchFirstAttempts += 1
                if result.snatch_best >= result.snatch1 {
                    snatchFirstMakes += 1
                }
            }

            if result.cj1 > 0 {
                cjFirstAttempts += 1
                if result.cj_best >= result.cj1 {
                    cjFirstMakes += 1
                }
            }
        }

        let snatchRate = snatchFirstAttempts > 0 ? Double(snatchFirstMakes) / Double(snatchFirstAttempts) : 0.0
        let cjRate = cjFirstAttempts > 0 ? Double(cjFirstMakes) / Double(cjFirstAttempts) : 0.0

        return (snatchRate, cjRate)
    }

    private func calculateAttemptsOut(estimates: [AthleteAttemptEstimate]) -> [AthleteAttemptEstimate] {
        // Create sorted arrays of all attempts
        var snatchAttempts: [AttemptData] = []
        var cjAttempts: [AttemptData] = []

        for estimate in estimates {
            for (index, weight) in estimate.snatchEstimates.enumerated() {
                if weight > 0 {
                    snatchAttempts.append(AttemptData(
                        athleteName: estimate.athleteName,
                        weight: weight,
                        attemptNumber: index + 1,
                        liftType: "snatch"
                    ))
                }
            }

            for (index, weight) in estimate.cjEstimates.enumerated() {
                if weight > 0 {
                    cjAttempts.append(AttemptData(
                        athleteName: estimate.athleteName,
                        weight: weight,
                        attemptNumber: index + 1,
                        liftType: "cj"
                    ))
                }
            }
        }

        // Sort by weight
        snatchAttempts.sort()
        cjAttempts.sort()

        print("SNATCH ORDER (by weight):")
        for (index, attempt) in snatchAttempts.enumerated() {
            print("  \(index). \(attempt.athleteName) - Attempt #\(attempt.attemptNumber): \(attempt.weight)kg")
        }

        print("\nCJ ORDER (by weight):")
        for (index, attempt) in cjAttempts.enumerated() {
            print("  \(index). \(attempt.athleteName) - Attempt #\(attempt.attemptNumber): \(attempt.weight)kg")
        }
        print("")

        // Calculate attempts out for each athlete
        return estimates.map { estimate in
            var snatchOut = 0
            var cjOut = 0

            // Find first snatch attempt
            if let firstSnatchIndex = snatchAttempts.firstIndex(where: {
                $0.athleteName == estimate.athleteName && $0.attemptNumber == 1
            }) {
                // Count attempts before this athlete's first attempt
                // If an athlete appears consecutively, count it as 2 instead of 1
                for i in 0..<firstSnatchIndex {
                    snatchOut += 1

                    // Check if next attempt is the same athlete (they're following themselves)
                    if i + 1 < snatchAttempts.count && i + 1 < firstSnatchIndex && snatchAttempts[i].athleteName == snatchAttempts[i + 1].athleteName {
                        snatchOut += 1  // Add extra 1 when athlete follows themselves
                        print("  → \(snatchAttempts[i].athleteName) follows themselves at position \(i)")
                    }
                }
            }

            // Find first CJ attempt
            if let firstCJIndex = cjAttempts.firstIndex(where: {
                $0.athleteName == estimate.athleteName && $0.attemptNumber == 1
            }) {
                // Count attempts before this athlete's first attempt
                // If an athlete appears consecutively, count it as 2 instead of 1
                for i in 0..<firstCJIndex {
                    cjOut += 1

                    // Check if next attempt is the same athlete (they're following themselves)
                    if i + 1 < cjAttempts.count && i + 1 < firstCJIndex && cjAttempts[i].athleteName == cjAttempts[i + 1].athleteName {
                        cjOut += 1  // Add extra 1 when athlete follows themselves
                        print("  → \(cjAttempts[i].athleteName) follows themselves at position \(i)")
                    }
                }
            }

            print("\(estimate.athleteName) - Snatch: \(snatchOut) attempts out, CJ: \(cjOut) attempts out")

            return AthleteAttemptEstimate(
                athleteName: estimate.athleteName,
                snatchEstimates: estimate.snatchEstimates,
                cjEstimates: estimate.cjEstimates,
                snatchAttemptsOut: snatchOut,
                cjAttemptsOut: cjOut,
                averageSnatchIncrease: estimate.averageSnatchIncrease,
                averageCJIncrease: estimate.averageCJIncrease,
                bestSnatch: estimate.bestSnatch,
                bestCJ: estimate.bestCJ,
                snatchMakeRate: estimate.snatchMakeRate,
                cjMakeRate: estimate.cjMakeRate
            )
        }
    }

    private enum LiftType {
        case snatch
        case cleanJerk
    }
}
