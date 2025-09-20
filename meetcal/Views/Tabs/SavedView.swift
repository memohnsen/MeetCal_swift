//
//  ScheduleView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/1/25.
//

import SwiftUI

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

struct SavedView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = SavedViewModel()

    var saved: [SessionsRow] { viewModel.saved }
    
    let sessions: [Saved] = [
        Saved(id: 2, date: "September 9, 2025", savedSession: [
            .init(platform: "Red", weightClass: "88kg", weighInTime: "10:00 AM EST", startTime: "12:00 PM EST", athleteName: "Alexander Nordstrom")
        ]),
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack {
                        ForEach(sessions) { session in
                            ForEach(session.savedSession) { group in
                                NavigationLink(destination: ScheduleDetailsView()) {
                                    VStack(alignment: .leading) {
                                        Text("Session \(session.id) • \(session.date)")
                                            .padding(.bottom, 6)
                                            .foregroundStyle(colorScheme == .light ? .black : .white)
                                            .font(.headline)
                                            .bold()
                                        
                                        HStack {
                                            Text("Weigh-In: \(group.weighInTime)")
                                            Text("Start: \(group.startTime)")
                                        }
                                        .padding(.bottom, 6)
                                        .font(.system(size: 14))
                                        .foregroundStyle(colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)

                                        HStack {
                                            Platform(text: group.platform)
                                        
                                            Text(group.weightClass)
                                                .padding(.leading, 8)
                                                .foregroundStyle(colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                                        }
                                        .padding(.bottom, 6)
                                        
                                        if let name = group.athleteName {
                                            Divider()
                                            
                                            Text("Athlete:")
                                                .foregroundStyle(colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                                                .padding(.vertical, 6)
                                            
                                            Text(name)
                                                .bold()
                                                .foregroundStyle(colorScheme == .light ? .black : .white)
                                                .padding(.bottom, 6)
                                        }
                                    }
                                    .padding()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 230)
                        .background(colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                        .foregroundStyle(.black)
                    }
                    .padding(.top, 8)
                    .toolbar{
                        ToolbarItem(placement: .topBarLeading) {
                            Image(systemName: "plus")
                        }
                        ToolbarItem {
                            Image(systemName: "calendar")
                        }
                        ToolbarSpacer()
                        ToolbarItem {
                            Image(systemName: "trash")
                                .foregroundStyle(.red)
                        }
                    }

                }
                .navigationTitle("Saved")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

#Preview {
    SavedView()
}

