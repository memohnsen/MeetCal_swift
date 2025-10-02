//
//  ScheduleView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/1/25.
//

import SwiftUI
import EventKit
import UserNotifications

private struct AgeBand: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let range: ClosedRange<Int>?

    static let all = AgeBand(label: "All Ages", range: nil)
}

private let defaultAgeBands: [AgeBand] = [
    .all,
    AgeBand(label: "U13", range: 0...13),
    AgeBand(label: "U15", range: 14...15),
    AgeBand(label: "U17", range: 16...17),
    AgeBand(label: "Junior", range: 18...20),
    AgeBand(label: "Senior", range: 21...35),
    AgeBand(label: "Masters 35", range: 36...40),
    AgeBand(label: "Masters 40", range: 41...45),
    AgeBand(label: "Masters 45", range: 46...50),
    AgeBand(label: "Masters 50", range: 51...55),
    AgeBand(label: "Masters 55", range: 56...60),
    AgeBand(label: "Masters 60", range: 61...65),
    AgeBand(label: "Masters 65", range: 66...70),
    AgeBand(label: "Masters 70", range: 71...75),
    AgeBand(label: "Masters 75", range: 76...80),
    AgeBand(label: "Masters 80", range: 81...85),
    AgeBand(label: "Masters 85", range: 86...90),
    AgeBand(label: "Masters 90+", range: 91...150)
]

struct StartListView: View {
    @AppStorage("selectedMeet") private var selectedMeet = ""
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = StartListModel()
    @StateObject private var viewModel2 = MeetsScheduleModel()
    @StateObject private var saveModel = SavedViewModel()
    @StateObject private var customerManager = CustomerInfoManager()
    
    @State var isAgeDropdownShowing: Bool = false
    @State var isWeightDropdownShowing: Bool = false
    @State var isGenderDropdownShowing: Bool = false
    @State var isClubDropdownShowing: Bool = false
    @State var isAdapDropdownShowing: Bool = false
    
    @State private var selectedAgeBand: AgeBand = .all
    @State var selectedWeight: String = "All Weight Classes"
    @State var selectedGender: String = "All Genders"
    @State var selectedClub: String = "All Clubs"
    @State private var selectedAdap: String = "All Athletes"
    
    @State private var draftAgeBand: AgeBand = .all
    @State var draftWeight: String = "All Weight Classes"
    @State var draftGender: String = "All Genders"
    @State var draftClub: String = "All Clubs"
    @State private var draftAdap: String = "All Athletes"
    
    @State private var searchText: String = ""
    @State private var clubSearchText: String = ""
    @State private var saveButtonClicked: Bool = false
    @State private var filterClicked: Bool = false
    
    @State private var alertShowing: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    var athleteList: [AthleteRow] { viewModel.athletes }
    var scheduleList: [ScheduleRow] { viewModel.schedule }
    var weightClass: [String] { viewModel.weightClass }
    var ages: [Int] { viewModel.ages }
    var club: [String] { viewModel.club }
    var adaptive: [Bool] { viewModel.adaptiveBool }
    var meetDetails: [MeetDetailsRow] { viewModel2.meetDetails }
    
