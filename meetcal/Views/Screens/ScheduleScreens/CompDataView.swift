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
    
    var body: some View {
        NavigationStack{
            List {
                NavigationLink("Event Info", destination: EventInfoView())
                
                NavigationLink("Weightlifting Wrapped", destination: WLWrapped())
                
                if customerManager.hasProAccess {
                    NavigationLink("Shareable Meet Results By Club", destination: ShareMeetResultsByClub())
                } else {
                    Button {
                        navigateToPaywall = true
                    } label: {
                        HStack {
                            Text("Shareable Meet Results By Club")
                                .foregroundStyle(colorScheme == .light ? .black : .white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.gray.opacity(0.5))
                        }
                    }
                }
                
                Section("National") {
                    NavigationLink(destination: AllMeetResultsView()) {
                        Text("All Meet Results")
                    }
                    
                    if customerManager.hasProAccess {
                        NavigationLink(destination: QualifyingTotalsView()) {
                            Text("Qualifying Totals")
                        }
                    } else {
                        Button {
                            navigateToPaywall = true
                        } label: {
                            HStack {
                                Text("Qualifying Totals")
                                    .foregroundStyle(colorScheme == .light ? .black : .white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.gray.opacity(0.5))
                            }
                        }
                    }
                    
                    if customerManager.hasProAccess {
                        NavigationLink(destination: NationalRankingsView()) {
                            Text("National Rankings")
                        }
                    } else {
                        Button {
                            navigateToPaywall = true
                        } label: {
                            HStack {
                                Text("National Rankings")
                                    .foregroundStyle(colorScheme == .light ? .black : .white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.gray.opacity(0.5))
                            }
                        }
                    }

                    if customerManager.hasProAccess {
                        NavigationLink(destination: AmericanRecordsView()) {
                            Text("American Records")
                        }
                    } else {
                        Button {
                            navigateToPaywall = true
                        } label: {
                            HStack {
                                Text("American Records")
                                    .foregroundStyle(colorScheme == .light ? .black : .white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.gray.opacity(0.5))
                            }
                        }
                    }
                    
                    
                    if customerManager.hasProAccess {
                        NavigationLink(destination: WSORecordsView()) {
                            Text("WSO Records")
                        }
                    } else {
                        Button {
                            navigateToPaywall = true
                        } label: {
                            HStack {
                                Text("WSO Records")
                                    .foregroundStyle(colorScheme == .light ? .black : .white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.gray.opacity(0.5))
                            }
                        }
                    }
                    
                    if customerManager.hasProAccess {
                        NavigationLink(destination: AdaptiveRecordsView()) {
                            Text("Adaptive American Records")
                        }
                    } else {
                        Button {
                            navigateToPaywall = true
                        } label: {
                            HStack {
                                Text("Adaptive American Records")
                                    .foregroundStyle(colorScheme == .light ? .black : .white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.gray.opacity(0.5))
                            }
                        }
                    }
                }
                    
                
                Section("International") {
                    if customerManager.hasProAccess {
                        NavigationLink(destination: WorldRecordsView()) {
                            Text("IWF World Records")
                        }
                    } else {
                        Button {
                            navigateToPaywall = true
                        } label: {
                            HStack {
                                Text("IWF World Records")
                                    .foregroundStyle(colorScheme == .light ? .black : .white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.gray.opacity(0.5))
                            }
                        }
                    }
                    
                    if customerManager.hasProAccess {
                        NavigationLink(destination: StandardsView()) {
                            Text("A/B Standards")
                        }
                    } else {
                        Button {
                            navigateToPaywall = true
                        } label: {
                            HStack {
                                Text("A/B Standards")
                                    .foregroundStyle(colorScheme == .light ? .black : .white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.gray.opacity(0.5))
                            }
                        }
                    }
                    
                    if customerManager.hasProAccess {
                        NavigationLink(destination: InternationalRankingsView()) {
                            Text("International Rankings")
                        }
                    } else {
                        Button {
                            navigateToPaywall = true
                        } label: {
                            HStack {
                                Text("International Rankings")
                                    .foregroundStyle(colorScheme == .light ? .black : .white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.gray.opacity(0.5))
                            }
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
            .sheet(isPresented: $navigateToPaywall) {
                PaywallView()
            }
            
        }
        
    }
}

#Preview {
    CompDataView()
}
