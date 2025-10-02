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
    @StateObject private var customerManager = CustomerInfoManager()
    
    var body: some View {
        TabView{
            Tab("Schedule", systemImage: "calendar") {
                ScheduleView()
            }
            Tab("Saved", systemImage: "bookmark.fill") {
                SavedView()
            }
            Tab("Sponsors", systemImage: "star.fill") {
                SponsorView()
            }
            Tab("Search", systemImage: "magnifyingglass", role: .search) {
                NavigationStack {
                    StartListView()
                }
                .searchable(text: $search)
            }
        }
        .onAppear{
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
    }
}

#Preview {
    ContentView()
}
