//
//  ScheduleView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/1/25.
//

import SwiftUI
import RevenueCat
import RevenueCatUI
import EventKit
import UserNotifications

struct SavedView: View {
    @AppStorage("selectedMeet") private var selectedMeet = ""
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = SavedViewModel()
    @StateObject private var meetViewModel = MeetsScheduleModel()
    @StateObject private var customerManager = CustomerInfoManager()

    @State private var alertShowing: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""

    var saved: [SessionsRow] { viewModel.saved }
    var meetDetails: [MeetDetailsRow] { meetViewModel.meetDetails }
    
    func addAllToCal() {
        Task {
            // Ensure meet details are loaded first
            if meetDetails.isEmpty {
                await meetViewModel.loadMeetDetails(meetName: selectedMeet)
            }

            let eventStore = EKEventStore()

            eventStore.requestWriteOnlyAccessToEvents { (granted, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error requesting access: \(error.localizedDescription)")
                        alertTitle = "Calendar Access Error"
                        alertMessage = error.localizedDescription
                        alertShowing = true
                        return
                    }

                    if granted {
                        var successCount = 0
                        var failCount = 0

                        for session in saved {
                            if self.createEvent(eventStore: eventStore, session: session) {
                                successCount += 1
                            } else {
                                failCount += 1
                            }
                        }

                        if failCount == 0 {
                            alertTitle = "Success"
                            alertMessage = "Added \(successCount) session(s) to your calendar"
                        } else {
                            alertTitle = "Partial Success"
                            alertMessage = "Added \(successCount) session(s). Failed to add \(failCount) session(s)."
                        }
                        alertShowing = true
                    } else {
                        alertTitle = "Calendar Access Denied"
                        alertMessage = "Please enable calendar access in Settings"
                        alertShowing = true
                    }
                }
            }
        }
    }

    private func createEvent(eventStore: EKEventStore, session: SessionsRow) -> Bool {
        let event = EKEvent(eventStore: eventStore)
        event.title = "Session \(session.session_number) \(session.platform) - \(session.weight_class)"

        // Get the meet's time zone
        let meetTimeZoneIdentifier = meetDetails.first(where: { $0.name == selectedMeet })?.time_zone ?? "America/Chicago"
        guard let meetTimeZone = TimeZone(identifier: meetTimeZoneIdentifier) else {
            return createEventWithLocalTime(event: event, eventStore: eventStore, session: session)
        }

        var meetCalendar = Calendar.current
        meetCalendar.timeZone = meetTimeZone

        // Parse the date string directly in the meet's timezone
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = meetTimeZone
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        guard let sessionDate = dateFormatter.date(from: session.date) else {
            return false
        }

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        timeFormatter.timeZone = meetTimeZone

        if let timeDate = timeFormatter.date(from: session.start_time) {
            let timeComponents = meetCalendar.dateComponents([.hour, .minute, .second], from: timeDate)
            let dateComponents = meetCalendar.dateComponents([.year, .month, .day], from: sessionDate)

            var combinedComponents = DateComponents()
            combinedComponents.year = dateComponents.year
            combinedComponents.month = dateComponents.month
            combinedComponents.day = dateComponents.day
            combinedComponents.hour = timeComponents.hour
            combinedComponents.minute = timeComponents.minute
            combinedComponents.second = timeComponents.second
            combinedComponents.timeZone = meetTimeZone

            if let eventStartDate = meetCalendar.date(from: combinedComponents) {
                event.startDate = eventStartDate
                event.endDate = eventStartDate.addingTimeInterval(7200)
            } else {
                return false
            }
        } else {
            return false
        }

        event.calendar = eventStore.defaultCalendarForNewEvents

        do {
            try eventStore.save(event, span: .thisEvent)
            return true
        } catch {
            print("Failed to save event: \(error.localizedDescription)")
            return false
        }
    }

    private func createEventWithLocalTime(event: EKEvent, eventStore: EKEventStore, session: SessionsRow) -> Bool {
        let calendar = Calendar.current

        // Parse the date string in local timezone
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = calendar.timeZone
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        guard let sessionDate = dateFormatter.date(from: session.date) else {
            return false
        }

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")

        if let timeDate = timeFormatter.date(from: session.start_time) {
            let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: timeDate)
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: sessionDate)

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
                return false
            }
        } else {
            return false
        }

        event.calendar = eventStore.defaultCalendarForNewEvents

        do {
            try eventStore.save(event, span: .thisEvent)
            return true
        } catch {
            print("Failed to save event: \(error.localizedDescription)")
            return false
        }
    }
        
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
                                                date: session.dateAsDate,
                                                sessionNum: session.session_number,
                                                platformColor: session.platform,
                                                weightClass: session.weight_class,
                                                startTime: session.start_time)) {
                                                    HStack{
                                                        VStack(alignment: .leading) {
                                                            Text("Session \(String(session.session_number)) • \(session.formattedDate)")
                                                                .padding(.bottom, 6)
                                                                .foregroundStyle(colorScheme == .light ? .black : .white)
                                                                .font(.headline)
                                                                .bold()
                                                            
                                                            HStack {
                                                                Text("Weigh-In: \(session.weighInTime) • Start: \(session.formattedStartTime)")
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
                                                        Spacer()
                                                    }
                                                    .padding(.horizontal)
                            }
                            .padding(.vertical)
                        }
                        .frame(maxWidth: .infinity)
                        .background(colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                        .cornerRadius(32)
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                        .foregroundStyle(.black)
                    }
                    .padding(.top, 8)
                    .toolbar{
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                addAllToCal()
                            } label: {
                                Image(systemName: "calendar.badge.plus")
                            }
                        }
                        ToolbarSpacer()
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                Task {
                                    await viewModel.deleteAllSessions(meet: selectedMeet)
                                    await viewModel.loadSaved(meet: selectedMeet)
                                    
                                    let center = UNUserNotificationCenter.current()
                                    let requests = await center.pendingNotificationRequests()
                                    let identifiersToRemove = requests
                                        .map { $0.identifier }
                                        .filter { $0.hasPrefix(selectedMeet) }
                                    
                                    center.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
                                    print(identifiersToRemove)
                                }
                                alertShowing = true
                                alertTitle = "Sessions Deleted"
                                alertMessage = "All saved sessions for \(selectedMeet) have been deleted"
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                }
                .navigationTitle("Saved")
                .navigationBarTitleDisplayMode(.inline)
                .refreshable{
                    await meetViewModel.loadMeetDetails(meetName: selectedMeet)
                    await viewModel.loadSaved(meet: selectedMeet)
                }
                .alert(alertTitle, isPresented: $alertShowing) {
                    Button("OK") { }
                } message: {
                    Text(alertMessage)
                }
            }
            .task {
                await viewModel.loadSaved(meet: selectedMeet)
            }
            .onChange(of: selectedMeet) {
                Task {
                    await viewModel.loadSaved(meet: selectedMeet)
                }
            }
        }
    }
}

#Preview {
    SavedView()
}

