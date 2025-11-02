//
//  AttemptsGuesser.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 11/2/25.
//

import SwiftUI
import PostHog

struct AttemptsGuesser: View {
    let athletes: [AthleteRow]
    let athleteResults: [AthleteResults]

    @StateObject private var viewModel = AttemptsGuesserModel()
    
    var body: some View {
        NavigationStack{
            Text("This data is based on historical meet results and may be inaccurate if the session includes athletes at their first meet. Always refer to the board for the final count.")
                .secondaryText()
                .italic()
                .padding(.horizontal)
                .multilineTextAlignment(.center)
            
            
            List{
                ForEach(viewModel.athleteEstimates.sorted(by: { $0.snatchAttemptsOut < $1.snatchAttemptsOut })) { estimate in
                    DisclosureGroup(estimate.athleteName){
                        VStack(alignment: .leading, spacing: 8){
                            if estimate.bestSnatch == nil && estimate.bestCJ == nil {
                                Text("No historical data available for this athlete in the past 2 years")
                                    .secondaryText()
                                    .italic()
                                    .padding(.vertical, 8)
                            } else {
                                Text("Estimated Count")
                                    .bold()

                                if !estimate.snatchEstimates.isEmpty && estimate.snatchEstimates[0] > 0 {
                                    Text("Snatch: \(estimate.snatchAttemptsOut) attempts out")
                                        .secondaryText()
                                } else {
                                    Text("Snatch: No historical data")
                                        .secondaryText()
                                }

                                if !estimate.cjEstimates.isEmpty && estimate.cjEstimates[0] > 0 {
                                    Text("CJ: \(estimate.cjAttemptsOut) attempts out")
                                        .secondaryText()
                                } else {
                                    Text("CJ: No historical data")
                                        .secondaryText()
                                }

                                Divider()
                                    .padding(.vertical, 12)

                                Text("Estimated Attempts")
                                    .bold()
                                    .padding(.bottom, 8)

                                Grid{
                                    GridRow{
                                        Text("")
                                        Text("1")
                                            .bold()
                                        Text("2")
                                            .bold()
                                        Text("3")
                                            .bold()
                                    }

                                    Divider()

                                    if !estimate.snatchEstimates.isEmpty && estimate.snatchEstimates[0] > 0 {
                                        GridRow{
                                            Text("Snatch")
                                                .bold()
                                            Text("\(estimate.snatchEstimates[0])")
                                                .secondaryText()
                                            Text("\(estimate.snatchEstimates[1])")
                                                .secondaryText()
                                            Text("\(estimate.snatchEstimates[2])")
                                                .secondaryText()
                                        }

                                        Divider()
                                    }

                                    if !estimate.cjEstimates.isEmpty && estimate.cjEstimates[0] > 0 {
                                        GridRow{
                                            Text("CJ")
                                                .bold()
                                            Text("\(estimate.cjEstimates[0])")
                                                .secondaryText()
                                            Text("\(estimate.cjEstimates[1])")
                                                .secondaryText()
                                            Text("\(estimate.cjEstimates[2])")
                                                .secondaryText()
                                        }
                                    }
                                }

                                Divider()
                                    .padding(.vertical, 12)

                                Text("Athlete Notes")
                                    .bold()

                                Text(generateAthleteNotes(estimate: estimate))
                                    .secondaryText()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Attempts Out Guesser")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                AnalyticsManager.shared.trackScreenView("Attempts Out Guesser")

                // Get meet name and session number from the first athlete if available
                let meetName = athletes.first?.meet ?? "Unknown"
                let sessionNumber = athletes.first?.session_number ?? 0

                AnalyticsManager.shared.trackAttemptsGuesserViewed(
                    meetName: meetName,
                    sessionNumber: sessionNumber,
                    athleteCount: athletes.count
                )

                viewModel.calculateEstimates(athletes: athletes, athleteResults: athleteResults)
            }
        }
    }
    
    func averageIncreaseRounded(firstAttempt: Int, secondAttempt: Int) -> Int {
        return (firstAttempt + secondAttempt) / 2
    }

    private func generateAthleteNotes(estimate: AthleteAttemptEstimate) -> String {
        var notes: [String] = []

        if !estimate.snatchEstimates.isEmpty && estimate.snatchEstimates[0] > 0 {
            notes.append("\(estimate.athleteName) typically takes \(averageIncreaseRounded(firstAttempt: estimate.averageSnatchIncrease.first, secondAttempt: estimate.averageSnatchIncrease.second))kg jumps in the Snatch, \(Int(estimate.snatchMakeRate * 100))% opener make rate")
        }

        if !estimate.cjEstimates.isEmpty && estimate.cjEstimates[0] > 0 {
            notes.append("They take \(averageIncreaseRounded(firstAttempt: estimate.averageCJIncrease.first, secondAttempt: estimate.averageCJIncrease.second))kg jumps in the Clean & Jerk, \(Int(estimate.cjMakeRate * 100))% opener make rate")
        }

        return notes.isEmpty ? "No historical data available" : notes.joined(separator: ". ") + "."
    }
}
