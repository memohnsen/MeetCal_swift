//
//  ScheduleView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/1/25.
//

import SwiftUI

struct StartListView: View {
    @AppStorage("selectedMeet") private var selectedMeet = ""
    @StateObject private var viewModel = StartListModel()
    
    @State private var searchText: String = ""
    
    var athleteList: [AthleteRow] { viewModel.athletes }
    var scheduleList: [ScheduleRow] { viewModel.schedule }
    
    var filteredAthletes: [AthleteRow] {
        guard !searchText.isEmpty else { return athleteList }
        return athleteList.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    private func matchSchedule(for athlete: AthleteRow) -> ScheduleRow? {
        scheduleList.first {
            $0.session_id == athlete.session_number && $0.platform == athlete.session_platform
        }
    }
    
    private func displayDateTime(for row: ScheduleRow) -> String {
        let dateText = row.date.formatted(date: .abbreviated, time: .omitted)
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "HH:mm:ss"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "h:mm a"
        outputFormatter.locale = Locale(identifier: "America/Los_Angeles")
        
        var timeText = "No Time"
        if let date = inputFormatter.date(from: row.start_time) {
            timeText = outputFormatter.string(from: date)
        }
        
        let tzAbbrev = TimeZone.current.abbreviation() ?? ""
        return "\(dateText) • \(timeText) \(tzAbbrev)"
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(filteredAthletes, id: \.member_id) { athlete in
                        DisclosureGroup(athlete.name) {
                            VStack(spacing: 20) {
                                HStack {
                                    Text("Session:")
                                        .secondaryText()

                                    Spacer()
                                    NavigationLink(destination: ScheduleDetailsView()) {
                                        Spacer()
                                        Spacer()
                                        Spacer()
                                        Spacer()
                                        Spacer()
                                        Text("Session \(athlete.session_number) • \(athlete.session_platform) Platform")
                                            .foregroundStyle(.blue)
                                    }
                                }
                                HStack {
                                    Text("Date & Time:")
                                        .secondaryText()
                                    
                                    Spacer()
                                    if let row = matchSchedule(for: athlete) {
                                        Text(displayDateTime(for: row))
                                    } else {
                                        Text("TBD")
                                    }
                                }
                                HStack {
                                    Text("Club:")
                                        .secondaryText()
                                    
                                    Spacer()
                                    Text(athlete.club)
                                }
                                HStack {
                                    Text("Weight Class:")
                                        .secondaryText()
                                    
                                    Spacer()
                                    Text(athlete.weight_class)
                                }
                                HStack {
                                    Text("Age:")
                                        .secondaryText()
                                    
                                    Spacer()
                                    Text(String(athlete.age))
                                }
                                HStack {
                                    Text("Entry Total:")
                                        .secondaryText()
                                    
                                    Spacer()
                                    Text(String(athlete.entry_total))
                                }
                                                        
                                HStack {
                                    VStack {
                                        Divider()
                                            .padding(.vertical, 6)
                                        
                                        Text("Best Lifts From The Last Year")
                                            .padding(.bottom, 10)
                                        
                                        HStack {
                                            VStack {
                                                Text("Snatch")
                                                    .secondaryText()
                                                Text("120")
                                                    .bold()
                                            }
                                            
                                            Spacer()
                                            
                                            VStack {
                                                Text("CJ")
                                                    .secondaryText()
                                                Text("160")
                                                    .bold()
                                            }
                                            
                                            Spacer()
                                            
                                            VStack {
                                                Text("Total")
                                                    .secondaryText()
                                                Text("280")
                                                    .bold()
                                            }
                                        }
                                        .frame(width: 220)
                                        
                                        HStack {
                                            Text("See All Meet Results")
                                            Image(systemName: "chevron.right")
                                        }
                                        .padding(.top, 10)
                                        .foregroundStyle(.blue)
                                    }
                                }
                            }
                            .padding(.leading, -20)
                        }
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
                }
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: "line.3.horizontal.decrease")
                }
            }
        }
        .task{
            await viewModel.loadStartList(meet: selectedMeet)
            await viewModel.loadMeetSchedule(meet: selectedMeet)
        }
        .onChange(of: selectedMeet) {
            Task {
                await viewModel.loadStartList(meet: selectedMeet)
                await viewModel.loadMeetSchedule(meet: selectedMeet)
            }
        }
    }
}

#Preview {
    StartListView()
}

