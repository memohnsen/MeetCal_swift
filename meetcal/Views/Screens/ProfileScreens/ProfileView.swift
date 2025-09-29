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
                    .padding(.bottom, 12)

                    Toggle(isOn: $localNotifs) {
                        Text("Session Reminders")
                        Text("Get notified 1 hour before your sessions")
                            .font(.system(size: 14))
                            .padding(.top, 0.5)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                    .cardStyling()
                    .disabled(!customerManager.hasProAccess)
                    
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
                    .padding(.top, 12)
                    
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
            .task{
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

