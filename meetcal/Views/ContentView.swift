//
//  ContentView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/1/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var search = ""
    var body: some View {
        TabView{
//            ScheduleView()
//                .tabItem{
//                    Label("Schedule", systemImage: "calendar")
//                }
//            SavedView()
//                .tabItem{
//                    Label("Saved", systemImage: "bookmark.fill")
//                }
//            StartListView()
//                .tabItem{
//                    Label("Start List", systemImage: "list.bullet")
//                }
//            SponsorView()
//                .tabItem{
//                    Label("Sponsors", systemImage: "star.fill")
//                }
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
    }
}

#Preview {
    ContentView()
}