    var filteredAthletes: [AthleteRow] {
        guard !searchText.isEmpty else { return athleteList }
        return athleteList.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var filteredClubs: [String] {
        guard !clubSearchText.isEmpty else { return club }
        return club.filter { $0.localizedCaseInsensitiveContains(clubSearchText) }
    }
    
    // Unique sessions represented by the currently filtered athletes (deduped by session_id + platform)
    private var uniqueFilteredSessions: [ScheduleRow] {
        var seen = Set<String>()
        var result: [ScheduleRow] = []
        for athlete in filteredAthletes {
            guard let sched = matchSchedule(for: athlete) else { continue }
            let key = "\(sched.session_id)|\(sched.platform)"
            if !seen.contains(key) {
                seen.insert(key)
                result.append(sched)
            }
        }
        return result
    }
    
    private func matchSchedule(for athlete: AthleteRow) -> ScheduleRow? {
        scheduleList.first {
            $0.session_id == (athlete.session_number ?? -1) && $0.platform == (athlete.session_platform ?? "")
        }
    }
    
    private func displayDateTime(for row: ScheduleRow) -> String {
        let dateText = row.date.formatted(date: .abbreviated, time: .omitted)
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "HH:mm:ss"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "h:mm a"
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        var timeText = "No Time"
        if let date = inputFormatter.date(from: row.start_time) {
            timeText = outputFormatter.string(from: date)
        }
        
        let timeZone = meetDetails.first(where: { $0.name == selectedMeet })?.time_zone ?? "Unknown"

        let tzAbbrev = switch timeZone {
            case "America/New_York": "ET"
            case "America/Los_Angeles": "PT"
            case "America/Denver": "MT"
            default: "CT"
        }
        
        return "\(dateText) • \(timeText) \(tzAbbrev)"
    }
    
    private func adaptiveFlag(from selection: String) -> Bool? {
        switch selection {
        case "Adaptive Athletes":
            return true
        case "Non-Adaptive Athletes":
            return false
        default:
            return nil
        }
    }
    
    private func applyFilters() {
        let adapParam: Bool? = adaptiveFlag(from: selectedAdap)
        let clubParam: String? = (selectedClub == "All Clubs") ? nil : selectedClub
        let weightParam: String? = (selectedWeight == "All Weight Classes") ? nil : selectedWeight
        let genderParam: String? = (selectedGender == "All Genders") ? nil : selectedGender
        Task {
            await viewModel.loadFilteredStartList(
                meet: selectedMeet,
                ageRange: selectedAgeBand.range,
                gender: genderParam,
                weight_class: weightParam,
                club: clubParam,
                adaptive: adapParam
            )
        }
    }
    
    // Get athlete names for a specific session
    private func getAthleteNames(for session: ScheduleRow) -> [String] {
        filteredAthletes
            .filter { athlete in
                athlete.session_number == session.session_id &&
                athlete.session_platform == session.platform
            }
            .map { $0.name }
    }

    // Save all filtered sessions to the app database
    func saveFilteredSessions() {
        let sessions = uniqueFilteredSessions
        if sessions.isEmpty {
            alertTitle = "Nothing to Save"
            alertMessage = "No sessions were found for the current filters."
            alertShowing = true
            return
        }

        Task {
            var successCount = 0
            var failCount = 0

            for session in sessions {
                let athleteNames = getAthleteNames(for: session)

                do {
                    try await saveModel.saveSession(
                        meet: selectedMeet,
                        sessionNumber: session.session_id,
                        platform: session.platform,
                        weightClass: session.weight_class,
                        startTime: session.start_time,
                        date: session.date,
                        athleteNames: athleteNames,
                        notes: ""
                    )
                    successCount += 1
                } catch {
                    print("Failed to save session \(session.session_id) \(session.platform): \(error.localizedDescription)")
                    failCount += 1
                }
            }

            await saveModel.loadSaved(meet: selectedMeet)

            alertTitle = failCount == 0 ? "Sessions Saved" : "Saved with Issues"
            if failCount == 0 {
                alertMessage = "Saved \(successCount) session\(successCount == 1 ? "" : "s") to your library."
            } else {
                alertMessage = "Saved \(successCount) of \(sessions.count) sessions. \(failCount) failed."
            }
            alertShowing = true
        }
    }

    // Add all unique sessions for the currently filtered athletes to Calendar
    func addFilteredSessionsToCalendar() {
        let sessions = uniqueFilteredSessions
        if sessions.isEmpty {
            alertTitle = "Nothing to Add"
            alertMessage = "No sessions were found for the current filters."
            alertShowing = true
            return
        }
        let eventStore = EKEventStore()

        let authStatus = EKEventStore.authorizationStatus(for: .event)
        print("Current auth status: \(authStatus.rawValue)")

        eventStore.requestWriteOnlyAccessToEvents { (granted, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.alertTitle = "Calendar Access Error"
                    self.alertMessage = error.localizedDescription
                    self.alertShowing = true
                    return
                }

                guard granted else {
                    self.alertTitle = "Calendar Access Denied"
                    self.alertMessage = "Please allow calendar access in Settings to add sessions."
                    self.alertShowing = true
                    return
                }

                // Determine meet time zone
                let tzIdentifier = self.meetDetails.first(where: { $0.name == self.selectedMeet })?.time_zone ?? "America/Chicago"
                let meetTimeZone = TimeZone(identifier: tzIdentifier) ?? TimeZone.current

                var successCount = 0
                var failureCount = 0

                for session in sessions {
                    if let event = self.makeEvent(for: session, eventStore: eventStore, timeZone: meetTimeZone) {
                        do {
                            try eventStore.save(event, span: .thisEvent)
                            successCount += 1
                        } catch {
                            print("Failed to save event for session \(session.session_id) \(session.platform): \(error.localizedDescription)")
                            failureCount += 1
                        }
                    } else {
                        failureCount += 1
                    }
                }

                self.alertTitle = failureCount == 0 ? "Added to Calendar" : "Added with Issues"
                if failureCount == 0 {
                    self.alertMessage = "Added \(successCount) session\(successCount == 1 ? "" : "s") to your calendar."
                } else {
                    self.alertMessage = "Added \(successCount) of \(sessions.count) sessions. \(failureCount) failed."
                }
                self.alertShowing = true
            }
        }
    }

