//
//  ScheduleView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/1/25.
//

import SwiftUI

struct Session: Identifiable {
    let id: Int
    let date: Date
    let groups: [Group]

    struct Group: Identifiable {
        let id = UUID()
        let platform: String
        let weightClass: String
        let startTime: Date
    }
}

struct ScheduleView: View {
    @StateObject private var viewModel = MeetsScheduleModel()
    @State private var showingMeetsOverlay: Bool = false
    @State private var selectedMeet: String = ""
    @State private var platformColor: String = ""
    

    private let staticSessions: [Session] = {
        func makeDate(year: Int, month: Int, day: Int) -> Date {
            var comps = DateComponents()
            comps.year = year
            comps.month = month
            comps.day = day
            return Calendar.current.date(from: comps) ?? Date()
        }
        func makeTime(on day: Date, hour: Int, minute: Int) -> Date {
            var comps = Calendar.current.dateComponents([.year, .month, .day], from: day)
            comps.hour = hour
            comps.minute = minute
            return Calendar.current.date(from: comps) ?? day
        }
        let d1 = makeDate(year: 2025, month: 8, day: 9)
        let d2 = makeDate(year: 2025, month: 8, day: 10)
        let d3 = makeDate(year: 2025, month: 8, day: 11)
        return [
            Session(
                id: 1,
                date: d1,
                groups: [
                    .init(platform: "Red",  weightClass: "88kg", startTime: makeTime(on: d1, hour: 9,  minute: 0)),
                    .init(platform: "Blue", weightClass: "94kg", startTime: makeTime(on: d1, hour: 9,  minute: 0)),
                ]
            ),
            Session(
                id: 2,
                date: d1,
                groups: [
                    .init(platform: "Red",  weightClass: "60kg", startTime: makeTime(on: d1, hour: 13, minute: 0)),
                    .init(platform: "Blue", weightClass: "71kg", startTime: makeTime(on: d1, hour: 13, minute: 0)),
                ]
            ),
            Session(
                id: 3,
                date: d2,
                groups: [
                    .init(platform: "Red",  weightClass: "60kg", startTime: makeTime(on: d2, hour: 9,  minute: 0)),
                    .init(platform: "Blue", weightClass: "71kg", startTime: makeTime(on: d2, hour: 9,  minute: 0)),
                ]
            ),
            Session(
                id: 4,
                date: d2,
                groups: [
                    .init(platform: "Red",  weightClass: "60kg", startTime: makeTime(on: d2, hour: 13, minute: 0)),
                    .init(platform: "Blue", weightClass: "71kg", startTime: makeTime(on: d2, hour: 13, minute: 0)),
                ]
            ),
            Session(
                id: 5,
                date: d3,
                groups: [
                    .init(platform: "Red",  weightClass: "60kg", startTime: makeTime(on: d3, hour: 9,  minute: 0)),
                    .init(platform: "Blue", weightClass: "71kg", startTime: makeTime(on: d3, hour: 9,  minute: 0)),
                ]
            ),
            Session(
                id: 6,
                date: d3,
                groups: [
                    .init(platform: "Red",  weightClass: "60kg", startTime: makeTime(on: d3, hour: 13, minute: 0)),
                    .init(platform: "Blue", weightClass: "71kg", startTime: makeTime(on: d3, hour: 13, minute: 0)),
                ]
            ),
        ]
    }()
    
    var meets: [String] { viewModel.meets }
    
    private var sessionsByDay: [(day: Date, sessions: [Session])] {
        let grouped = Dictionary(grouping: staticSessions) { session in
            Calendar.current.startOfDay(for: session.date)
        }
        return grouped
            .map { ($0.key, $0.value.sorted { $0.id < $1.id }) }
            .sorted { $0.0 < $1.0 }
    }

    var body: some View {
        NavigationStack{
            VStack {
                ZStack {
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
                    .background(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .onTapGesture {
                        showingMeetsOverlay = true
                    }
                }
                .frame(height: 100)

                if sessionsByDay.isEmpty {
                    Text("No sessions available")
                        .secondaryText()
                        .padding()
                } else {
                    TabView {
                        ForEach(Array(sessionsByDay.enumerated()), id: \.offset) { _, item in
                            DaySessionsView(day: item.day, sessions: item.sessions)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .automatic))
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .onAppear{
                UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.systemBlue
                UIPageControl.appearance().pageIndicatorTintColor = UIColor.systemBlue.withAlphaComponent(0.2)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(destination: CompDataView()) {
                        Image(systemName: "list.bullet")
                    }
                }
            }
        }
        .task {
            await viewModel.loadMeets()
            if selectedMeet.isEmpty, let first = viewModel.meets.first {
                selectedMeet = first
            }
        }
        .task {
            await viewModel.loadMeetSchedule(meet: selectedMeet)
        }
        .onChange(of: selectedMeet) {
            Task {
                await viewModel.loadMeetSchedule(meet: selectedMeet)
            }
        }
        .overlay(
            Group {
                if showingMeetsOverlay {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture { showingMeetsOverlay = false }
                    
                    ScrollView {
                        VStack(spacing: 0) {
                            Text("Select Your Meet")
                                .font(.headline)
                                .padding()
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(meets, id: \.self) { meet in
                                    HStack {
                                        Text(meet)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading, 0)
                                            .padding()
                                            .foregroundStyle(meet == selectedMeet ? Color.blue : Color.black)
                                        Spacer()
                                        if meet == selectedMeet {
                                            Image(systemName: "checkmark")
                                                .foregroundStyle(.blue)
                                        }
                                        Spacer()
                                    }
                                    .background(meet == selectedMeet ? Color.gray.opacity(0.1) : Color.white)
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
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(radius: 20)
                    .padding(.horizontal, 30)
                }
            }
        )
    }
}

private struct DaySessionsView: View {
    let day: Date
    let sessions: [Session]
    
    private var timeFormatter: DateFormatter {
        let f = DateFormatter()
        f.timeStyle = .short
        f.dateStyle = .none
        return f
    }
    
    var body: some View {
        List {
            ForEach(sessions) { session in
                Section(
                    header: Text("Session \(session.id)")
                        .foregroundStyle(.black)
                ) {
                    ForEach(session.groups) { group in
                        NavigationLink(destination: ScheduleDetailsView()) {
                            HStack {
                                Platform(text: group.platform)
                                
                                VStack(alignment: .leading) {
                                    Text(group.weightClass)
                                        .padding(.vertical, 2)
                                    Text("Start: \(timeFormatter.string(from: group.startTime))")
                                        .padding(.vertical, 2)
                                }
                                .padding(.leading, 10)
                                .secondaryText()
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(day.formatted(date: .complete, time: .omitted))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ScheduleView()
}
