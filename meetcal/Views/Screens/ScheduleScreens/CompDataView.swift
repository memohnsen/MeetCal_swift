//
//  CompDataView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/13/25.
//

import SwiftUI
import RevenueCat
import RevenueCatUI

struct CompDataView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var customerManager = CustomerInfoManager()
    @State private var navigateToPaywall: Bool = false
    @State private var navigateToEventInfo: Bool = false
    @State private var navigateToTotals: Bool = false
    @State private var navigateToRecords: Bool = false
    @State private var navigateToWSO: Bool = false
    @State private var navigateToStandards: Bool = false
    @State private var navigateToRankings: Bool = false
    
    var body: some View {
        NavigationStack{
            List {
                Button {
                    navigateToEventInfo = true
                } label: {
                    HStack {
                        Text("Event Info")
                            .font(.system(size: 17))
                            .foregroundStyle(colorScheme == .light ? .black : .white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundStyle(.gray.opacity(0.8))
                        
                    }
                }
                
                Button {
                    Task {
                        if customerManager.hasProAccess == true {
                            navigateToTotals = true
                        } else {
                            navigateToPaywall = true
                        }
                    }
                } label: {
                    HStack {
                        Text("Qualifying Totals")
                            .font(.system(size: 17))
                            .foregroundStyle(colorScheme == .light ? .black : .white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundStyle(.gray.opacity(0.8))
                        
                    }
                }
                
//                    NavigationLink(destination: ScheduleView()) {
//                        Text("Weightlifting Wrapped")
//                    }

                
                Section("Records") {
                    Button {
                        Task {
                            if customerManager.hasProAccess == true {
                                navigateToRecords = true
                            } else {
                                navigateToPaywall = true
                            }
                        }
                    } label: {
                        HStack {
                            Text("American Records")
                                .font(.system(size: 17))
                                .foregroundStyle(colorScheme == .light ? .black : .white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundStyle(.gray.opacity(0.8))
                            
                        }
                    }
                    
                    Button {
                        Task {
                            if customerManager.hasProAccess == true {
                                navigateToWSO = true
                            } else {
                                navigateToPaywall = true
                            }
                        }
                    } label: {
                        HStack {
                            Text("WSO Records")
                                .font(.system(size: 17))
                                .foregroundStyle(colorScheme == .light ? .black : .white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundStyle(.gray.opacity(0.8))
                            
                        }
                    }
                    
//                    NavigationLink(destination: ScheduleView()) {
//                        Text("Adaptive Records")
//                    }
                }
                
                Section("International") {
                    Button {
                        Task {
                            if customerManager.hasProAccess == true {
                                navigateToStandards = true
                            } else {
                                navigateToPaywall = true
                            }
                        }
                    } label: {
                        HStack {
                            Text("A/B Standards")
                                .font(.system(size: 17))
                                .foregroundStyle(colorScheme == .light ? .black : .white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundStyle(.gray.opacity(0.8))
                            
                        }
                    }
                    
                    Button {
                        Task {
                            if customerManager.hasProAccess == true {
                                navigateToRankings = true
                            } else {
                                navigateToPaywall = true
                            }
                        }
                    } label: {
                        HStack {
                            Text("International Rankings")
                                .font(.system(size: 17))
                                .foregroundStyle(colorScheme == .light ? .black : .white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundStyle(.gray.opacity(0.8))
                            
                        }
                    }
                }
            }
            .navigationTitle("Competition Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .tabBar)
            .padding(.top, -10)
            .task {
                await customerManager.fetchCustomerInfo()
            }
            .navigationDestination(isPresented: $navigateToEventInfo) {
                EventInfoView()
            }
            .navigationDestination(isPresented: $navigateToTotals) {
                QualifyingTotalsView()
            }
            .navigationDestination(isPresented: $navigateToRecords) {
                AmericanRecordsView()
            }
            .navigationDestination(isPresented: $navigateToWSO) {
                WSORecordsView()
            }
            .navigationDestination(isPresented: $navigateToStandards) {
                StandardsView()
            }
            .navigationDestination(isPresented: $navigateToRankings) {
                InternationalRankingsView()
            }
            .sheet(isPresented: $navigateToPaywall) {
                PaywallView()
            }
            
        }
        
    }
}

#Preview {
    CompDataView()
}
