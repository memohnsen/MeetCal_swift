//
//  OnboardingView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 10/2/25.
//

import SwiftUI
import EventKit
import UserNotifications

struct OnboardingView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    @State private var pageCounter: Int = 1
    
    private func requestCalendarAccess() {
        let eventStore = EKEventStore()
        
        switch EKEventStore.authorizationStatus(for: .event) {
        case .notDetermined:
            eventStore.requestFullAccessToEvents { granted, error in
                DispatchQueue.main.async {
                    if granted {
                        print("Calendar access granted")
                    } else {
                        print("Calendar access denied: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
        case .denied, .restricted:
            print("Calendar access previously denied or restricted")
        case .fullAccess, .writeOnly:
            print("Calendar access already granted")
        @unknown default:
            print("Unknown calendar authorization status")
        }
    }
    
    private func requestNotificationAccess() {
        let center = UNUserNotificationCenter.current()

        AnalyticsManager.shared.trackNotificationPermissionRequested()

        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Notification access granted")
                    AnalyticsManager.shared.trackNotificationPermissionGranted()
                    AnalyticsManager.shared.setNotificationEnabled(true)
                } else {
                    print("Notification access denied: \(error?.localizedDescription ?? "Unknown error")")
                    AnalyticsManager.shared.trackNotificationPermissionDenied()
                    AnalyticsManager.shared.setNotificationEnabled(false)
                }
            }
        }
    }
    
    private func requestPermissions() {
        requestCalendarAccess()
        requestNotificationAccess()
        AnalyticsManager.shared.trackOnboardingCompleted()
        AnalyticsManager.shared.setOnboardingCompleted(true)
        dismiss()
    }
        
    var body: some View {
        Group {
            if pageCounter == 1 {
                VStack(alignment: .leading) {
                    Text("👋 Welcome to MeetCal!")
                        .bold()
                        .font(.title)
                        .foregroundStyle(colorScheme == .light ? .black : .white)
                        .padding(.top, 32)
                    
                    Text("We have 5 main features that help you have as much data as possible to compete and coach your best at meets.")
                        .foregroundStyle(colorScheme == .light ? .black : .white)
                        .padding(.top)
                    
                    Spacer()
                    
                    HStack {
                        Text("Next")
                    }
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .foregroundStyle(.white)
                    .background(.blue)
                    .cornerRadius(32)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .onTapGesture {
                        pageCounter += 1
                    }
                    .padding(.top)
                }
                .padding(.horizontal)
            } else if pageCounter == 2 {
                VStack(alignment: .leading) {
                    Text("📅 Schedule View")
                        .bold()
                        .font(.title)
                        .foregroundStyle(colorScheme == .light ? .black : .white)
                        .padding(.top, 32)
                    
                    Text("We have the Schedule and Start List for all USAW National meets, WSO meets, and all USAMW competitions. On this page you can swipe left to see each day of the meet.")
                        .foregroundStyle(colorScheme == .light ? .black : .white)
                        .padding(.top)
                    
                    Spacer()
                    
                    HStack {
                        Text("Next")
                    }
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .foregroundStyle(.white)
                    .background(.blue)
                    .cornerRadius(32)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .onTapGesture {
                        pageCounter += 1
                    }
                    .padding(.top)
                }
                .padding(.horizontal)
            } else if pageCounter == 3 {
                VStack(alignment: .leading) {
                    Text("📋 Schedule Details")
                        .bold()
                        .font(.title)
                        .foregroundStyle(colorScheme == .light ? .black : .white)
                        .padding(.top, 32)
                    
                    Text("After selecting a session you'll see all the athletes in the session. Alongside that you'll see age, club, weight class, entry total, and all their USAW meet results.")
                        .foregroundStyle(colorScheme == .light ? .black : .white)
                        .padding(.top)
                    
                    Spacer()
                    
                    HStack {
                        Text("Next")
                    }
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .foregroundStyle(.white)
                    .background(.blue)
                    .cornerRadius(32)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .onTapGesture {
                        pageCounter += 1
                    }
                    .padding(.top)
                }
                .padding(.horizontal)
            } else if pageCounter == 4 {
                VStack(alignment: .leading) {
                    Text("🥇 Start List")
                        .bold()
                        .font(.title)
                        .foregroundStyle(colorScheme == .light ? .black : .white)
                        .padding(.top, 32)
                    
                    Text("Click the search button in the bottom right to see the entire Start List. In here you can filter through the start list to get all the info you need.")
                        .foregroundStyle(colorScheme == .light ? .black : .white)
                        .padding(.top)
                    
                    Spacer()
                    
                    HStack {
                        Text("Next")
                    }
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .foregroundStyle(.white)
                    .background(.blue)
                    .cornerRadius(32)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .onTapGesture {
                        pageCounter += 1
                    }
                    .padding(.top)
                }
                .padding(.horizontal)
            } else if pageCounter == 5 {
                VStack(alignment: .leading) {
                    Text("🏋️‍♀️ Competition Data")
                        .bold()
                        .font(.title)
                        .foregroundStyle(colorScheme == .light ? .black : .white)
                        .padding(.top, 32)
                    
                    Text("Click the button in the top left and you'll have all the pertinent competition data you'll need such as: Qualifying Totals, A/B Standards, American and WSO Records, and International Rankings.")
                        .foregroundStyle(colorScheme == .light ? .black : .white)
                        .padding(.top)
                    
                    Spacer()
                    
                    HStack {
                        Text("Next")
                    }
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .foregroundStyle(.white)
                    .background(.blue)
                    .cornerRadius(32)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .onTapGesture {
                        pageCounter += 1
                    }
                    .padding(.top)
                }
                .padding(.horizontal)
            } else if pageCounter == 6 {
                VStack(alignment: .leading) {
                    Text("📲 Saved Sessions")
                        .bold()
                        .font(.title)
                        .foregroundStyle(colorScheme == .light ? .black : .white)
                        .padding(.top, 32)
                    
                    Text("Through the Start List and Session Details pages you can save important sessions both in the app and right to your calendar. From there you'll get push notifications 90 minutes before the session begins.")
                        .foregroundStyle(colorScheme == .light ? .black : .white)
                        .padding(.top)
                    
                    Spacer()
                    
                    HStack {
                        Text("Next")
                    }
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .foregroundStyle(.white)
                    .background(.blue)
                    .cornerRadius(32)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .onTapGesture {
                        pageCounter += 1
                    }
                    .padding(.top)
                }
                .padding(.horizontal)
            } else {
                VStack(alignment: .leading) {
                    Text("Calendar & Notification Access")
                        .bold()
                        .font(.title2)
                        .foregroundStyle(colorScheme == .light ? .black : .white)
                        .padding(.top, 32)
                    
                    Text("We ask for access to write to your calendar and to send you notifications. This allows us to put sessions on your calendar, alert you ahead of your session, and send updates such as platform changes.")
                        .foregroundStyle(colorScheme == .light ? .black : .white)
                        .padding(.top)
                    
                    Spacer()
                    
                    HStack {
                        Text("Done")
                    }
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .foregroundStyle(.white)
                    .background(.blue)
                    .cornerRadius(32)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .onTapGesture {
                        requestPermissions()
                    }
                    .padding(.top)
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            if pageCounter == 1 {
                AnalyticsManager.shared.trackOnboardingStarted()
            }
        }
    }
}

#Preview {
    OnboardingView()
}
