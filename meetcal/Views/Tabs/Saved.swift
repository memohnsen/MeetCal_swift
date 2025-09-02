//
//  ScheduleView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/1/25.
//

import SwiftUI

struct SavedView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack {
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            ButtonComponent(image: "plus", action: {}, title: "Create Session")
                            ButtonComponent(image: "calendar", action: {}, title: "Add to Calendar")
                        }
                        HStack {
                            ButtonComponent(image: "bookmark", action: {}, title: "Saved Warmups")
                        }
                    }
                    .padding(.horizontal)
                    
                    SavedElementsView()
                }
                .background(Color(.systemGroupedBackground))
                .navigationTitle("Saved")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

struct Saved: Identifiable {
    let id: Int
    let date: String
    let savedSession: [SavedSession]

    struct SavedSession: Identifiable {
        let id = UUID()
        let platform: String
        let weightClass: String
        let weighInTime: String
        let startTime: String
        let athleteName: String?
    }
}

struct SavedElementsView: View {
    let sessions: [Saved] = [
        Saved(id: 2, date: "8/9/2025", savedSession: [
            .init(platform: "Red", weightClass: "88kg", weighInTime: "10:00 AM", startTime: "12:00 PM", athleteName: "Alexander Nordstrom"),
            .init(platform: "Blue", weightClass: "94kg", weighInTime: "10:00 AM", startTime: "12:00 PM", athleteName: "")
        ]),
        Saved(id: 1, date: "8/9/2025", savedSession: [
            .init(platform: "Red", weightClass: "60kg", weighInTime: "8:00 AM", startTime: "10:00 AM", athleteName: "Amber Hapken"),
            .init(platform: "Blue", weightClass: "71kg", weighInTime: "8:00 AM", startTime: "10:00 AM", athleteName: "")
        ]),
    ]
    
    var body: some View {
        ScrollView {
            Divider()
                .padding(.vertical, 8)
            
            ForEach(sessions) { session in
                Section(header: Text("Session \(session.id) | \(session.date)")) {
                    ForEach(session.savedSession) { group in
                        NavigationLink(destination: ScheduleView()) {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Weigh-In: \(group.weighInTime)")
                                    Text("Start: \(group.startTime)")
                                }
                                
                                HStack {
                                    Text(group.platform)
                                        .frame(width: 40, height: 40)
                                        .padding(.horizontal, 10)
                                        .background(group.platform == "Red" ? .red : .blue)
                                        .foregroundStyle(.white)
                                        .cornerRadius(10)
                                    
                                    VStack(alignment: .leading) {
                                        Text(group.weightClass)
                                            .padding(.vertical, 2)
                                        Text("Start: 9:00am PDT")
                                            .padding(.vertical, 2)
                                    }
                                    .padding(.leading, 10)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SavedView()
}
