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

    private let debugMode = false

    func calculateEstimates(athletes: [AthleteRow], athleteResults: [AthleteResults]) {
        var estimates: [AthleteAttemptEstimate] = []

        // Calculate two years ago date
        let twoYearsAgo = Calendar.current.date(byAdding: .year, value: -2, to: Date()) ?? Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let twoYearsAgoString = dateFormatter.string(from: twoYearsAgo)

        if debugMode {
            print("\n========================================")
            print("ATTEMPTS GUESSER CALCULATION")
            print("Two years ago cutoff: \(twoYearsAgoString)")
            print("========================================\n")
        }

        // First pass: collect all estimates from athletes WITH history to calculate session averages
        var tempEstimates: [(athlete: AthleteRow, history: [AthleteResults], bestSnatch: Float?, bestCJ: Float?, avgSnatchIncrease: (Int, Int), avgCJIncrease: (Int, Int), snatchMakeRate: Double, cjMakeRate: Double)] = []

        for athlete in athletes {
            let athleteHistory = athleteResults.filter { result in
                result.name == athlete.name && result.date >= twoYearsAgoString
            }

            let bestSnatch = athleteHistory.map { $0.snatch_best }.max()
            let bestCJ = athleteHistory.map { $0.cj_best }.max()

            let avgSnatchIncrease = calculateAverageIncrease(results: athleteHistory, liftType: .snatch)
            let avgCJIncrease = calculateAverageIncrease(results: athleteHistory, liftType: .cleanJerk)
            let (snatchMakeRate, cjMakeRate) = calculateMakeRates(results: athleteHistory)

            tempEstimates.append((athlete, athleteHistory, bestSnatch, bestCJ, avgSnatchIncrease, avgCJIncrease, snatchMakeRate, cjMakeRate))
        }

        // Calculate session average jumps from athletes with history
        let sessionSnatchJumps = tempEstimates.compactMap { estimate -> (Int, Int)? in
            guard estimate.bestSnatch != nil && estimate.bestSnatch! > 0 else { return nil }
            return estimate.avgSnatchIncrease
        }
        let sessionCJJumps = tempEstimates.compactMap { estimate -> (Int, Int)? in
            guard estimate.bestCJ != nil && estimate.bestCJ! > 0 else { return nil }
            return estimate.avgCJIncrease
        }

        let sessionAvgSnatchJump1to2 = sessionSnatchJumps.isEmpty ? 3 : Int(round(Double(sessionSnatchJumps.map { $0.0 }.reduce(0, +)) / Double(sessionSnatchJumps.count)))
        let sessionAvgSnatchJump2to3 = sessionSnatchJumps.isEmpty ? 3 : Int(round(Double(sessionSnatchJumps.map { $0.1 }.reduce(0, +)) / Double(sessionSnatchJumps.count)))
        let sessionAvgCJJump1to2 = sessionCJJumps.isEmpty ? 4 : Int(round(Double(sessionCJJumps.map { $0.0 }.reduce(0, +)) / Double(sessionCJJumps.count)))
        let sessionAvgCJJump2to3 = sessionCJJumps.isEmpty ? 4 : Int(round(Double(sessionCJJumps.map { $0.1 }.reduce(0, +)) / Double(sessionCJJumps.count)))

        if debugMode {
            print("Session Average Jumps:")
            print("  Snatch: 1→2: \(sessionAvgSnatchJump1to2)kg, 2→3: \(sessionAvgSnatchJump2to3)kg")
            print("  CJ: 1→2: \(sessionAvgCJJump1to2)kg, 2→3: \(sessionAvgCJJump2to3)kg\n")
        }

        // Second pass: create estimates for all athletes
        for (athlete, athleteHistory, bestSnatch, bestCJ, avgSnatchIncrease, avgCJIncrease, snatchMakeRate, cjMakeRate) in tempEstimates {
            if debugMode {
                print("--- \(athlete.name) ---")

                print("Found \(athleteHistory.count) meets in past 2 years")
                for (index, result) in athleteHistory.enumerated() {
                    print("  Meet \(index + 1): \(result.meet) (\(result.date))")
                    print("    Snatch: \(Int(result.snatch1))/\(Int(result.snatch2))/\(Int(result.snatch3)) (best: \(Int(result.snatch_best)))")
                    print("    CJ: \(Int(result.cj1))/\(Int(result.cj2))/\(Int(result.cj3)) (best: \(Int(result.cj_best)))")
                }

                print("Best Snatch: \(bestSnatch != nil ? String(Int(bestSnatch!)) : "nil")")
                print("Best CJ: \(bestCJ != nil ? String(Int(bestCJ!)) : "nil")")
            }

            // Calculate estimated attempts
            var snatchEstimates: [Int] = []
            var cjEstimates: [Int] = []
            var finalAvgSnatchIncrease = avgSnatchIncrease
            var finalAvgCJIncrease = avgCJIncrease

            // Use history if available, otherwise use entry total
            if let bestSnatch = bestSnatch, bestSnatch > 0 {
                let firstAttempt = Int(round(bestSnatch * 0.93))
                let secondAttempt = firstAttempt + avgSnatchIncrease.0
                let thirdAttempt = secondAttempt + avgSnatchIncrease.1

                snatchEstimates = [firstAttempt, secondAttempt, thirdAttempt]
                if debugMode {
                    print("Snatch avg increases: 1→2: \(avgSnatchIncrease.0)kg, 2→3: \(avgSnatchIncrease.1)kg")
                    print("Snatch estimates: \(snatchEstimates[0])/\(snatchEstimates[1])/\(snatchEstimates[2])")
                }
            } else if athlete.entry_total > 0 {
                // No history - use entry total
                if debugMode {
                    print("No snatch history - using entry total: \(athlete.entry_total)kg")
                }
                let estimatedTotal = Int(round(Float(athlete.entry_total) * 0.93))
                let snatchOpener = Int(round(Float(estimatedTotal) * 0.43))
                let secondAttempt = snatchOpener + sessionAvgSnatchJump1to2
                let thirdAttempt = secondAttempt + sessionAvgSnatchJump2to3

                snatchEstimates = [snatchOpener, secondAttempt, thirdAttempt]
                finalAvgSnatchIncrease = (sessionAvgSnatchJump1to2, sessionAvgSnatchJump2to3)
                if debugMode {
                    print("Snatch estimates (from entry): \(snatchEstimates[0])/\(snatchEstimates[1])/\(snatchEstimates[2])")
                }
            }

            if let bestCJ = bestCJ, bestCJ > 0 {
                let firstAttempt = Int(round(bestCJ * 0.93))
                let secondAttempt = firstAttempt + avgCJIncrease.0
                let thirdAttempt = secondAttempt + avgCJIncrease.1

                cjEstimates = [firstAttempt, secondAttempt, thirdAttempt]
                if debugMode {
                    print("CJ avg increases: 1→2: \(avgCJIncrease.0)kg, 2→3: \(avgCJIncrease.1)kg")
                    print("CJ estimates: \(cjEstimates[0])/\(cjEstimates[1])/\(cjEstimates[2])")
                }
            } else if athlete.entry_total > 0 {
                // No history - use entry total
                if debugMode {
                    print("No CJ history - using entry total: \(athlete.entry_total)kg")
                }
                let estimatedTotal = Int(round(Float(athlete.entry_total) * 0.93))
                let cjOpener = Int(round(Float(estimatedTotal) * 0.57))
                let secondAttempt = cjOpener + sessionAvgCJJump1to2
                let thirdAttempt = secondAttempt + sessionAvgCJJump2to3

                cjEstimates = [cjOpener, secondAttempt, thirdAttempt]
                finalAvgCJIncrease = (sessionAvgCJJump1to2, sessionAvgCJJump2to3)
                if debugMode {
                    print("CJ estimates (from entry): \(cjEstimates[0])/\(cjEstimates[1])/\(cjEstimates[2])")
                }
            }

            if debugMode {
                print("Make rates - Snatch: \(Int(snatchMakeRate * 100))%, CJ: \(Int(cjMakeRate * 100))%")
            }

            let estimate = AthleteAttemptEstimate(
                athleteName: athlete.name,
                snatchEstimates: snatchEstimates,
                cjEstimates: cjEstimates,
                snatchAttemptsOut: 0, // Will calculate after all estimates
                cjAttemptsOut: 0, // Will calculate after all estimates
                averageSnatchIncrease: finalAvgSnatchIncrease,
                averageCJIncrease: finalAvgCJIncrease,
                bestSnatch: bestSnatch,
                bestCJ: bestCJ,
                snatchMakeRate: snatchMakeRate,
                cjMakeRate: cjMakeRate
            )

            estimates.append(estimate)
            if debugMode {
                print("")  // Empty line between athletes
            }
        }

        // Calculate attempts out for each athlete
        if debugMode {
            print("========================================")
            print("CALCULATING ATTEMPTS OUT")
            print("========================================\n")
        }
        estimates = calculateAttemptsOut(estimates: estimates)

        self.athleteEstimates = estimates
    }

    private func calculateAverageIncrease(results: [AthleteResults], liftType: LiftType) -> (first: Int, second: Int) {
        var firstToSecondIncreases: [Int] = []
        var secondToThirdIncreases: [Int] = []

        for result in results {
            switch liftType {
            case .snatch:
                // Only count increases from positive to positive (both successful)
                if result.snatch1 > 0 && result.snatch2 > 0 {
                    firstToSecondIncreases.append(Int(abs(result.snatch2 - result.snatch1)))
                }
                // Only count 2nd to 3rd if 2nd was positive (successful)
                if result.snatch2 > 0 && result.snatch3 > 0 {
                    secondToThirdIncreases.append(Int(abs(result.snatch3 - result.snatch2)))
                }
            case .cleanJerk:
                // Only count increases from positive to positive (both successful)
                if result.cj1 > 0 && result.cj2 > 0 {
                    firstToSecondIncreases.append(Int(abs(result.cj2 - result.cj1)))
                }
                // Only count 2nd to 3rd if 2nd was positive (successful)
                if result.cj2 > 0 && result.cj3 > 0 {
                    secondToThirdIncreases.append(Int(abs(result.cj3 - result.cj2)))
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

        if debugMode {
            print("SNATCH ORDER (by weight):")
            for (index, attempt) in snatchAttempts.enumerated() {
                print("  \(index). \(attempt.athleteName) - Attempt #\(attempt.attemptNumber): \(attempt.weight)kg")
            }

            print("\nCJ ORDER (by weight):")
            for (index, attempt) in cjAttempts.enumerated() {
                print("  \(index). \(attempt.athleteName) - Attempt #\(attempt.attemptNumber): \(attempt.weight)kg")
            }
            print("")
        }

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
                        if debugMode {
                            print("  → \(snatchAttempts[i].athleteName) follows themselves at position \(i)")
                        }
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
                        if debugMode {
                            print("  → \(cjAttempts[i].athleteName) follows themselves at position \(i)")
                        }
                    }
                }
            }

            if debugMode {
                print("\(estimate.athleteName) - Snatch: \(snatchOut) attempts out, CJ: \(cjOut) attempts out")
            }

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