    // Create a single EKEvent for a schedule row using the meet's time zone
    private func makeEvent(for session: ScheduleRow, eventStore: EKEventStore, timeZone: TimeZone) -> EKEvent? {
        let event = EKEvent(eventStore: eventStore)
        event.title = "Session \(session.session_id) \(session.platform) - \(session.weight_class)"

        var meetCalendar = Calendar.current
        meetCalendar.timeZone = timeZone

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        timeFormatter.timeZone = timeZone

        let date = session.date

        if let timeDate = timeFormatter.date(from: session.start_time) {
            let timeComponents = meetCalendar.dateComponents([.hour, .minute, .second], from: timeDate)
            var dateComponents = meetCalendar.dateComponents([.year, .month, .day], from: date)
            dateComponents.hour = timeComponents.hour
            dateComponents.minute = timeComponents.minute
            dateComponents.second = timeComponents.second
            dateComponents.timeZone = timeZone

            if let eventStartDate = meetCalendar.date(from: dateComponents) {
                event.startDate = eventStartDate
                event.endDate = eventStartDate.addingTimeInterval(7200) // 2 hours
            } else {
                // Fallback to noon on that date in meet TZ
                var fallback = meetCalendar.dateComponents([.year, .month, .day], from: date)
                fallback.hour = 12
                fallback.minute = 0
                fallback.second = 0
                fallback.timeZone = timeZone
                event.startDate = meetCalendar.date(from: fallback) ?? date
                event.endDate = event.startDate.addingTimeInterval(7200)
            }
        } else {
            // Fallback for invalid/missing time
            var fallback = meetCalendar.dateComponents([.year, .month, .day], from: date)
            fallback.hour = 12
            fallback.minute = 0
            fallback.second = 0
            fallback.timeZone = timeZone
            event.startDate = meetCalendar.date(from: fallback) ?? date
            event.endDate = event.startDate.addingTimeInterval(7200)
        }

        event.calendar = eventStore.defaultCalendarForNewEvents
        return event
    }
    
    // Schedule notifications for all filtered sessions
    func scheduleNotificationsForFilteredSessions() async {
        // Ensure customer info is fetched first
        await customerManager.fetchCustomerInfo()
        
        // Only schedule notifications for Pro users
        guard customerManager.hasProAccess else {
            print("Notifications are a Pro feature")
            return
        }
        
        let sessions = uniqueFilteredSessions
        
        // Check if notifications are authorized first
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        guard settings.authorizationStatus == .authorized else {
            print("Notifications not authorized")
            return
        }
        
        for session in sessions {
            scheduleNotification(for: session)
        }
    }
    
