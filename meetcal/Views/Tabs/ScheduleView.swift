//
//  ScheduleView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/1/25.
//

import SwiftUI
import Clerk

struct ScheduleView: View {
    @AppStorage("selectedMeet") private var selectedMeet: String = ""
    @AppStorage("has_launched_before") var hasLaunchedBefore = false

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.clerk) private var clerk
    
    @StateObject private var viewModel = MeetsScheduleModel()
    
    @State private var authIsPresented = false
    @State private var showingMeetsOverlay: Bool = false
    @State private var onboardingSheetShowing: Bool = false
    @State private var platformColor: String = ""
    
    var schedule: [ScheduleRow] { viewModel.schedule }
    var meets: [String] { viewModel.meets }
    var meetDetails: [MeetDetailsRow] { viewModel.meetDetails }
    var isLoading: Bool { viewModel.isLoading }
    
    private var uniqueDays: [Date] {
        let calendar = Calendar.current
        let days = schedule.map { calendar.startOfDay(for: $0.date)}
        let unique = Array(Set(days))
        return unique.sorted()
    }

    var body: some View {
        NavigationStack{
            if clerk.user != nil {
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Selected Meet")
                                .bold()
                                .padding(.bottom, 0.5)
                            Text(selectedMeet)
                        }
                        Spacer()
                        Image(systemName: "chevron.down")
                            .secondaryText()
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .onTapGesture {
                        showingMeetsOverlay = true
                    }
                    .frame(height: 100)
                    .padding(.top, 0)
                    
                    if viewModel.schedule.count == 0 {
                        Spacer()
                    }
                    
                    VStack {
                        if viewModel.isLoading {
                            VStack {
                                Spacer()
                                ProgressView("Loading...")
                                Spacer()
                            }
                            .padding(.top, -10)
                            .navigationTitle("Loading...")
                            .navigationBarTitleDisplayMode(.inline)
                        } else if uniqueDays.count == 0 {
                            VStack {
                                Spacer()
                                Image("meetcal-logo")
                                    .resizable()
                                    .frame(width: 140, height: 140)
                                    .shadow(radius: 8)
                                Text("No data for has been loaded yet for this meet.")
                                Text("Check back soon!")
                                Spacer()
                            }
                            .padding(.top, -10)
                            .navigationTitle("TBD")
                            .navigationBarTitleDisplayMode(.inline)
                        } else {
                            TabView {
                                ForEach(uniqueDays, id: \.self) { day in
                                    let calendar = Calendar.current
                                    let rowsForDay = schedule.filter{ calendar.isDate($0.date, inSameDayAs: day )}
                                    DaySessionsView(day: day, schedule: rowsForDay, meetDetails: meetDetails, isLoading: isLoading)
                                        .background(Color.clear)
                                        .safeAreaInset(edge: .bottom) {
                                            Color.clear
                                                .frame(height: 40)
                                        }
                                        .safeAreaPadding(.top, 28)
                                }
                            }
                            .tabViewStyle(.page(indexDisplayMode: .never))
                            .background(Color.clear)
                            .ignoresSafeArea(edges: .bottom)
                        }
                    }
                }
                .background(Color(.systemGroupedBackground).ignoresSafeArea())
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(destination: ProfileView()) {
                            Image(systemName: "person.crop.circle.fill")
                        }
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        NavigationLink(destination: CompDataView()) {
                            Image(systemName: "list.bullet")
                        }
                    }
                }
            } else {
                SignInView(action: { authIsPresented = true })
            }
        }
        .sheet(isPresented: $authIsPresented) {
            AuthView()
        }
        .sheet(isPresented: $onboardingSheetShowing) {
            OnboardingView()
                .presentationDetents([.height(275)])
        }
        .onChange(of: authIsPresented) { oldValue, newValue in
            if oldValue == true && newValue == false && clerk.user != nil && !hasLaunchedBefore {
                onboardingSheetShowing = true
                hasLaunchedBefore = true
            }
        }
        .task {
            await viewModel.loadMeets()
            if selectedMeet.isEmpty, let first = viewModel.meets.first {
                selectedMeet = first
            }
            await viewModel.loadMeetSchedule(meet: selectedMeet)
            await viewModel.loadMeetDetails(meetName: selectedMeet)
        }
        .onChange(of: selectedMeet) {
            Task {
                await viewModel.loadMeetSchedule(meet: selectedMeet)
                await viewModel.loadMeetDetails(meetName: selectedMeet)
            }
        }
        .refreshable {
            await viewModel.loadMeetSchedule(meet: selectedMeet)
            await viewModel.loadMeetDetails(meetName: selectedMeet)
        }
        .overlay(
            Group {
                if showingMeetsOverlay {
                    Color(colorScheme == .light ? .black.opacity(0.4) : .black.opacity(0.7))
                        .ignoresSafeArea()
                        .onTapGesture { showingMeetsOverlay = false }
                    
                    VStack(spacing: 0) {
                        Text("Select Your Meet")
                            .font(.headline)
                            .padding()
                        Divider()
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(meets, id: \.self) { meet in
                                    HStack {
                                        Text(meet)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading, 0)
                                            .padding()
                                            .foregroundStyle(meet == selectedMeet ? Color.blue : colorScheme == .light ? .black : .white)
                                        Spacer()
                                        if meet == selectedMeet {
                                            Image(systemName: "checkmark")
                                                .foregroundStyle(.blue)
                                        }
                                        Spacer()
                                    }
                                    .background(meet == selectedMeet ? Color.gray.opacity(0.1) : colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                                    .onTapGesture{
                                        selectedMeet = meet
                                        showingMeetsOverlay = false
                                    }
                                    
                                    Divider()
                                }
                            }
                        }
                    }
                    .frame(maxWidth: 350)
                    .frame(maxHeight: 550)
                    .background(colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    .shadow(radius: 20)
                    .padding(.horizontal, 30)
                    .toolbar(.hidden, for: .tabBar)
                    .refreshable{
                        await viewModel.loadMeets()
                    }
                }
            }
        )
    }
}

