//
//  ContentView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/1/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView{
            ScheduleView()
                .tabItem{
                    Label("Schedule", systemImage: "calendar")
                }
            SavedView()
                .tabItem{
                    Label("Saved", systemImage: "bookmark.fill")
                }
            StartListView()
                .tabItem{
                    Label("Start List", systemImage: "list.bullet")
                }
            SponsorView()
                .tabItem{
                    Label("Sponsors", systemImage: "star.fill")
                }
        }
    }
}

#Preview {
    ContentView()
}
