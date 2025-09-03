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
        Saved(id: 2, date: "September 9, 2025", savedSession: [
            .init(platform: "Red", weightClass: "88kg", weighInTime: "10:00 AM EST", startTime: "12:00 PM EST", athleteName: "Alexander Nordstrom")
        ]),
        Saved(id: 1, date: "September 9, 2025", savedSession: [
            .init(platform: "Blue", weightClass: "60kg", weighInTime: "8:00 AM EST", startTime: "10:00 AM EST", athleteName: "Amber Hapken")
        ]),
    ]
    
    var body: some View {
        ScrollView {
            Divider()
                .padding(.vertical, 8)
            
            ForEach(sessions) { session in
                ForEach(session.savedSession) { group in
                    NavigationLink(destination: ScheduleView()) {
                        VStack(alignment: .leading) {
                            Text("Session \(session.id) • \(session.date)")
                                .padding(.bottom, 6)
                                .font(.headline)
                                .bold()
                            
                            HStack {
                                Text("Weigh-In: \(group.weighInTime)")
                                Text("Start: \(group.startTime)")
                            }
                            .padding(.bottom, 6)
                            .font(.system(size: 14))
                            .secondaryText()
                            
                            HStack {
                                Platform(text: group.platform)
                            
                                Text(group.weightClass)
                                    .padding(.leading, 8)
                                    .secondaryText()
                            }
                            .padding(.bottom, 6)
                            
                            if let name = group.athleteName {
                                Divider()
                                
                                Text("Athlete:")
                                    .secondaryText()
                                    .padding(.vertical, 6)
                                
                                Text(name)
                                    .bold()
                                    .padding(.bottom, 6)
                            }
                        }
                        .padding()
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 230)
            .background(.white)
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.vertical, 6)
            .foregroundStyle(.black)
        }
    }
}

#Preview {
    SavedView()
}

