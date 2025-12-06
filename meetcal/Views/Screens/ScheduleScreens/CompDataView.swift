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
                    .simultaneousGesture(TapGesture().onEnded {
                        AnalyticsManager.shared.trackFeatureAccessed(featureName: "Event Info", source: "Competition Data")
                    })

                NavigationLink("Weightlifting Wrapped", destination: WLWrapped())
                    .simultaneousGesture(TapGesture().onEnded {
                        AnalyticsManager.shared.trackFeatureAccessed(featureName: "Weightlifting Wrapped", source: "Competition Data")
                    })

                if customerManager.hasProAccess {
                    NavigationLink("Shareable Meet Results By Club", destination: ShareMeetResultsByClub())
                        .simultaneousGesture(TapGesture().onEnded {
                            AnalyticsManager.shared.trackFeatureAccessed(featureName: "Shareable Meet Results By Club", source: "Competition Data")
                        })
                } else {
                    Button {
                        AnalyticsManager.shared.trackProFeatureAttemptedWithoutAccess(featureName: "Shareable Meet Results By Club")
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
                    .simultaneousGesture(TapGesture().onEnded {
                        AnalyticsManager.shared.trackFeatureAccessed(featureName: "All Meet Results", source: "Competition Data")
                    })

                    if customerManager.hasProAccess {
                        NavigationLink(destination: QualifyingTotalsView()) {
                            Text("Qualifying Totals")
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            AnalyticsManager.shared.trackFeatureAccessed(featureName: "Qualifying Totals", source: "Competition Data")
                        })
                    } else {
                        Button {
                            AnalyticsManager.shared.trackProFeatureAttemptedWithoutAccess(featureName: "Qualifying Totals")
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
                        .simultaneousGesture(TapGesture().onEnded {
                            AnalyticsManager.shared.trackFeatureAccessed(featureName: "National Rankings", source: "Competition Data")
                        })
                    } else {
                        Button {
                            AnalyticsManager.shared.trackProFeatureAttemptedWithoutAccess(featureName: "National Rankings")
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
                            Text("National & World Records")
                        }
                    } else {
                        Button {
                            navigateToPaywall = true
                        } label: {
                            HStack {
                                Text("National & World Records")
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
                AnalyticsManager.shared.trackScreenView("Competition Data")
                await customerManager.fetchCustomerInfo()
            }
            .sheet(isPresented: $navigateToPaywall) {
                PaywallView()
            }
            .onChange(of: navigateToPaywall) { oldValue, newValue in
                if newValue {
                    AnalyticsManager.shared.trackPaywallViewed(triggerLocation: "Competition Data")
                }
            }
            
        }
        
    }
}

#Preview {
    CompDataView()
}
