//
//  ProfileView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/4/25.
//

import SwiftUI
import RevenueCatUI

struct ProfileView: View {
    @Environment(\.colorScheme) var colorScheme

    @State private var localNotifs: Bool = false
    @State private var isCustomerCenterPresented: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
            
                ScrollView {
                    VStack {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("First Name")
                                    .bold()
                                    .padding(.bottom, 0.5)
                                Text("Maddisen")
                                    .secondaryText()
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        
                        Divider()
                            .padding(.vertical, 8)

                        HStack {
                            VStack(alignment: .leading) {
                                Text("Last Name")
                                    .bold()
                                    .padding(.bottom, 0.5)
                                Text("Mohnsen")
                                    .secondaryText()
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Email")
                                    .bold()
                                    .padding(.bottom, 0.5)
                                Text("memohnsen@gmail.com")
                                    .secondaryText()
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    }
                    .cardStyling()
                    .padding(.bottom, 12)
                    
                    Toggle(isOn: $localNotifs) {
                        Text("Session Reminders")
                            .bold()
                        Text("Get notified 1 hour before your sessions")
                            .font(.system(size: 14))
                            .padding(.top, 0.5)
                    }
                        .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                        .cardStyling()
                    
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
                            NavigationLink(destination: ScheduleView(), label: {Text("Submit Feedback")})
                                .foregroundStyle(colorScheme == .light ? .black : .white)
                            Spacer()
                            Image(systemName: "chevron.right")
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
                    
                    Link("Delete Your Account", destination: URL(string: "https://www.meetcal.app/privacy")!)
                        .font(.system(size: 14))
                        .padding(.top, 8)
                    
                    Button("Sign Out") {
                        
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.red)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
                    .padding(.top)
                }
                .padding(.horizontal)
            }
            .navigationTitle("My Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .tabBar)
        }
        .sheet(isPresented: $isCustomerCenterPresented) {
            CustomerCenterView()
        }
    }
}

#Preview {
    ProfileView()
}
