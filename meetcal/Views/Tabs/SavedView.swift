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
    @State private var showPaywall = false

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
                                    
                                    if session.athlete_names.count != 0 {
                                        Divider()
                                        
                                        Text("Athlete:")
                                            .foregroundStyle(colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                                            .padding(.vertical, 6)
                                        
                                        ForEach(session.athlete_names, id: \.self) { name in
                                            Text(name)
                                                .bold()
                                                .foregroundStyle(colorScheme == .light ? .black : .white)
                                                .padding(.bottom, 6)
                                        }
                                    }
                                }
                                .padding()
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
                                .presentPaywallIfNeeded(
                                    requiredEntitlementIdentifier: "default",
                                    purchaseCompleted: { customerInfo in
                                        print("Purchase completed: \(customerInfo.entitlements)")
                                    },
                                    restoreCompleted: { customerInfo in
                                        print("Purchases restored: \(customerInfo.entitlements)")
                                    }
                                )
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

