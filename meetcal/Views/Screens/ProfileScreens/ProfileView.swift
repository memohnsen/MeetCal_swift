//
//  ProfileView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/4/25.
//

import SwiftUI
import RevenueCatUI
import RevenueCat
import Clerk

struct ProfileView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.clerk) private var clerk
    @StateObject private var customerManager = CustomerInfoManager()

    @State private var localNotifs: Bool = false
    @State private var isCustomerCenterPresented: Bool = false
    @State private var navigateToPaywall: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
            
                ScrollView {
                    NavigationLink(destination: UserProfileView()) {
                        Text("Manage Your Profile")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .cardStyling()
                    .foregroundStyle(colorScheme == .light ? .black : .white)
                    .padding(.bottom, 8)
                    
                    if customerManager.hasProAccess {
                        HStack {
                            NavigationLink(destination: OfflineModeView()) {
                                Text("Downloaded Data")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .cardStyling()
                            .foregroundStyle(colorScheme == .light ? .black : .white)
                            .padding(.bottom, 8)
                        }
                    } else {
                        Button {
                            navigateToPaywall = true
                        } label: {
                            HStack {
                                Text("Downloaded Data")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .cardStyling()
                            .foregroundStyle(colorScheme == .light ? .black : .white)
                            .padding(.bottom, 8)
                        }
                    }
                    
                    VStack {
                        HStack {
                            Button{
                                self.isCustomerCenterPresented = true
                            } label: {
                                Text("Customer Support")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .foregroundStyle(colorScheme == .light ? .black : .white)
                        }
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        HStack {
                            NavigationLink(destination: FeedbackView()) {
                                Text("Submit Feedback")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .foregroundStyle(colorScheme == .light ? .black : .white)
                        }
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        Link(destination: URL(string: "https://apps.apple.com/us/app/meetcal/id6741133286")!) {
                            HStack {
                                Text("Leave A Review")
                                Spacer()
                                Image(systemName: "chevron.right")
                              }
                            .foregroundStyle(colorScheme == .light ? .black : .white)
                        }
                    }
                    .cardStyling()
                    
                    HStack {
                        Link("Privacy Policy", destination: URL(string: "https://www.meetcal.app/privacy")!)
                        Text("•")
                        Link("Terms of Use", destination: URL(string: "https://www.meetcal.app/terms")!)
                        Text("•")
                        Link("User Agreement", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                    }
                    .font(.system(size: 14))
                    .padding(.top)
                }
                .padding(.horizontal)
            }
            .navigationTitle("My Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .tabBar)
            .sheet(isPresented: $navigateToPaywall) {
                PaywallView()
            }
            .task{
                AnalyticsManager.shared.trackScreenView("Profile")
                await customerManager.fetchCustomerInfo()
            }
        }
        .sheet(isPresented: $isCustomerCenterPresented) {
            CustomerCenterView()
        }
    }
}

#Preview {
    ProfileView()
}

