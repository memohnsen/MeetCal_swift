//
//  ContentView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/1/25.
//

import SwiftUI
import SwiftData
import Clerk
import UserNotifications

struct ContentView: View {
    @State private var search = ""
    @State private var selectedTab: String = "Schedule"
    @StateObject private var customerManager = CustomerInfoManager()
    @State private var showReleaseNotes = false

    private let releaseNotesVersionKey = "meetcal.releaseNotes.lastSeenVersion"
    private var currentVersion: String {
        Bundle.main.appVersionString
    }

    var body: some View {
        TabView(selection: $selectedTab){
            Tab("Schedule", systemImage: "calendar", value: "Schedule") {
                ScheduleView()
            }
            Tab("Saved", systemImage: "bookmark.fill", value: "Saved") {
                SavedView()
            }
            Tab("Sponsors", systemImage: "star.fill", value: "Sponsors") {
                SponsorView()
            }
            Tab("Search", systemImage: "magnifyingglass", value: "Start List", role: .search) {
                NavigationStack {
                    StartListView()
                }
                .searchable(text: $search)
            }
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            if !oldValue.isEmpty && oldValue != newValue {
                AnalyticsManager.shared.trackTabSwitched(fromTab: oldValue, toTab: newValue)
            }
        }
        .onAppear{
            handleReleaseNotesIfNeeded()
            if customerManager.hasProAccess {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        print("All set!")
                    } else if let error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
        .sheet(isPresented: $showReleaseNotes, onDismiss: markReleaseNotesAsSeen) {
            ReleaseNotesSheet(
                version: currentVersion,
                entry: ReleaseNotesCatalog.entry(for: currentVersion)
            )
        }
    }

    private func handleReleaseNotesIfNeeded() {
        let lastSeenVersion = UserDefaults.standard.string(forKey: releaseNotesVersionKey)
        if lastSeenVersion != currentVersion {
            showReleaseNotes = true
        }
    }

    private func markReleaseNotesAsSeen() {
        UserDefaults.standard.set(currentVersion, forKey: releaseNotesVersionKey)
    }
}

#Preview {
    ContentView()
}
