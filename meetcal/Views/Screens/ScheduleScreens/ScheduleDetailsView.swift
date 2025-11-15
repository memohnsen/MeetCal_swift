//
//  ScheduleDetails.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/1/25.
//

import SwiftUI
import Foundation
import RevenueCatUI
import RevenueCat
import EventKit
import UserNotifications

struct ScheduleDetailsView: View {
    @AppStorage("selectedMeet", store: .appGroup) private var selectedMeet: String = ""
    @Environment(\.modelContext) private var modelContext
    
    @StateObject private var viewModel = ScheduleDetailsModel()
    @StateObject private var viewModel2 = MeetsScheduleModel()
    @StateObject private var customerManager = CustomerInfoManager()
    
    var athletes: [AthleteRow] { viewModel.athletes }
    
    let meet: String
    let date: Date
    let sessionNum: Int
    let platformColor: String
    let weightClass: String
    let startTime: String
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    TopView(viewModel: viewModel2, athletes: athletes, athleteResults: viewModel.athleteResults, date: date, sessionNum: sessionNum, platformColor: platformColor, weightClass: weightClass, startTime: startTime)
                        .padding(.bottom, 8)

                    BottomView(viewModel: viewModel, athletes: athletes)
                }
                .padding(.horizontal)
                .navigationTitle(date.formatted(date: .long, time: .omitted))
                .navigationBarTitleDisplayMode(.inline)
            }
            .toolbar(.hidden, for: .tabBar)
        }
        .task(id: selectedMeet) {
            viewModel.setModelContext(modelContext)
            viewModel2.setModelContext(modelContext)
            viewModel2.meetDetails.removeAll()
            viewModel.athletes.removeAll()
            viewModel.athleteResults.removeAll()
            await viewModel2.loadMeetDetails(meetName: selectedMeet)
            await viewModel.loadAthletes(meet: meet, sessionID: sessionNum, platform: platformColor)
            await viewModel.loadAllResults()

            // Track session view
            AnalyticsManager.shared.trackSessionViewed(
                meetName: selectedMeet,
                sessionNumber: sessionNum,
                platform: platformColor,
                weightClass: weightClass
            )
        }
    }
}

struct TopView: View {
    @AppStorage("selectedMeet", store: .appGroup) private var selectedMeet: String = ""
    @AppStorage("has_seen_review") var hasSeenReview = false

    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: MeetsScheduleModel
    @StateObject private var saveModel = SavedViewModel()
    @StateObject private var customerManager = CustomerInfoManager()

    @State private var alertShowing: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var notificationIdentifier: String?
    @State private var navigateToPaywall: Bool = false
    @State private var navigateToQT: Bool = false
    @State private var navigateToReview: Bool = false
    @State private var navigateToGuesser: Bool = false

    var meetDetails: [MeetDetailsRow] { viewModel.meetDetails }
    var saved: [SessionsRow] { saveModel.saved }
    let athletes: [AthleteRow]
    let athleteResults: [AthleteResults]

    let date: Date
    let sessionNum: Int
    let platformColor: String
    let weightClass: String
    let startTime: String

    var isSessionSaved: Bool {
        saved.contains { session in
            session.meet == selectedMeet &&
            session.session_number == sessionNum &&
            session.platform == platformColor
        }
    }
    
    func convert24hourTo12hour(time24hour: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "HH:mm:ss"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let date = inputFormatter.date(from: time24hour) else {
            return nil
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "h:mm a"
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let time12hour = outputFormatter.string(from: date)
        
        return time12hour
    }
    
    func timeZoneShortHand() -> String {
        guard !meetDetails.isEmpty,
              let timeZone = meetDetails.first(where: { $0.name == selectedMeet })?.time_zone else {
            return "TBD" 
        }

        switch timeZone {
        case "America/New_York": return "Eastern"
        case "America/Los_Angeles": return "Pacific"
        case "America/Denver": return "Mountain"
        case "America/Chicago": return "Central"
        default: return "Central"
        }
    }
    
    func addToCal() {
        let eventStore = EKEventStore()
        
        let authStatus = EKEventStore.authorizationStatus(for: .event)
        print("Current auth status: \(authStatus.rawValue)")
        
        eventStore.requestWriteOnlyAccessToEvents { (granted, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error requesting access: \(error.localizedDescription)")
                    return
                }
                
                if granted {
                    self.createEvent(eventStore: eventStore)
                } else {
                    print("Calendar access denied")
                }
            }
        }
    }
    
