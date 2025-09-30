//
//  ScheduleView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/1/25.
//

import SwiftUI
import RevenueCat
import RevenueCatUI

struct SavedView: View {
    @AppStorage("selectedMeet") private var selectedMeet = ""
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = SavedViewModel()
    @StateObject private var customerManager = CustomerInfoManager()
    @State private var showPaywall = false
    @State private var navigateToSchedule = false
    @State private var navigateToPaywall = false

    var saved: [SessionsRow] { viewModel.saved }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack {
                        ForEach(saved) { session in
                            NavigationLink(destination:
                                            ScheduleDetailsView(
                                                meet: selectedMeet,
                                                date: .now,
                                                sessionNum: session.session_number,
                                                platformColor: session.platform,
                                                weightClass: session.weight_class,
                                                startTime: session.start_time)) {
                                VStack(alignment: .leading) {
                                    Text("Session \(String(session.session_number)) • Fill date here")
                                        .padding(.bottom, 6)
                                        .foregroundStyle(colorScheme == .light ? .black : .white)
                                        .font(.headline)
                                        .bold()
                                    
                                    HStack {
                                        Text("Start: \(session.start_time)")
                                    }
                                    .padding(.bottom, 6)
                                    .font(.system(size: 14))
                                    .foregroundStyle(colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)

                                    HStack {
                                        Platform(text: session.platform)
                                    
                                        Text(session.weight_class)
                                            .padding(.leading, 8)
                                            .foregroundStyle(colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                                    }
                                    .padding(.bottom, 6)
                                    
                                    if let athleteNames = session.athlete_names, !athleteNames.isEmpty {
                                        Divider()

                                        Text("Athlete:")
                                            .foregroundStyle(colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                                            .padding(.vertical, 6)

                                        ForEach(athleteNames, id: \.self) { name in
                                            Text(name)
                                                .bold()
                                                .foregroundStyle(colorScheme == .light ? .black : .white)
                                                .padding(.bottom, 6)
                                        }
                                    }
                                }
                            }
                                                .padding(.vertical)
                        }
                        .frame(maxWidth: .infinity)
                        .background(colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                        .foregroundStyle(.black)
                    }
                    .padding(.top, 8)
                    .toolbar{
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                Task {
                                    await customerManager.fetchCustomerInfo()
                                    if customerManager.hasProAccess == true {
                                        navigateToSchedule = true
                                    } else {
                                        navigateToPaywall = true
                                    }
                                }
                            } label: {
                                Image(systemName: "plus")
                            }
                            .navigationDestination(isPresented: $navigateToSchedule) {
                                ScheduleView()
                            }
                            .sheet(isPresented: $navigateToPaywall) {
                                PaywallView()
                            }
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
                .refreshable{
                    await viewModel.loadSaved(meet: selectedMeet)
                }
            }
            .task {
                await viewModel.loadSaved(meet: selectedMeet)
            }

        }
    }
}

#Preview {
    SavedView()
}

