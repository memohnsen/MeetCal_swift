//
//  AllMeetResultsView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 11/2/25.
//

import SwiftUI
import Supabase
import PostHog

struct AllMeetResultsView: View {
    @ObservedObject private var viewModel = ScheduleDetailsModel()

    @State private var searchText: String = ""
    @State private var isLoading: Bool = false
    @State private var searchResults: [String] = []

    var body: some View {
        NavigationStack{
            ZStack {
                if searchText.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("Search for an athlete")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Enter a name to view their meet history")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else if isLoading {
                    ProgressView("Searching...")
                } else if viewModel.error != nil {
                    VStack {
                        Text("Error loading athletes")
                            .font(.headline)
                        Text("Try searching again")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding()
                    }
                } else if searchResults.isEmpty {
                    Text("No athletes found")
                        .foregroundColor(.secondary)
                } else {
                    List{
                        ForEach(searchResults, id: \.self) { athleteName in
                            NavigationLink(destination: MeetResultsView(name: athleteName)) {
                                Text(athleteName)
                            }
                            .simultaneousGesture(TapGesture().onEnded {
                                AnalyticsManager.shared.trackAthleteHistoryViewed(athleteName: athleteName)
                            })
                        }
                    }
                }
            }
            .navigationTitle("Meet Results")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, placement: .automatic, prompt: "Search for an athlete")
            .onChange(of: searchText) { oldValue, newValue in
                Task {
                    try? await Task.sleep(nanoseconds: 500_000_000) 

                    if searchText == newValue && newValue.count >= 3 {
                        await performSearch(query: newValue)
                    } else if newValue.isEmpty || newValue.count < 3 {
                        searchResults = []
                    }
                }
            }
            .task {
                AnalyticsManager.shared.trackScreenView("All Meet Results")
            }
        }
    }

    private func performSearch(query: String) async {
        isLoading = true
        searchResults = []

        await viewModel.searchAthletesByName(query: query)

        // Extract unique names from results
        let uniqueNames = Array(Set(viewModel.athleteResults.map { $0.name })).sorted()
        searchResults = uniqueNames

        // Track the search
        AnalyticsManager.shared.trackAthleteHistorySearched(query: query, resultsCount: uniqueNames.count)

        isLoading = false
    }
}