    // Schedule a notification for a specific session
    private func scheduleNotification(for session: ScheduleRow) {
        let timeInterval = calculateNotificationTime(for: session)
        
        // Only schedule if the notification time is in the future
        guard timeInterval > 1 else {
            print("Session \(session.session_id) \(session.platform) is too soon or has passed, skipping notification")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Session \(session.session_id) \(session.platform) starts in 90 minutes"
        content.subtitle = "Make sure to secure your platform!"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        let identifier = "\(selectedMeet)-\(session.session_id)-\(session.platform)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification for session \(session.session_id) \(session.platform): \(error.localizedDescription)")
            } else {
                let notificationDate = Date().addingTimeInterval(timeInterval)
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d, yyyy 'at' h:mm:ss a zzz"
                formatter.locale = Locale(identifier: "en_US")
                print("Notification scheduled for session \(session.session_id) \(session.platform): \(formatter.string(from: notificationDate)) (\(Int(timeInterval / 60)) minutes from now)")
            }
        }
    }
    
    // Calculate notification time for a specific session (90 minutes before)
    private func calculateNotificationTime(for session: ScheduleRow) -> TimeInterval {
        // Get the meet's time zone
        let meetTimeZoneIdentifier = meetDetails.first(where: { $0.name == selectedMeet })?.time_zone ?? "America/Chicago"
        guard let meetTimeZone = TimeZone(identifier: meetTimeZoneIdentifier) else {
            return 5400 // Default to 90 minutes if timezone is invalid
        }
        
        // Create a calendar with the meet's time zone
        var meetCalendar = Calendar.current
        meetCalendar.timeZone = meetTimeZone
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        timeFormatter.timeZone = meetTimeZone
        
        guard let timeDate = timeFormatter.date(from: session.start_time) else {
            return 5400
        }
        
        let timeComponents = meetCalendar.dateComponents([.hour, .minute, .second], from: timeDate)
        let dateComponents = meetCalendar.dateComponents([.year, .month, .day], from: session.date)
        
        // Combine date and time with the meet's timezone
        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute
        combinedComponents.second = timeComponents.second
        combinedComponents.timeZone = meetTimeZone
        
        guard let sessionDateTime = meetCalendar.date(from: combinedComponents) else {
            return 5400
        }
        
        let notificationTime = sessionDateTime.addingTimeInterval(-5400) // 90 minutes before
        let timeInterval = notificationTime.timeIntervalSinceNow
        
        return max(timeInterval, 1)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(filteredAthletes, id: \.member_id) { athlete in
                        let matchedSchedule = matchSchedule(for: athlete)
                        let formattedDateTime = matchedSchedule.map(displayDateTime(for:)) ?? "TBD"
                        
                        AthleteDisclosureRow(
                            athlete: athlete,
                            schedule: matchedSchedule,
                            dateTimeText: formattedDateTime,
                            colorScheme: colorScheme,
                            viewModel: viewModel
                        )
                    }
                }
                .searchable(text: $searchText, prompt: "Search for an athlete")
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Start List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .topBarTrailing) {
                    Image(systemName: "square.and.arrow.down")
                        .onTapGesture {
                            saveButtonClicked = true
                        }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: "line.3.horizontal.decrease")
                        .onTapGesture {
                            filterClicked = true
                        }
                }
            }
            .toolbar(filterClicked || saveButtonClicked ? .hidden : .visible, for: .tabBar)
            .overlay {
                if saveButtonClicked {
                    ZStack {
                        Color(colorScheme == .light ? .black.opacity(0.4) : .black.opacity(0.7))
                            .ignoresSafeArea()
                            .onTapGesture {
                                saveButtonClicked = false
                            }
                        
                        VStack(spacing: 16) {
                            Button{
                                saveFilteredSessions()
                                Task {
                                    await scheduleNotificationsForFilteredSessions()
                                }
                                saveButtonClicked = false
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Save Sessions")
                                            .foregroundStyle(colorScheme == .light ? .black : .white)
                                        Text("Save \(uniqueFilteredSessions.count) session\(uniqueFilteredSessions.count == 1 ? "" : "s") in the app")
                                            .foregroundStyle(colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(colorScheme == .light ? .black : .white)
                                }
                            }

                            Divider()
                            
                            Button {
                                addFilteredSessionsToCalendar()
                                saveButtonClicked = false
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Save to Calendar")
                                            .foregroundStyle(colorScheme == .light ? .black : .white)
                                        Text("Save \(uniqueFilteredSessions.count) session\(uniqueFilteredSessions.count == 1 ? "" : "s") directly to your iCal")
                                            .foregroundStyle(colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(colorScheme == .light ? .black : .white)
                                }
                            }
                        }
                        .padding()
                        .background(colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
            }
        }
        .overlay{
            if filterClicked {
                FilterModal(
                    isShowing: $filterClicked,
                    isAgeDropdownShowing: $isAgeDropdownShowing,
                    isWeightDropdownShowing: $isWeightDropdownShowing,
                    isGenderDropdownShowing: $isGenderDropdownShowing,
                    isClubDropdownShowing: $isClubDropdownShowing,
                    isAdapDropdownShowing: $isAdapDropdownShowing,
                    selectedAgeBand: $selectedAgeBand,
                    selectedWeight: $selectedWeight,
                    selectedGender: $selectedGender,
                    selectedClub: $selectedClub,
                    selectedAdap: $selectedAdap,
                    draftAgeBand: $draftAgeBand,
                    draftWeight: $draftWeight,
                    draftGender: $draftGender,
                    draftClub: $draftClub,
                    draftAdap: $draftAdap,
                    clubSearchText: $clubSearchText,
                    ageBands: defaultAgeBands,
                    club: club,
                    weightClass: weightClass,
                    adaptiveBool: adaptive,
                    onApply: {
                        selectedAgeBand = draftAgeBand
                        selectedAdap = draftAdap
                        selectedClub = draftClub
                        selectedGender = draftGender
                        selectedWeight = draftWeight
                        Task {
                            applyFilters()
                        }
                        filterClicked = false
                    }
                )
            }
        }
        .task{
            await viewModel.loadStartList(meet: selectedMeet)
            await viewModel.loadMeetSchedule(meet: selectedMeet)
            await viewModel2.loadMeetDetails(meetName: selectedMeet)
        }
        .onChange(of: selectedMeet) {
            Task {
                await viewModel.loadStartList(meet: selectedMeet)
                await viewModel.loadMeetSchedule(meet: selectedMeet)
            }
        }
        .onChange(of: draftAgeBand) {
            Task {
                await viewModel.loadWeightClasses(meet: selectedMeet, ageRange: draftAgeBand.range, gender: draftGender == "All Genders" ? nil : draftGender)
            }
        }
        .onChange(of: draftGender) {
            Task {
                await viewModel.loadWeightClasses(meet: selectedMeet, ageRange: draftAgeBand.range, gender: draftGender == "All Genders" ? nil : draftGender)
            }
        }
        .onChange(of: isWeightDropdownShowing) {
            if isWeightDropdownShowing {
                Task {
                    await viewModel.loadWeightClasses(meet: selectedMeet, ageRange: draftAgeBand == .all ? nil : draftAgeBand.range, gender: draftGender == "All Genders" ? nil : draftGender)
                }
            }
        }
        .alert(alertTitle, isPresented: $alertShowing) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
}

private struct AthleteDisclosureRow: View {
    @AppStorage("selectedMeet") private var selectedMeet = ""
    
    let athlete: AthleteRow
    let schedule: ScheduleRow?
    let dateTimeText: String
    let colorScheme: ColorScheme
    @ObservedObject var viewModel: StartListModel
    
    @State private var hasLoadedBestLifts = false
    
    private var athleteBestLifts: [AthleteResults] {
        viewModel.athleteBests.filter { $0.name == athlete.name }
    }
    
    private var bestSnatch: Float {
        athleteBestLifts.map { $0.snatch_best }.max() ?? 0
    }
    
    private var bestCleanJerk: Float {
        athleteBestLifts.map { $0.cj_best }.max() ?? 0
    }
    
    private var bestTotal: Float {
        athleteBestLifts.map { $0.total }.max() ?? 0
    }
    
    var body: some View {
        DisclosureGroup(athlete.name) {
            VStack(spacing: 20) {
                HStack {
                    Text("Session:")
                        .foregroundStyle(colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)

                    Spacer()

                    NavigationLink(destination: ScheduleDetailsView(meet: selectedMeet, date: schedule?.date ?? .now, sessionNum: athlete.session_number ?? 00, platformColor: athlete.session_platform ?? "TBD", weightClass: athlete.weight_class, startTime: dateTimeText)) {
                        Text("Session \(athlete.session_number ?? 0) • \(athlete.session_platform ?? "TBD") Platform")
                    }
                    .foregroundStyle(.blue)
                    .frame(width: 250, alignment: .trailing)
                }
                HStack {
                    Text("Date & Time:")
                        .foregroundStyle(colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                    
                    Spacer()
                    Text(dateTimeText)
                }
                HStack {
                    Text("Club:")
                        .foregroundStyle(colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                    
                    Spacer()
                    Text(athlete.club)
                }
                HStack {
                    Text("Weight Class:")
                        .foregroundStyle(colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                    
                    Spacer()
                    Text(athlete.weight_class)
                }
                HStack {
                    Text("Age:")
                        .foregroundStyle(colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                    
                    Spacer()
                    Text(String(athlete.age))
                }
                HStack {
                    Text("Entry Total:")
                        .foregroundStyle(colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                    
                    Spacer()
                    Text(String(athlete.entry_total))
                }
                
                HStack {
                    VStack {
                        Divider()
                            .padding(.vertical, 6)
                        
                        Text("Best Lifts From The Last Year")
                            .padding(.bottom, 10)
                        
                        if viewModel.isLoading && !hasLoadedBestLifts {
                            ProgressView()
                                .frame(height: 60)
                        } else {
                            HStack {
                                VStack {
                                    Text("Snatch")
                                        .secondaryText()
                                    Text(bestSnatch > 0 ? String(Int(bestSnatch)) : "N/A")
                                        .bold()
                                }
                                
                                Spacer()
                                
                                VStack {
                                    Text("CJ")
                                        .secondaryText()
                                    Text(bestCleanJerk > 0 ? String(Int(bestCleanJerk)) : "N/A")
                                        .bold()
                                }
                                
                                Spacer()
                                
                                VStack {
                                    Text("Total")
                                        .secondaryText()
                                    Text(bestTotal > 0 ? String(Int(bestTotal)) : "N/A")
                                        .bold()
                                }
                            }
                            .frame(width: 220)
                        }
                    }
                }
            }
            .padding(.leading, -20)
            .task {
                if !hasLoadedBestLifts {
                    await viewModel.loadBestLifts(name: athlete.name)
                    hasLoadedBestLifts = true
                }
            }
        }
    }
}

private struct FilterModal: View {
    @Environment(\.colorScheme) var colorScheme

    @Binding var isShowing: Bool
    @Binding var isAgeDropdownShowing: Bool
    @Binding var isWeightDropdownShowing: Bool
    @Binding var isGenderDropdownShowing: Bool
    @Binding var isClubDropdownShowing: Bool
    @Binding var isAdapDropdownShowing: Bool
    
    @Binding var selectedAgeBand: AgeBand
    @Binding var selectedWeight: String
    @Binding var selectedGender: String
    @Binding var selectedClub: String
    @Binding var selectedAdap: String
    
    @Binding var draftAgeBand: AgeBand
    @Binding var draftWeight: String
    @Binding var draftGender: String
    @Binding var draftClub: String
    @Binding var draftAdap: String
    
    @Binding var clubSearchText: String
    
    let genders: [String] = ["All Genders", "Male", "Female"]
    let adaptive: [String] = ["All Athletes", "Adaptive Athletes", "Non-Adaptive Athletes"]
    var ageBands: [AgeBand]
    var club: [String]
    var weightClass: [String]
    var adaptiveBool: [Bool]
    var onApply: () -> Void
    
    var filteredClubs: [String] {
        guard !clubSearchText.isEmpty else { return club }
        return club.filter { $0.localizedCaseInsensitiveContains(clubSearchText) }
    }
    
    var body: some View {
        Group {
            if isShowing {
                Color(colorScheme == .light ? .black.opacity(0.4) : .black.opacity(0.7))
                    .ignoresSafeArea()
                    .onTapGesture {
                        isShowing = false
                        isAgeDropdownShowing = false
                        isWeightDropdownShowing = false
                        isClubDropdownShowing = false
                        isGenderDropdownShowing = false
                        isAdapDropdownShowing = false
                        clubSearchText = ""
                    }
                
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Age Groups")
                                .secondaryText()
                                .padding(.bottom, 0.5)
                            Text(draftAgeBand.label)
                        }
                        Spacer()
                        Image(systemName: isAgeDropdownShowing ? "chevron.down" : "chevron.right")
                    }
                    .padding()
                    .background(colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isAgeDropdownShowing.toggle()
                        isWeightDropdownShowing = false
                        isClubDropdownShowing = false
                        isGenderDropdownShowing = false
                        isAdapDropdownShowing = false
                    }
                    
                    if isAgeDropdownShowing {
                        if ageBands.count > 6 {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 0) {
                                    Divider()
                                    ForEach(ageBands) { band in
                                        HStack {
                                            Button(action: {
                                                draftAgeBand = band
                                                isAgeDropdownShowing = false
                                            }) {
                                                Text(band.label)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding(.leading, 0)
                                                    .padding()
                                                    .foregroundStyle(band == draftAgeBand ? Color.blue : (colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white))
                                            }
                                            Spacer()
                                            if band == draftAgeBand {
                                                Image(systemName: "checkmark")
                                                    .foregroundStyle(.blue)
                                            }
                                            Spacer()
                                        }
                                        .background(band == draftAgeBand ? .gray.opacity(0.2) : (colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground)))
                                        Divider()
                                    }
                                }
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 0) {
                                Divider()
                                ForEach(ageBands) { band in
                                    HStack {
                                        Button(action: {
                                            draftAgeBand = band
                                            isAgeDropdownShowing = false
                                        }) {
                                            Text(band.label)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.leading, 0)
                                                .padding()
                                                .foregroundStyle(band == draftAgeBand ? Color.blue : (colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white))
                                        }
                                        Spacer()
                                        if band == draftAgeBand {
                                            Image(systemName: "checkmark")
                                                .foregroundStyle(.blue)
                                        }
                                        Spacer()
                                    }
                                    .background(band == draftAgeBand ? .gray.opacity(0.2) : (colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground)))
                                    Divider()
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Gender")
                                .secondaryText()
                                .padding(.bottom, 0.5)
                            Text(draftGender.isEmpty ? selectedGender : draftGender)
                        }
                        Spacer()
                        Image(systemName: isGenderDropdownShowing ? "chevron.down" : "chevron.right")
                    }
                    .padding()
                    .background(colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isGenderDropdownShowing.toggle()
                        isAgeDropdownShowing = false
                        isClubDropdownShowing = false
                        isWeightDropdownShowing = false
                        isAdapDropdownShowing = false
                    }
                    
                    if isGenderDropdownShowing {
                        VStack(alignment: .leading, spacing: 0) {
                            Divider()
                            
                            ForEach(genders, id: \.self) { gender in
                                HStack {
                                    Button(action: {
                                        draftGender = gender
                                        isGenderDropdownShowing = false
                                    }) {
                                        Text(gender)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading, 0)
                                            .padding()
                                            .foregroundStyle(gender == draftGender ? Color.blue : colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                                    }
                                    
                                    
                                    Spacer()
                                    if gender == draftGender {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.blue)
                                    }
                                    Spacer()
                                }
                                .background(gender == draftGender ? .gray.opacity(0.2) : colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                                
                                Divider()
                            }
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Weight Class")
                                .secondaryText()
                                .padding(.bottom, 0.5)
                            Text(((draftWeight.isEmpty ? selectedWeight : draftWeight) == "All Weight Classes") ? (draftWeight.isEmpty ? selectedWeight : draftWeight) : "\(draftWeight.isEmpty ? selectedWeight : draftWeight)kg")
                        }
                        Spacer()
                        Image(systemName: isWeightDropdownShowing ? "chevron.down" : "chevron.right")
                    }
                    .padding()
                    .background(colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isWeightDropdownShowing.toggle()
                        isAgeDropdownShowing = false
                        isGenderDropdownShowing = false
                        isAdapDropdownShowing = false
                        isClubDropdownShowing = false
                    }
                    
                    if isWeightDropdownShowing {
                        if weightClass.count > 6 {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 0) {
                                    Divider()
                                    
                                    ForEach(["All Weight Classes"] + weightClass, id: \.self) { weight in
                                        HStack {
                                            Button(action: {
                                                draftWeight = weight
                                                isWeightDropdownShowing = false
                                            }) {
                                                Text(weight == "All Weight Classes" ? weight : "\(weight)kg")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding(.leading, 0)
                                                    .padding()
                                                    .foregroundStyle(weight == draftWeight ? Color.blue : colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                                            }
                                            
                                            
                                            Spacer()
                                            if weight == draftWeight {
                                                Image(systemName: "checkmark")
                                                    .foregroundStyle(.blue)
                                            }
                                            Spacer()
                                        }
                                        .background(weight == draftWeight ? .gray.opacity(0.2) : colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                                        
                                        Divider()
                                    }
                                }
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 0) {
                                Divider()
                                
                                ForEach(["All Weight Classes"] + weightClass, id: \.self) { weight in
                                    HStack {
                                        Button(action: {
                                            draftWeight = weight
                                            isWeightDropdownShowing = false
                                        }) {
                                            Text(weight == "All Weight Classes" ? weight : "\(weight)kg")
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.leading, 0)
                                                .padding()
                                                .foregroundStyle(weight == draftWeight ? Color.blue : colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                                        }
                                        
                                        
                                        Spacer()
                                        if weight == draftWeight {
                                            Image(systemName: "checkmark")
                                                .foregroundStyle(.blue)
                                        }
                                        Spacer()
                                    }
                                    .background(weight == draftWeight ? .gray.opacity(0.2) : colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                                    
                                    Divider()
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Club")
                                .secondaryText()
                                .padding(.bottom, 0.5)
                            Text(draftClub.isEmpty ? selectedClub : draftClub)
                        }
                        Spacer()
                        Image(systemName: isClubDropdownShowing ? "chevron.down" : "chevron.right")
                    }
                    .padding()
                    .background(colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isClubDropdownShowing.toggle()
                        isAgeDropdownShowing = false
                        isWeightDropdownShowing = false
                        isGenderDropdownShowing = false
                        isAdapDropdownShowing = false
                    }
                    
                    if isClubDropdownShowing {
                        VStack(alignment: .leading, spacing: 0) {
                            Divider()
                            
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundStyle(.gray)
                                TextField("Search clubs...", text: $clubSearchText)
                                    .textFieldStyle(PlainTextFieldStyle())
                                if !clubSearchText.isEmpty {
                                    Button(action: {
                                        clubSearchText = ""
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.gray)
                                    }
                                }
                            }
                            .padding()
                            .background(colorScheme == .light ? Color(.systemGray6) : Color(.systemGray5))
                            
                            Divider()
                            
                            if filteredClubs.count > 6 {
                                ScrollView {
                                    VStack(alignment: .leading, spacing: 0) {
                                        HStack {
                                            Button(action: {
                                                draftClub = "All Clubs"
                                                isClubDropdownShowing = false
                                                clubSearchText = ""
                                            }) {
                                                Text("All Clubs")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding(.leading, 0)
                                                    .padding()
                                                    .foregroundStyle("All Clubs" == draftClub ? Color.blue : colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                                            }
                                            
                                            Spacer()
                                            if "All Clubs" == draftClub {
                                                Image(systemName: "checkmark")
                                                    .foregroundStyle(.blue)
                                            }
                                            Spacer()
                                        }
                                        .background("All Clubs" == draftClub ? .gray.opacity(0.2) : colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                                        
                                        Divider()
                                        
                                        ForEach(filteredClubs, id: \.self) { team in
                                            HStack {
                                                Button(action: {
                                                    draftClub = team
                                                    isClubDropdownShowing = false
                                                    clubSearchText = ""
                                                }) {
                                                    Text(team)
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                        .padding(.leading, 0)
                                                        .padding()
                                                        .foregroundStyle(team == draftClub ? Color.blue : colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                                                }
                                                
                                                Spacer()
                                                if team == draftClub {
                                                    Image(systemName: "checkmark")
                                                        .foregroundStyle(.blue)
                                                }
                                                Spacer()
                                            }
                                            .background(team == draftClub ? .gray.opacity(0.2) : colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                                            
                                            Divider()
                                        }
                                        
                                        if filteredClubs.isEmpty && !clubSearchText.isEmpty {
                                            HStack {
                                                Text("No clubs found")
                                                    .foregroundStyle(.gray)
                                                    .frame(maxWidth: .infinity, alignment: .center)
                                                    .padding()
                                            }
                                            .background(colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                                            
                                            Divider()
                                        }
                                    }
                                }
                            } else {
                                VStack(alignment: .leading, spacing: 0) {
                                    HStack {
                                        Button(action: {
                                            draftClub = "All Clubs"
                                            isClubDropdownShowing = false
                                            clubSearchText = ""
                                        }) {
                                            Text("All Clubs")
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.leading, 0)
                                                .padding()
                                                .foregroundStyle("All Clubs" == draftClub ? Color.blue : colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                                        }
                                        
                                        Spacer()
                                        if "All Clubs" == draftClub {
                                            Image(systemName: "checkmark")
                                                .foregroundStyle(.blue)
                                        }
                                        Spacer()
                                    }
                                    .background("All Clubs" == draftClub ? .gray.opacity(0.2) : colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                                    
                                    Divider()
                                    
                                    ForEach(filteredClubs, id: \.self) { team in
                                        HStack {
                                            Button(action: {
                                                draftClub = team
                                                isClubDropdownShowing = false
                                                clubSearchText = ""
                                            }) {
                                                Text(team)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding(.leading, 0)
                                                    .padding()
                                                    .foregroundStyle(team == draftClub ? Color.blue : colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                                            }
                                            
                                            Spacer()
                                            if team == draftClub {
                                                Image(systemName: "checkmark")
                                                    .foregroundStyle(.blue)
                                            }
                                            Spacer()
                                        }
                                        .background(team == draftClub ? .gray.opacity(0.2) : colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                                        
                                        Divider()
                                    }
                                    
                                    if filteredClubs.isEmpty && !clubSearchText.isEmpty {
                                        HStack {
                                            Text("No clubs found")
                                                .foregroundStyle(.gray)
                                                .frame(maxWidth: .infinity, alignment: .center)
                                                .padding()
                                        }
                                        .background(colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                                        
                                        Divider()
                                    }
                                }
                            }
                        }
                    }

                    Divider()
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Adaptive")
                                .secondaryText()
                                .padding(.bottom, 0.5)
                            Text(draftAdap.isEmpty ? selectedAdap : draftAdap)
                        }
                        Spacer()
                        Image(systemName: isAdapDropdownShowing ? "chevron.down" : "chevron.right")
                    }
                    .padding()
                    .background(colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isAdapDropdownShowing.toggle()
                        isAgeDropdownShowing = false
                        isWeightDropdownShowing = false
                        isGenderDropdownShowing = false
                        isClubDropdownShowing = false
                    }
                    
                    if isAdapDropdownShowing {
                        VStack(alignment: .leading, spacing: 0) {
                            Divider()
                            
                            ForEach(adaptive, id: \.self) { adap in
                                HStack {
                                    Button(action: {
                                        draftAdap = adap
                                        isAdapDropdownShowing = false
                                    }) {
                                        Text(adap)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading, 0)
                                            .padding()
                                            .foregroundStyle(adap == draftAdap ? Color.blue : colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                                    }
                                    
                                    
                                    Spacer()
                                    if adap == draftAdap {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.blue)
                                    }
                                    Spacer()
                                }
                                .background(adap == draftAdap ? .gray.opacity(0.2) : colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                                
                                Divider()
                            }
                        }
                    }
                                        
                    Divider()
                    
                    HStack {
                        Text("Apply")
                            .bold()
                            .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(.white)
                    .background(.blue)
                    .cornerRadius(12)
                    .padding()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onApply()
                    }
                }
                .frame(maxWidth: 350)
                .background(colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                .cornerRadius(16)
                .shadow(radius: 20)
                .padding(.horizontal, 30)
            }
        }
    }
}

#Preview {
    StartListView()
}