private struct DaySessionsView: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("selectedMeet") private var selectedMeet: String = ""
    
    let day: Date
    let schedule: [ScheduleRow]
    let meetDetails: [MeetDetailsRow]
    let isLoading: Bool
    
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
        let timeZone = meetDetails.first(where: { $0.name == selectedMeet })?.time_zone ?? "Unknown"
        
        switch timeZone {
        case "America/New_York": return "Eastern"
        case "America/Los_Angeles": return "Pacific"
        case "America/Denver": return "Mountain"
        default: return "Central"
        }
    }
    
    var body: some View {
        List {
            ForEach(Array(schedule.enumerated()), id: \.element.id) { index, row in
                if schedule.firstIndex(where: {$0.session_id == row.session_id}) == index {
                    let rowsInSession = schedule.filter{$0.session_id == row.session_id}
                    let platformColors = [1: "Red", 2: "White", 3: "Blue", 4: "Stars", 5: "Stripes", 6: "Rogue"]
                    
                    let dataSorted = rowsInSession.sorted {first, second in
                        let firstPlatform = first.platform
                        let secondPlatform = second.platform
                        
                        let firstKey = platformColors.first(where: { $0.value == firstPlatform })?.key ?? Int.max
                        let secondKey = platformColors.first(where: { $0.value == secondPlatform })?.key ?? Int.max
                        
                        return firstKey < secondKey
                    }
                    
                    Section(
                        header: Text("Session \(row.session_id)")
                            .foregroundStyle(colorScheme == .light ? .black : .white)
                    ) {
                        ForEach(dataSorted, id: \.id) { sched in
                            NavigationLink(destination: ScheduleDetailsView(meet: sched.meet ?? "TBD", date: sched.date, sessionNum: sched.session_id, platformColor: sched.platform, weightClass: sched.weight_class, startTime: sched.start_time)) {
                                HStack {
                                    Platform(text: sched.platform)
                                    
                                    VStack(alignment: .leading) {
                                        Text(sched.weight_class)
                                            .padding(.bottom, 2)
                                        Text("Start: \(convert24hourTo12hour(time24hour: sched.start_time) ?? "No Time Data") \(timeZoneShortHand())")
                                    }
                                    .font(.system(size: 16))
                                    .padding(.leading, 10)
                                    .foregroundStyle(colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                                }
                            }
                        }
                    }
                }
                //            .padding(.top, 4)
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .listStyle(.insetGrouped)
            .navigationTitle(isLoading ? "Loading..." : day.formatted(date: .complete, time: .omitted))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ScheduleView()
}
