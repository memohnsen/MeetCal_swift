//
//  WLWrapped.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 10/4/25.
//

import SwiftUI
import Supabase
import FoundationModels
import PostHog

struct WLWrapped: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = WrappedModel()

    @State private var searchText: String = ""
    @State private var roastedClicked: Bool = false
    @State private var roastText: String = ""
    @State private var isGenerating: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var hasSearched: Bool = false
    @State private var shareImage: UIImage?

    var athleteResults: [AthleteResults] { viewModel.athleteResults }
    
    var bestSnatchThisYear: Int {
        let allSnatches = viewModel.currentYearResults.compactMap { result in
            result.snatch_best > 0 ? Int(result.snatch_best) : nil
        }
        return allSnatches.max() ?? 0
    }
    
    var bestSnatchPastYear: Int {
        let allSnatches = viewModel.previousYearResults.compactMap { result in
            result.snatch_best > 0 ? Int(result.snatch_best) : nil
        }
        return allSnatches.max() ?? 0
    }
    
    private func snatchPounds(lift: Int) -> Double {
       return Double(lift) * 2.2
    }
    
    var bestCJThisYear: Int {
        let allCJs = viewModel.currentYearResults.compactMap { result in
            result.cj_best > 0 ? Int(result.cj_best) : nil
        }
        return allCJs.max() ?? 0
    }
    
    var bestCJPastYear: Int {
        let allCJs = viewModel.previousYearResults.compactMap { result in
            result.cj_best > 0 ? Int(result.cj_best) : nil
        }
        return allCJs.max() ?? 0
    }
    
    private func cjPounds(lift: Int) -> Double {
       return Double(lift) * 2.2
    }
    
    func makeRateThisYear() -> (snatch1Rate: Double, snatch2Rate: Double, snatch3Rate: Double, cj1Rate: Double, cj2Rate: Double, cj3Rate: Double, countSnatch1: Int, countSnatch2: Int, countSnatch3: Int, countCJ1: Int, countCJ2: Int, countCJ3: Int, snatch1Makes: Int, snatch2Makes: Int, snatch3Makes: Int, cj1Makes: Int, cj2Makes: Int, cj3Makes: Int, snatchAverage: Double, cjAverage: Double, totalRate: Double) {
        
        let countSnatch1 = viewModel.currentYearResults.count
        let countSnatch2 = viewModel.currentYearResults.count
        let countSnatch3 = viewModel.currentYearResults.count
        let countCJ1 = viewModel.currentYearResults.count
        let countCJ2 = viewModel.currentYearResults.count
        let countCJ3 = viewModel.currentYearResults.count
        
        let snatch1Makes = viewModel.currentYearResults.filter { $0.snatch1 > 0 }.count
        let snatch2Makes = viewModel.currentYearResults.filter { $0.snatch2 > 0 }.count
        let snatch3Makes = viewModel.currentYearResults.filter { $0.snatch3 > 0 }.count
        let cj1Makes = viewModel.currentYearResults.filter { $0.cj1 > 0 }.count
        let cj2Makes = viewModel.currentYearResults.filter { $0.cj2 > 0 }.count
        let cj3Makes = viewModel.currentYearResults.filter { $0.cj3 > 0 }.count
        
        let snatch1Rate = countSnatch1 > 0 ? (Double(snatch1Makes) / Double(countSnatch1)) * 100 : 0.0
        let snatch2Rate = countSnatch2 > 0 ? (Double(snatch2Makes) / Double(countSnatch2)) * 100 : 0.0
        let snatch3Rate = countSnatch3 > 0 ? (Double(snatch3Makes) / Double(countSnatch3)) * 100 : 0.0
        let cj1Rate = countCJ1 > 0 ? (Double(cj1Makes) / Double(countCJ1)) * 100 : 0.0
        let cj2Rate = countCJ2 > 0 ? (Double(cj2Makes) / Double(countCJ2)) * 100 : 0.0
        let cj3Rate = countCJ3 > 0 ? (Double(cj3Makes) / Double(countCJ3)) * 100 : 0.0
        
        let snatchAverage = (snatch1Rate + snatch2Rate + snatch3Rate) / 3
        let cjAverage = (cj1Rate + cj2Rate + cj3Rate) / 3
        
        let totalRate = (snatchAverage + cjAverage) / 2

        return (snatch1Rate, snatch2Rate, snatch3Rate, cj1Rate, cj2Rate, cj3Rate, countSnatch1, countSnatch2, countSnatch3, countCJ1, countCJ2, countCJ3, snatch1Makes, snatch2Makes, snatch3Makes, cj1Makes, cj2Makes, cj3Makes, snatchAverage, cjAverage, totalRate)
    }
    
    func makeRatePastYear() -> (snatch1Rate: Double, snatch2Rate: Double, snatch3Rate: Double, cj1Rate: Double, cj2Rate: Double, cj3Rate: Double, countSnatch1: Int, countSnatch2: Int, countSnatch3: Int, countCJ1: Int, countCJ2: Int, countCJ3: Int, snatch1Makes: Int, snatch2Makes: Int, snatch3Makes: Int, cj1Makes: Int, cj2Makes: Int, cj3Makes: Int, snatchAverage: Double, cjAverage: Double, totalRate: Double) {
        
        let countSnatch1 = viewModel.previousYearResults.count
        let countSnatch2 = viewModel.previousYearResults.count
        let countSnatch3 = viewModel.previousYearResults.count
        let countCJ1 = viewModel.previousYearResults.count
        let countCJ2 = viewModel.previousYearResults.count
        let countCJ3 = viewModel.previousYearResults.count
        
        let snatch1Makes = viewModel.previousYearResults.filter { $0.snatch1 > 0 }.count
        let snatch2Makes = viewModel.previousYearResults.filter { $0.snatch2 > 0 }.count
        let snatch3Makes = viewModel.previousYearResults.filter { $0.snatch3 > 0 }.count
        let cj1Makes = viewModel.previousYearResults.filter { $0.cj1 > 0 }.count
        let cj2Makes = viewModel.previousYearResults.filter { $0.cj2 > 0 }.count
        let cj3Makes = viewModel.previousYearResults.filter { $0.cj3 > 0 }.count
        
        let snatch1Rate = countSnatch1 > 0 ? (Double(snatch1Makes) / Double(countSnatch1)) * 100 : 0.0
        let snatch2Rate = countSnatch2 > 0 ? (Double(snatch2Makes) / Double(countSnatch2)) * 100 : 0.0
        let snatch3Rate = countSnatch3 > 0 ? (Double(snatch3Makes) / Double(countSnatch3)) * 100 : 0.0
        let cj1Rate = countCJ1 > 0 ? (Double(cj1Makes) / Double(countCJ1)) * 100 : 0.0
        let cj2Rate = countCJ2 > 0 ? (Double(cj2Makes) / Double(countCJ2)) * 100 : 0.0
        let cj3Rate = countCJ3 > 0 ? (Double(cj3Makes) / Double(countCJ3)) * 100 : 0.0
        
        let snatchAverage = (snatch1Rate + snatch2Rate + snatch3Rate) / 3
        let cjAverage = (cj1Rate + cj2Rate + cj3Rate) / 3
        
        let totalRate = (snatchAverage + cjAverage) / 2

        return (snatch1Rate, snatch2Rate, snatch3Rate, cj1Rate, cj2Rate, cj3Rate, countSnatch1, countSnatch2, countSnatch3, countCJ1, countCJ2, countCJ3, snatch1Makes, snatch2Makes, snatch3Makes, cj1Makes, cj2Makes, cj3Makes, snatchAverage, cjAverage, totalRate)
    }
    
    private var bestLift: String {
        if makeRateThisYear().snatchAverage > makeRateThisYear().cjAverage {
           return "Snatch"
        } else {
           return "Clean & Jerk"
        }
    }
    
    private func changeInMakeRate(thisYear: Double, pastYear: Double) -> Double {
        guard pastYear != 0 else { return thisYear > 0 ? 100.0 : 0.0 }
        return ((thisYear - pastYear) / pastYear) * 100
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack {
                    ScrollView {
                        if searchText == "" {
                            VStack(spacing: 20) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 60))
                                    .foregroundStyle(.blue)
                                Text("Search for an athlete to see their Weightlifting Wrapped stats")
                                    .font(.title2)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                        } else if viewModel.currentYearResults.count > 0 && viewModel.previousYearResults.count > 0 {
                            Grid {
                                GridRow {
                                    HStack {
                                        VStack {
                                            Text("Meet Count")
                                                .bold()
                                                .padding(.bottom, 2)
                                            Text("\(viewModel.currentYearResults.count)")
                                                .padding(.bottom, 2)
                                            
                                            if viewModel.currentYearResults.count > viewModel.previousYearResults.count {
                                                Text("+\(viewModel.currentYearResults.count - viewModel.previousYearResults.count)")
                                                    .foregroundStyle(.green)
                                            } else if viewModel.currentYearResults.count < viewModel.previousYearResults.count {
                                                Text("\(viewModel.currentYearResults.count - viewModel.previousYearResults.count)")
                                                    .foregroundStyle(.red)
                                            } else {
                                                Text("No Change")
                                            }
                                        }
                                    }
                                    .cardStyling()
                                    
                                    HStack {
                                        VStack {
                                            Text("Make Rate")
                                                .bold()
                                                .padding(.bottom, 2)
                                            Text("\(Int(makeRateThisYear().totalRate))%")
                                                .padding(.bottom, 2)
                                            
                                            if changeInMakeRate(thisYear: makeRateThisYear().totalRate, pastYear: makeRatePastYear().totalRate) > 0 {
                                                Text("+\(Int(changeInMakeRate(thisYear: makeRateThisYear().totalRate, pastYear: makeRatePastYear().totalRate)))%")
                                                    .foregroundStyle(.green)
                                            } else if changeInMakeRate(thisYear: makeRateThisYear().totalRate, pastYear: makeRatePastYear().totalRate) < 0 {
                                                Text("\(Int(changeInMakeRate(thisYear: makeRateThisYear().totalRate, pastYear: makeRatePastYear().totalRate)))%")
                                                    .foregroundStyle(.red)
                                            } else {
                                                Text("No Change")
                                            }
                                        }
                                    }
                                    .cardStyling()
                                }
                                GridRow {
                                    HStack {
                                        VStack {
                                            Text("Best Snatch")
                                                .bold()
                                                .padding(.bottom, 2)
                                            Text("\(bestSnatchThisYear)kg / \(Int(snatchPounds(lift: bestSnatchThisYear)))lbs")
                                                .padding(.bottom, 2)
                                            
                                            if bestSnatchThisYear - bestSnatchPastYear > 0 {
                                                Text("+\(Int(bestSnatchThisYear - bestSnatchPastYear))kg / +\(Int(snatchPounds(lift: bestSnatchThisYear)) - Int(snatchPounds(lift: bestSnatchPastYear)))lbs")
                                                    .foregroundStyle(.green)
                                            } else if bestSnatchThisYear - bestSnatchPastYear < 0 {
                                                Text("\(Int(bestSnatchThisYear - bestSnatchPastYear))kg / \(Int(snatchPounds(lift: bestSnatchThisYear)) - Int(snatchPounds(lift: bestSnatchPastYear)))lbs")
                                                    .foregroundStyle(.red)
                                            } else {
                                                Text("No Change")
                                            }
                                        }
                                    }
                                    .cardStyling()
                                    
                                    HStack {
                                        VStack {
                                            Text("Best CJ")
                                                .bold()
                                                .padding(.bottom, 2)
                                            Text("\(bestCJThisYear)kg / \(Int(cjPounds(lift: bestCJThisYear)))lbs")
                                                .padding(.bottom, 2)
                                            
                                            if bestCJThisYear - bestCJPastYear > 0 {
                                                Text("+\(Int(bestCJThisYear - bestCJPastYear))kg / +\(Int(snatchPounds(lift: bestCJThisYear)) - Int(snatchPounds(lift: bestCJPastYear)))lbs")
                                                    .foregroundStyle(.green)
                                            } else if bestCJThisYear - bestCJPastYear < 0 {
                                                Text("\(Int(bestCJThisYear - bestCJPastYear))kg / \(Int(snatchPounds(lift: bestCJThisYear)) - Int(snatchPounds(lift: bestCJPastYear)))lbs")
                                                    .foregroundStyle(.red)
                                            } else {
                                                Text("No Change")
                                            }
                                        }
                                    }
                                    .cardStyling()
                                }
                                GridRow {
                                    HStack {
                                        VStack {
                                            Text("Snatch Make Rate")
                                                .bold()
                                                .padding(.bottom, 2)
                                            Text("\(Int(makeRateThisYear().snatchAverage))%")
                                                .padding(.bottom, 2)
                                            
                                            if changeInMakeRate(thisYear: makeRateThisYear().snatchAverage, pastYear: makeRatePastYear().snatchAverage) > 0 {
                                                Text("+\(Int(changeInMakeRate(thisYear: makeRateThisYear().snatchAverage, pastYear: makeRatePastYear().snatchAverage)))%")
                                                    .foregroundStyle(.green)
                                            } else if changeInMakeRate(thisYear: makeRateThisYear().snatchAverage, pastYear: makeRatePastYear().snatchAverage) < 0 {
                                                Text("\(Int(changeInMakeRate(thisYear: makeRateThisYear().snatchAverage, pastYear: makeRatePastYear().snatchAverage)))%")
                                                    .foregroundStyle(.red)
                                            } else {
                                                Text("No Change")
                                            }
                                        }
                                    }
                                    .cardStyling()
                                    
                                    HStack {
                                        VStack {
                                            Text("CJ Make Rate")
                                                .bold()
                                                .padding(.bottom, 2)
                                            Text("\(Int(makeRateThisYear().cjAverage))%")
                                                .padding(.bottom, 2)
                                            
                                            if changeInMakeRate(thisYear: makeRateThisYear().cjAverage, pastYear: makeRatePastYear().cjAverage) > 0 {
                                                Text("+\(Int(changeInMakeRate(thisYear: makeRateThisYear().cjAverage, pastYear: makeRatePastYear().cjAverage)))%")
                                                    .foregroundStyle(.green)
                                            } else if changeInMakeRate(thisYear: makeRateThisYear().cjAverage, pastYear: makeRatePastYear().cjAverage) < 0 {
                                                Text("\(Int(changeInMakeRate(thisYear: makeRateThisYear().cjAverage, pastYear: makeRatePastYear().cjAverage)))%")
                                                    .foregroundStyle(.red)
                                            } else {
                                                Text("No Change")
                                            }
                                        }
                                    }
                                    .cardStyling()
                                }
                                GridRow {
                                    HStack {
                                        VStack {
                                            Text("Best Lift")
                                                .bold()
                                                .padding(.bottom, 2)
                                            Text("\(bestLift)")
                                        }
                                    }
                                    .cardStyling()
                                    
                                    HStack {
                                        VStack {
                                            Text("National Ranking")
                                                .bold()
                                                .padding(.bottom, 2)
                                            
                                            if let weightClass = viewModel.currentYearResults.last?.age,
                                               let ranking = viewModel.calculateNationalRanking(for: searchText, in: weightClass, year: 2025) {
                                                Text(ordinalString(for: ranking))
                                                    .padding(.bottom, 2)
                                            } else {
                                                Text("N/A")
                                                    .padding(.bottom, 2)
                                            }
                                            
                                            //                                        if let weightClass = viewModel.currentYearResults.last?.age,
                                            //                                           let currentRanking = viewModel.calculateNationalRanking(for: searchText, in: weightClass, year: 2025),
                                            //                                           let pastRanking = viewModel.calculateNationalRanking(for: searchText, in: weightClass, year: 2024) {
                                            //                                            let rankingChange = pastRanking - currentRanking
                                            //
                                            //                                            if rankingChange > 0 {
                                            //                                                Text("+\(rankingChange) spots")
                                            //                                                    .foregroundStyle(.green)
                                            //                                            } else if rankingChange < 0 {
                                            //                                                Text("\(rankingChange) spots")
                                            //                                                    .foregroundStyle(.red)
                                            //                                            } else {
                                            //                                                Text("No Change")
                                            //                                            }
                                            //                                        } else {
                                            //                                            Text("N/A")
                                            //                                        }
                                        }
                                    }
                                    .cardStyling()
                                }
                                
                            }
                            
                            if roastedClicked {
                                VStack(alignment: .leading) {
                                    if isGenerating {
                                        HStack {
                                            Spacer()
                                            ProgressView()
                                                .padding()
                                            Spacer()
                                        }
                                    } else {
                                        Text(roastText)
                                            .padding()
                                    }
                                }
                                .cardStyling()
                            } else {
                                HStack{
                                    if isGenerating {
                                        ProgressView()
                                            .tint(.white)
                                        Text("Generating Roast...")
                                    } else {
                                        Text("Get Roasted")
                                    }
                                }
                                .frame(maxWidth: .infinity, minHeight: 40)
                                .foregroundStyle(.white)
                                .background(.blue)
                                .cornerRadius(32)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 32)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                                .padding(.top, 4)
                                .onTapGesture {
                                    Task {
                                        await generateRoast()
                                    }
                                }
                            }
                        } else {
                            VStack(spacing: 20) {
                                Image(systemName: "person.fill.questionmark")
                                    .font(.system(size: 60))
                                    .foregroundStyle(.gray)
                                Text("No data available for \"\(searchText)\" in 2024-2025")
                                    .font(.title2)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                Text("Try searching for a different athlete or check the spelling")
                                    .font(.body)
                                    .foregroundStyle(.tertiary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationTitle("Weightlifting Wrapped")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.visible, for: .tabBar)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for an athlete...")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        shareImage = captureSnapshot()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .disabled(viewModel.currentYearResults.isEmpty)
                }
            }
            .sheet(item: Binding(
                get: { shareImage.map { ShareableImage(image: $0) } },
                set: { _ in shareImage = nil }
            )) { shareable in
                ShareSheet(items: [shareable.image])
                    .presentationDetents([.medium, .large])
            }
            .task {
                AnalyticsManager.shared.trackScreenView("Weightlifting Wrapped")
                await viewModel.loadResults(name: "")
            }
            .onChange(of: searchText) { _, newValue in
                Task {
                    try? await Task.sleep(nanoseconds: 300_000_000)

                    if searchText == newValue && !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        roastedClicked = false
                        roastText = ""
                        isGenerating = false
                        hasSearched = true

                        AnalyticsManager.shared.trackAthleteSearched(
                            athleteName: newValue.trimmingCharacters(in: .whitespacesAndNewlines),
                            found: false // Will update after results load
                        )

                        await viewModel.loadResults(name: newValue.trimmingCharacters(in: .whitespacesAndNewlines))

                        let found = viewModel.currentYearResults.count > 0
                        AnalyticsManager.shared.trackAthleteSearched(
                            athleteName: newValue.trimmingCharacters(in: .whitespacesAndNewlines),
                            found: found
                        )

                        if let weightClass = viewModel.currentYearResults.first?.age {
                            await viewModel.loadWeightClassRankings(age: weightClass)
                        }
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func generateRoast() async {
        isGenerating = true
        roastText = ""

        let model = SystemLanguageModel.default
        

        switch model.availability {
        case .available:
            break
        case .unavailable(let reason):
            errorMessage = "Apple Intelligence is unavailable: \(reason)"
            showError = true
            isGenerating = false
            return
        }

        let stats = makeRateThisYear()
        let pastStats = makeRatePastYear()

        let prompt = """
        You are a witty olympic weightlifting coach giving a humorous year-in-review roast to an athlete named \(searchText). Be playful and sarcastic, and a little mean. Use their stats to create funny observations.

        Stats for this year:
        - Competition Count: \(viewModel.currentYearResults.count)
        - Overall make rate: \(Int(stats.totalRate))%
        - Snatch make rate: \(Int(stats.snatchAverage))%
        - Clean & Jerk make rate: \(Int(stats.cjAverage))%
        - Best snatch: \(bestSnatchThisYear)kg
        - Best clean & jerk: \(bestCJThisYear)kg
        - Best lift type: \(bestLift)

        Comparison to last year:
        - Competition Count change: \(viewModel.currentYearResults.count - viewModel.previousYearResults.count)
        - Make rate change: \(Int(changeInMakeRate(thisYear: stats.totalRate, pastYear: pastStats.totalRate)))%
        - Best snatch improvement: \(bestSnatchThisYear - bestSnatchPastYear)kg
        - Best C&J improvement: \(bestCJThisYear - bestCJPastYear)kg

        Write a short, funny roast (3-4 sentences) about their performance this year. Focus on their strengths and weaknesses with humor. Keep it under 100 words.
        """

        let session = LanguageModelSession(instructions: prompt)

        AnalyticsManager.shared.trackScreenView("Roast Generation")

        do {
            let response = try await session.respond(to: prompt)
            roastText = response.content
            roastedClicked = true

            PostHogSDK.shared.capture("roast_generated", properties: [
                "athlete_name": searchText,
                "competitions_count": viewModel.currentYearResults.count,
                "make_rate": Int(stats.totalRate)
            ])
        } catch {
            errorMessage = "Failed to generate roast: \(error.localizedDescription)"
            showError = true

            PostHogSDK.shared.capture("roast_generation_failed", properties: [
                "error": error.localizedDescription,
                "athlete_name": searchText
            ])
        }

        isGenerating = false
    }

    private func ordinalString(for number: Int) -> String {
        let suffix: String
        switch number {
        case 1: suffix = "st"
        case 2: suffix = "nd"
        case 3: suffix = "rd"
        default: suffix = "th"
        }
        return "\(number)\(suffix)"
    }

    @MainActor
    private func captureSnapshot() -> UIImage? {
        let stats = makeRateThisYear()
        let pastStats = makeRatePastYear()
        let athleteName = searchText
        let currentCount = viewModel.currentYearResults.count
        let previousCount = viewModel.previousYearResults.count
        let snatchThisYear = bestSnatchThisYear
        let snatchPastYear = bestSnatchPastYear
        let cjThisYear = bestCJThisYear
        let cjPastYear = bestCJPastYear
        let lift = bestLift
        let weightClass = viewModel.currentYearResults.last?.age
        let ranking = weightClass != nil ? viewModel.calculateNationalRanking(for: searchText, in: weightClass!, year: 2025) : nil

        let view = VStack(spacing: 0) {
            Text(athleteName.capitalized)
                .font(.largeTitle)
                .bold()
                .padding(.top)

            Text("Weightlifting Wrapped 2025")
                .font(.headline)
                .foregroundStyle(.secondary)
                .padding(.bottom)

            Grid {
                GridRow {
                    HStack {
                        VStack {
                            Text("Meet Count")
                                .bold()
                                .padding(.bottom, 2)
                            Text("\(currentCount)")
                                .padding(.bottom, 2)

                            if currentCount > previousCount {
                                Text("+\(currentCount - previousCount)")
                                    .foregroundStyle(.green)
                            } else if currentCount < previousCount {
                                Text("\(currentCount - previousCount)")
                                    .foregroundStyle(.red)
                            } else {
                                Text("No Change")
                            }
                        }
                    }
                    .cardStyling()

                    HStack {
                        VStack {
                            Text("Make Rate")
                                .bold()
                                .padding(.bottom, 2)
                            Text("\(Int(stats.totalRate))%")
                                .padding(.bottom, 2)

                            if changeInMakeRate(thisYear: stats.totalRate, pastYear: pastStats.totalRate) > 0 {
                                Text("+\(Int(changeInMakeRate(thisYear: stats.totalRate, pastYear: pastStats.totalRate)))%")
                                    .foregroundStyle(.green)
                            } else if changeInMakeRate(thisYear: stats.totalRate, pastYear: pastStats.totalRate) < 0 {
                                Text("\(Int(changeInMakeRate(thisYear: stats.totalRate, pastYear: pastStats.totalRate)))%")
                                    .foregroundStyle(.red)
                            } else {
                                Text("No Change")
                            }
                        }
                    }
                    .cardStyling()
                }
                GridRow {
                    HStack {
                        VStack {
                            Text("Best Snatch")
                                .bold()
                                .padding(.bottom, 2)
                            Text("\(snatchThisYear)kg / \(Int(snatchPounds(lift: snatchThisYear)))lbs")
                                .padding(.bottom, 2)

                            if snatchThisYear - snatchPastYear > 0 {
                                Text("+\(Int(snatchThisYear - snatchPastYear))kg / +\(Int(snatchPounds(lift: snatchThisYear)) - Int(snatchPounds(lift: snatchPastYear)))lbs")
                                    .foregroundStyle(.green)
                            } else if snatchThisYear - snatchPastYear < 0 {
                                Text("\(Int(snatchThisYear - snatchPastYear))kg / \(Int(snatchPounds(lift: snatchThisYear)) - Int(snatchPounds(lift: snatchPastYear)))lbs")
                                    .foregroundStyle(.red)
                            } else {
                                Text("No Change")
                            }
                        }
                    }
                    .cardStyling()

                    HStack {
                        VStack {
                            Text("Best CJ")
                                .bold()
                                .padding(.bottom, 2)
                            Text("\(cjThisYear)kg / \(Int(cjPounds(lift: cjThisYear)))lbs")
                                .padding(.bottom, 2)

                            if cjThisYear - cjPastYear > 0 {
                                Text("+\(Int(cjThisYear - cjPastYear))kg / +\(Int(snatchPounds(lift: cjThisYear)) - Int(snatchPounds(lift: cjPastYear)))lbs")
                                    .foregroundStyle(.green)
                            } else if cjThisYear - cjPastYear < 0 {
                                Text("\(Int(cjThisYear - cjPastYear))kg / \(Int(snatchPounds(lift: cjThisYear)) - Int(snatchPounds(lift: cjPastYear)))lbs")
                                    .foregroundStyle(.red)
                            } else {
                                Text("No Change")
                            }
                        }
                    }
                    .cardStyling()
                }
                GridRow {
                    HStack {
                        VStack {
                            Text("Snatch Make Rate")
                                .bold()
                                .padding(.bottom, 2)
                            Text("\(Int(stats.snatchAverage))%")
                                .padding(.bottom, 2)

                            if changeInMakeRate(thisYear: stats.snatchAverage, pastYear: pastStats.snatchAverage) > 0 {
                                Text("+\(Int(changeInMakeRate(thisYear: stats.snatchAverage, pastYear: pastStats.snatchAverage)))%")
                                    .foregroundStyle(.green)
                            } else if changeInMakeRate(thisYear: stats.snatchAverage, pastYear: pastStats.snatchAverage) < 0 {
                                Text("\(Int(changeInMakeRate(thisYear: stats.snatchAverage, pastYear: pastStats.snatchAverage)))%")
                                    .foregroundStyle(.red)
                            } else {
                                Text("No Change")
                            }
                        }
                    }
                    .cardStyling()

                    HStack {
                        VStack {
                            Text("CJ Make Rate")
                                .bold()
                                .padding(.bottom, 2)
                            Text("\(Int(stats.cjAverage))%")
                                .padding(.bottom, 2)

                            if changeInMakeRate(thisYear: stats.cjAverage, pastYear: pastStats.cjAverage) > 0 {
                                Text("+\(Int(changeInMakeRate(thisYear: stats.cjAverage, pastYear: pastStats.cjAverage)))%")
                                    .foregroundStyle(.green)
                            } else if changeInMakeRate(thisYear: stats.cjAverage, pastYear: pastStats.cjAverage) < 0 {
                                Text("\(Int(changeInMakeRate(thisYear: stats.cjAverage, pastYear: pastStats.cjAverage)))%")
                                    .foregroundStyle(.red)
                            } else {
                                Text("No Change")
                            }
                        }
                    }
                    .cardStyling()
                }
                GridRow {
                    HStack {
                        VStack {
                            Text("Best Lift")
                                .bold()
                                .padding(.bottom, 2)
                            Text("\(lift)")
                        }
                    }
                    .cardStyling()

                    HStack {
                        VStack {
                            Text("National Ranking")
                                .bold()
                                .padding(.bottom, 2)

                            if let ranking = ranking {
                                Text(ordinalString(for: ranking))
                                    .padding(.bottom, 2)
                            } else {
                                Text("N/A")
                                    .padding(.bottom, 2)
                            }
                        }
                    }
                    .cardStyling()
                }
            }
            .padding()
        }
        .frame(width: 400)
        .background(Color(.systemGroupedBackground))

        let renderer = ImageRenderer(content: view)
        renderer.scale = UIScreen.main.scale

        guard let image = renderer.uiImage else {
            print("ImageRenderer failed to create uiImage")
            return nil
        }

        print("Successfully created image with size: \(image.size)")
        return image
    }
}

struct ShareableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        controller.excludedActivityTypes = []

        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    WLWrapped()
}
