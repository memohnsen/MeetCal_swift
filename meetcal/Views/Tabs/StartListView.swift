//
//  ScheduleView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/1/25.
//

import SwiftUI

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
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(filteredAthletes, id: \.member_id) { athlete in
                        AthleteDisclosureRow(
                            athlete: athlete,
                            schedule: matchSchedule(for: athlete),
                            dateTimeText: matchSchedule(for: athlete).map(displayDateTime(for:)) ?? "TBD",
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
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Save Sessions")
                                    Text("Save X sessions in the app")
                                        .foregroundStyle(colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .onTapGesture{
                                
                            }
                            
                            Divider()
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Save to Calendar")
                                    Text("Save X sessions directly to your iCal")
                                        .foregroundStyle(colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .onTapGesture{
                                
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
    
    // Computed properties to get best lifts for this athlete
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
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Text("Session \(athlete.session_number ?? 0) • \(athlete.session_platform ?? "TBD") Platform")
                            .foregroundStyle(.blue)
                    }
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
                        
                        NavigationLink(destination: MeetResultsView(name: athlete.name)) {
                            HStack {
                                Spacer()
                                Spacer()
                                Spacer()
                                Text("See All Meet Results")
                                Spacer()
                                Spacer()
                            }
                        }
                        .padding(.top, 10)
                        .foregroundStyle(.blue)
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
