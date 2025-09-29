//
//  ContentView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/1/25.
//

import SwiftUI
import SwiftData
import Clerk

struct ContentView: View {
    @State private var search = ""
    
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
    }
}

#Preview {
    ContentView()
}