    private func createEvent(eventStore: EKEventStore) {
        let event = EKEvent(eventStore: eventStore)
        event.title = "Session \(sessionNum) \(platformColor) - \(weightClass)"
        
        // Get the meet's time zone
        let meetTimeZoneIdentifier = meetDetails.first(where: { $0.name == selectedMeet })?.time_zone ?? "America/Chicago"
        guard let meetTimeZone = TimeZone(identifier: meetTimeZoneIdentifier) else {
            print("Invalid time zone identifier: \(meetTimeZoneIdentifier)")
            createEventWithLocalTime(event: event, eventStore: eventStore)
            return
        }
        
        // Create a calendar with the meet's time zone
        var meetCalendar = Calendar.current
        meetCalendar.timeZone = meetTimeZone
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        timeFormatter.timeZone = meetTimeZone // Set formatter to meet's time zone
        
        if let timeDate = timeFormatter.date(from: startTime) {
            let timeComponents = meetCalendar.dateComponents([.hour, .minute, .second], from: timeDate)
            let dateComponents = meetCalendar.dateComponents([.year, .month, .day], from: date)
            
            var combinedComponents = DateComponents()
            combinedComponents.year = dateComponents.year
            combinedComponents.month = dateComponents.month
            combinedComponents.day = dateComponents.day
            combinedComponents.hour = timeComponents.hour
            combinedComponents.minute = timeComponents.minute
            combinedComponents.second = timeComponents.second
            combinedComponents.timeZone = meetTimeZone // Specify the time zone
            
            if let eventStartDate = meetCalendar.date(from: combinedComponents) {
                event.startDate = eventStartDate
                event.endDate = eventStartDate.addingTimeInterval(7200) // 2 hours duration
            } else {
                // Fallback: create event with meet time zone applied to the date
                var fallbackComponents = meetCalendar.dateComponents([.year, .month, .day], from: date)
                fallbackComponents.hour = 12 // Default to noon
                fallbackComponents.minute = 0
                fallbackComponents.second = 0
                fallbackComponents.timeZone = meetTimeZone
                
                if let fallbackDate = meetCalendar.date(from: fallbackComponents) {
                    event.startDate = fallbackDate
                    event.endDate = fallbackDate.addingTimeInterval(7200)
                } else {
                    event.startDate = date
                    event.endDate = date.addingTimeInterval(7200)
                }
            }
        } else {
            // Fallback for invalid time format
            var fallbackComponents = meetCalendar.dateComponents([.year, .month, .day], from: date)
            fallbackComponents.hour = 12 // Default to noon
            fallbackComponents.minute = 0
            fallbackComponents.second = 0
            fallbackComponents.timeZone = meetTimeZone
            
            if let fallbackDate = meetCalendar.date(from: fallbackComponents) {
                event.startDate = fallbackDate
                event.endDate = fallbackDate.addingTimeInterval(7200)
            } else {
                event.startDate = date
                event.endDate = date.addingTimeInterval(7200)
            }
        }
        
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            try eventStore.save(event, span: .thisEvent)
            print("Event saved successfully!")
            alertTitle = "Event Saved Successfully"
            alertMessage = "Session \(sessionNum) \(platformColor) - \(weightClass) is now in your calendar"
            alertShowing = true
        } catch let error as NSError {
            print("Failed to save event: \(error.localizedDescription)")
            alertTitle = "Error saving to calendar"
            alertMessage = "Failed to save event: \(error.localizedDescription)"
            alertShowing = true
        }
    }
    
    private func createEventWithLocalTime(event: EKEvent, eventStore: EKEventStore) {
        // Fallback method using local time (original logic)
        let calendar = Calendar.current
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let timeDate = timeFormatter.date(from: startTime) {
            let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: timeDate)
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            
            var combinedComponents = DateComponents()
            combinedComponents.year = dateComponents.year
            combinedComponents.month = dateComponents.month
            combinedComponents.day = dateComponents.day
            combinedComponents.hour = timeComponents.hour
            combinedComponents.minute = timeComponents.minute
            combinedComponents.second = timeComponents.second
            
            if let eventStartDate = calendar.date(from: combinedComponents) {
                event.startDate = eventStartDate
                event.endDate = eventStartDate.addingTimeInterval(7200)
            } else {
                event.startDate = date
                event.endDate = date.addingTimeInterval(7200)
            }
        } else {
            event.startDate = date
            event.endDate = date.addingTimeInterval(7200)
        }
        
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            try eventStore.save(event, span: .thisEvent)
            print("Event saved successfully!")
            alertTitle = "Event Saved Successfully"
            alertMessage = "Session \(sessionNum) \(platformColor) - \(weightClass) is now in your calendar"
            alertShowing = true
        } catch let error as NSError {
            print("Failed to save event: \(error.localizedDescription)")
            alertTitle = "Error saving to calendar"
            alertMessage = "Failed to save event: \(error.localizedDescription)"
            alertShowing = true
        }
    }
    
    var notifTime: TimeInterval {
        let meetTimeZoneIdentifier = meetDetails.first(where: { $0.name == selectedMeet })?.time_zone ?? "America/Chicago"
        guard let meetTimeZone = TimeZone(identifier: meetTimeZoneIdentifier) else {
            return -1 // Return negative to indicate invalid
        }

        // Create a calendar with the meet's time zone
        var meetCalendar = Calendar.current
        meetCalendar.timeZone = meetTimeZone

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        timeFormatter.timeZone = meetTimeZone

        guard let timeDate = timeFormatter.date(from: startTime) else {
            return -1 // Return negative to indicate invalid
        }

        let timeComponents = meetCalendar.dateComponents([.hour, .minute, .second], from: timeDate)
        let dateComponents = meetCalendar.dateComponents([.year, .month, .day], from: date)

        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute
        combinedComponents.second = timeComponents.second
        combinedComponents.timeZone = meetTimeZone

        guard let sessionDateTime = meetCalendar.date(from: combinedComponents) else {
            return -1 // Return negative to indicate invalid
        }

        let notificationTime = sessionDateTime.addingTimeInterval(-5400) // 90 minutes before
        let timeInterval = notificationTime.timeIntervalSinceNow

        // Return the actual time interval (can be negative if in the past)
        return timeInterval
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Session \(sessionNum) • \(convert24hourTo12hour(time24hour: startTime) ?? "TBD") \(timeZoneShortHand())")
                .foregroundStyle(colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                .padding(.vertical, 6)

            Divider()
            
            HStack {
                Platform(text: platformColor)
                Text(weightClass)
                    .padding(.horizontal, 6)
                    
            }
            .padding(.vertical, 6)
            
            Divider()
                .padding(.vertical, 6)
            
 

            HStack {
                if !isSessionSaved {
                    Button("Save Session") {
                        Task {
                            do {
                                try await saveModel.saveSession(meet: selectedMeet, sessionNumber: sessionNum, platform: platformColor, weightClass: weightClass, startTime: startTime, date: date, athleteNames: [], notes: "")
                                await saveModel.loadSaved(meet: selectedMeet)
                                alertTitle = "Session Saved"
                                alertMessage = "Session \(sessionNum) \(platformColor) has been saved successfully!"
                                alertShowing = true

                                // Track session save
                                AnalyticsManager.shared.trackSessionSaved(
                                    meetName: selectedMeet,
                                    sessionNumber: sessionNum,
                                    platform: platformColor,
                                    athleteCount: athletes.count
                                )

                                await customerManager.fetchCustomerInfo()

                                if customerManager.hasProAccess {
                                    let settings = await UNUserNotificationCenter.current().notificationSettings()
                                    guard settings.authorizationStatus == .authorized else {
                                        print("Notifications not authorized")
                                        return
                                    }

                                    if notifTime > 60 {
                                        let content = UNMutableNotificationContent()
                                        content.title = "Session \(sessionNum) \(platformColor) starts in 90 minutes"
                                        content.subtitle = "Make sure to secure your platform!"
                                        content.sound = UNNotificationSound.default

                                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: notifTime, repeats: false)

                                        let identifier = "\(selectedMeet)-\(sessionNum)-\(platformColor)"
                                        notificationIdentifier = identifier
                                        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

                                        try await UNUserNotificationCenter.current().add(request)
                                        let notificationDate = Date().addingTimeInterval(notifTime)
                                        let formatter = DateFormatter()
                                        formatter.dateFormat = "MMM d, yyyy 'at' h:mm:ss a zzz"
                                        formatter.locale = Locale(identifier: "en_US")
                                        print("Notification set for: \(formatter.string(from: notificationDate)) (\(Int(notifTime / 60)) minutes from now)")
                                    } else {
                                        if notifTime < 0 {
                                            print("Session \(sessionNum) \(platformColor) has already passed, skipping notification")
                                        } else {
                                            print("Session \(sessionNum) \(platformColor) starts too soon (less than 90 minutes), skipping notification")
                                        }
                                    }
                                } else {
                                    print("Not a pro user")
                                }
                            } catch {
                                alertTitle = "Error"
                                alertMessage = "Failed to save session: \(error.localizedDescription)"
                                alertShowing = true
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.width < 415 ? 44 : (UIScreen.main.bounds.width < 431 ? 48 : 50))
                    .foregroundStyle(.white)
                    .background(.blue)
                    .cornerRadius(12)
                    .padding(.vertical, 6)
                } else {
                    Button("Unsave Session") {
                        Task {
                            await saveModel.unsaveSession(meet: selectedMeet, sessionNumber: sessionNum, platform: platformColor)
                            await saveModel.loadSaved(meet: selectedMeet)

                            let identifier = "\(selectedMeet)-\(sessionNum)-\(platformColor)"
                            let center = UNUserNotificationCenter.current()
                            center.removePendingNotificationRequests(withIdentifiers: [identifier])
                            notificationIdentifier = nil

                            // Track session unsave
                            AnalyticsManager.shared.trackSessionUnsaved(
                                meetName: selectedMeet,
                                sessionNumber: sessionNum,
                                platform: platformColor
                            )

                            alertTitle = "Session Unsaved"
                            alertMessage = "Session \(sessionNum) \(platformColor) has been unsaved"
                            alertShowing = true
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.width < 415 ? 44 : (UIScreen.main.bounds.width < 431 ? 48 : 50))
                    .foregroundStyle(.white)
                    .background(.blue)
                    .cornerRadius(12)
                    .padding(.vertical, 6)
                }

                Button("Add to Calendar") {
                    addToCal()
                }
                .frame(maxWidth: .infinity)
                .frame(height: UIScreen.main.bounds.width < 415 ? 44 : (UIScreen.main.bounds.width < 431 ? 48 : 50))
                .foregroundStyle(.white)
                .background(.green)
                .cornerRadius(12)
            }
            
            Divider()
                .padding(.vertical, 6)
            
            if customerManager.hasProAccess {
                HStack{
                    Button {
                        navigateToQT = true
                    } label: {
                        Text("Qualifying Totals")
                            .font(.system(size: UIScreen.main.bounds.width < 415 ? 15 : 18))
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundStyle(.blue)

                    Divider()

                    Button{
                        navigateToGuesser = true
                    } label: {
                        Text("Attempt Estimator")
                            .font(.system(size: UIScreen.main.bounds.width < 415 ? 15 : 18))
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundStyle(.blue)
                }
            } else {
                HStack {
                    Button {
                        navigateToPaywall = true
                    } label: {
                        HStack {
                            Text("Qualifying Totals")
                                .font(.system(size: UIScreen.main.bounds.width < 415 ? 15 : 18))
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .foregroundStyle(.blue)
                    }

                    Divider()

                    Button{
                        navigateToPaywall = true
                    } label: {
                        Text("Attempt Estimator")
                            .font(.system(size: UIScreen.main.bounds.width < 415 ? 15 : 18))
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundStyle(.blue)
                }
            }
        }
        .cardStyling()
        .cornerRadius(32)
        .alert(alertTitle, isPresented: $alertShowing) {
            Button("OK") {
                if !hasSeenReview && alertTitle == "Session Saved" {
                    navigateToReview = true
                    hasSeenReview = true
                }
            }
        } message: {
            Text(alertMessage)
        }
        .task(id: selectedMeet) {
            await saveModel.loadSaved(meet: selectedMeet)
        }
        .sheet(isPresented: $navigateToPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $navigateToQT) {
            QualifyingTotalsView()
        }
        .sheet(isPresented: $navigateToGuesser) {
            AttemptsGuesser(athletes: athletes, athleteResults: athleteResults)
        }
        .sheet(isPresented: $navigateToReview) {
            ReviewRequest()
                .presentationDetents([.height(450)])
        }
    }
}

struct BottomView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: ScheduleDetailsModel
    @StateObject private var customerManager = CustomerInfoManager()
    @State private var navigateToPaywall: Bool = false
    @State private var navigateToResults: Bool = false

    let athletes: [AthleteRow]
    var results: [AthleteResults] { viewModel.athleteResults }
    
    func getBestResults(for athleteName: String) -> (snatch: Float, cleanJerk: Float, total: Float) {
        let athleteResults = results.filter { $0.name == athleteName }
        let bestSnatch = athleteResults.map { $0.snatch_best }.max() ?? 0
        let bestCleanJerk = athleteResults.map { $0.cj_best }.max() ?? 0
        let bestTotal = athleteResults.map { $0.total }.max() ?? 0
        return (bestSnatch, bestCleanJerk, bestTotal)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Session Athletes")
                .bold()
                .padding(.bottom, 4)
                .padding(.top, 20)
            
            Divider()
            
            ForEach(athletes, id: \.member_id) { athlete in
                VStack(alignment: .leading) {
                    Text(athlete.name)
                        .bold()
                        .padding(.top, 8)
                    
                    VStack(alignment: .leading) {
                        Text("Age: \(athlete.age)")
                            .foregroundStyle(colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                            .padding(.top, 0.5)
                            .font(.system(size: 16))
                        Text("Weight Class: \(athlete.weight_class)")
                            .foregroundStyle(colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                            .padding(.top, 0.5)
                            .font(.system(size: 16))
                        
                        Text(athlete.club)
                            .foregroundStyle(colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                            .padding(.top, 0.5)
                            .font(.system(size: 16))
                        
                        HStack {
                            VStack {
                                Text("Entry Total")
                                    .secondaryText()
                                    .padding(.bottom, 0.5)
                                Text("\(athlete.entry_total)kg")
                                    .bold()
                            }
                            
                            Spacer()
                            
                            if customerManager.hasProAccess {
                                VStack {
                                    Text("Best Sn")
                                        .secondaryText()
                                        .padding(.bottom, 0.5)
                                    Text("\(Int(getBestResults(for: athlete.name).snatch))kg")
                                        .bold()
                                }
                            
                                Spacer()
                                
                                VStack {
                                    Text("Best CJ")
                                        .secondaryText()
                                        .padding(.bottom, 0.5)
                                    Text("\(Int(getBestResults(for: athlete.name).cleanJerk))kg")
                                        .bold()
                                }
                                
                                Spacer()

                                VStack {
                                    Text("Best Total")
                                        .secondaryText()
                                        .padding(.bottom, 0.5)
                                    Text("\(Int(getBestResults(for: athlete.name).total))kg")
                                        .bold()
                                }
                            } else {
                                HStack {
                                    Spacer()
                                    Text("PRO ACCESS ONLY")
                                        .bold()
                                    Spacer()
                                }
                                .padding()
                                .background(.ultraThickMaterial)
                                .background(.blue)
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical, 8)
                        .font(.system(size: 16))

                        if customerManager.hasProAccess {
                            HStack {
                                Spacer()
                                NavigationLink(destination: MeetResultsView(name: athlete.name)) {
                                    Text("See All Meet Results")
                                    Image(systemName: "chevron.right")
                                }
                                .padding(.vertical, 8)
                                Spacer()
                            }
                        } else {
                            Button {
                                navigateToPaywall = true
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("Get Pro To See All Meet Results")
                                        .font(.system(size: 15))
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12))
                                    Spacer()
                                }
                                .foregroundStyle(.blue)
                            }
                            .padding(.vertical, 8)
                            .sheet(isPresented: $navigateToPaywall) {
                                PaywallView()
                            }
                        }
                        Divider()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .background(colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
        .cornerRadius(32)
        .task{
            await customerManager.fetchCustomerInfo()
        }
    }
}

#Preview {
    ScheduleDetailsView(meet: "2025 Iowa-Nebraska WSO Championships", date: .now, sessionNum: 1, platformColor: "Red", weightClass: "F 58B", startTime: "8:00")
}
