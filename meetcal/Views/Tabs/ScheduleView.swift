//
//  ScheduleView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/1/25.
//

import SwiftUI

struct ScheduleView: View {
    @StateObject private var viewModel = MeetsScheduleModel()
    @State private var showingMeetsOverlay: Bool = false
    @State private var selectedMeet: String = ""
    @State private var platformColor: String = ""
    
    var schedule: [ScheduleRow] { viewModel.schedule }
    var meets: [String] { viewModel.meets }
    
    private var uniqueDays: [Date] {
        let calendar = Calendar.current
        let days = schedule.map { calendar.startOfDay(for: $0.date)}
        let unique = Array(Set(days))
        return unique.sorted()
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

                //need to fix the padding for this. gray bar around tab bar. ignoring safe area then wont scroll up the whole way
                TabView {
                    ForEach(uniqueDays, id: \.self) { day in
                        let calendar = Calendar.current
                        let rowsForDay = schedule.filter{ calendar.isDate($0.date, inSameDayAs: day )}
                        DaySessionsView(day: day, schedule: rowsForDay)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))
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
    let schedule: [ScheduleRow]
    
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
                            .foregroundStyle(.black)
                    ) {
                        ForEach(dataSorted, id: \.id) { sched in
                            NavigationLink(destination: ScheduleDetailsView()) {
                                HStack {
                                    Platform(text: sched.platform)
                                    
                                    VStack(alignment: .leading) {
                                        Text(sched.weight_class)
                                            .padding(.vertical, 2)
                                        Text("Start: \(sched.start_time)")
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
        }
        .listStyle(.insetGrouped)
        .navigationTitle(day.formatted(date: .complete, time: .omitted))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ScheduleView()
}
