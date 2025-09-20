//
//  ScheduleView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/1/25.
//

import SwiftUI

struct StartListView: View {
    @AppStorage("selectedMeet") private var selectedMeet = ""
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = StartListModel()
    
    @State var isAgeDropdownShowing: Bool = false
    @State var isWeightDropdownShowing: Bool = false
    @State var isGenderDropdownShowing: Bool = false
    @State var isClubDropdownShowing: Bool = false
    @State var isAdapDropdownShowing: Bool = false
    
    @State var selectedAge: String = "Senior"
    @State var selectedWeight: Int = 60
    @State var selectedGender: String = "Men"
    @State var selectedClub: String = "All Clubs"
    @State var selectedAdap: String = "All Athletes"
    
    @State var draftAge: String = "Senior"
    @State var draftWeight: Int = 60
    @State var draftGender: String = "Men"
    @State var draftClub: String = "All Clubs"
    @State var draftAdap: String = "All Athletes"
    
    @State private var searchText: String = ""
    @State private var saveButtonClicked: Bool = false
    @State private var filterClicked: Bool = false
    
    var athleteList: [AthleteRow] { viewModel.athletes }
    var scheduleList: [ScheduleRow] { viewModel.schedule }
    var weightClass: [AthleteRow] { viewModel.weightClass }
    var ages: [AthleteRow] { viewModel.ages }
    let ageGroups: [String] = ["Senior"]
    
    var filteredAthletes: [AthleteRow] {
        guard !searchText.isEmpty else { return athleteList }
        return athleteList.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
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
                        AthleteDisclosureRow(
                            athlete: athlete,
                            schedule: matchSchedule(for: athlete),
                            dateTimeText: matchSchedule(for: athlete).map(displayDateTime(for:)) ?? "TBD",
                            colorScheme: colorScheme
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
                    selectedAge: $selectedAge,
                    selectedWeight: $selectedWeight,
                    selectedGender: $selectedGender,
                    selectedClub: $selectedClub,
                    selectedAdap: $selectedAdap,
                    draftAge: $draftAge,
                    draftWeight: $draftWeight,
                    draftGender: $draftGender,
                    draftClub: $draftClub,
                    draftAdap: $draftAdap,
                    ageGroups: ageGroups,
                    meets: ["Nationals"],
                    onApply: {}
                )
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

private struct AthleteDisclosureRow: View {
    let athlete: AthleteRow
    let schedule: ScheduleRow?
    let dateTimeText: String
    let colorScheme: ColorScheme
    
    var body: some View {
        DisclosureGroup(athlete.name) {
            VStack(spacing: 20) {
                HStack {
                    Text("Session:")
                        .foregroundStyle(colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                    
                    Spacer()
                    NavigationLink(destination: ScheduleDetailsView()) {
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

struct FilterModal: View {
    @Environment(\.colorScheme) var colorScheme

    @Binding var isShowing: Bool
    @Binding var isAgeDropdownShowing: Bool
    @Binding var isWeightDropdownShowing: Bool
    @Binding var isGenderDropdownShowing: Bool
    @Binding var isClubDropdownShowing: Bool
    @Binding var isAdapDropdownShowing: Bool
    
    @Binding var selectedAge: String
    @Binding var selectedWeight: Int
    @Binding var selectedGender: String
    @Binding var selectedClub: String
    @Binding var selectedAdap: String
    
    @Binding var draftAge: String
    @Binding var draftWeight: Int
    @Binding var draftGender: String
    @Binding var draftClub: String
    @Binding var draftAdap: String
    
    let genders: [String] = ["Men", "Women"]
    let adaptive: [String] = ["All Athletes", "Adaptive Athletes", "Non-Adaptive Athletes"]
    let ageGroups: [String]
    let club: [String] = ["P&G", "1kilo"]
    let weightClass: [Int] = [60, 45, 110]
    var meets: [String]
    var onApply: () -> Void
    
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
                    }
                
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Age Groups")
                                .secondaryText()
                                .padding(.bottom, 0.5)
                            Text(draftAge.isEmpty ? selectedAge : draftAge)
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
                        if ageGroups.count > 6 {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 0) {
                                    Divider()
                                    
                                    ForEach(ageGroups, id: \.self) { age in
                                        HStack {
                                            Button(action: {
                                                draftAge = age
                                                isAgeDropdownShowing = false
                                            }) {
                                                Text(age)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding(.leading, 0)
                                                    .padding()
                                                    .foregroundStyle(age == draftAge ? Color.blue : colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                                            }
                                            
                                            
                                            Spacer()
                                            if age == draftAge {
                                                Image(systemName: "checkmark")
                                                    .foregroundStyle(.blue)
                                            }
                                            Spacer()
                                        }
                                        .background(age == draftAge ? .gray.opacity(0.2) : colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                                        
                                        Divider()
                                    }
                                }
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 0) {
                                Divider()
                                
                                ForEach(ageGroups, id: \.self) { age in
                                    HStack {
                                        Button(action: {
                                            draftAge = age
                                            isAgeDropdownShowing = false
                                        }) {
                                            Text(age)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.leading, 0)
                                                .padding()
                                                .foregroundStyle(age == draftAge ? Color.blue : colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                                        }
                                        
                                        
                                        Spacer()
                                        if age == draftAge {
                                            Image(systemName: "checkmark")
                                                .foregroundStyle(.blue)
                                        }
                                        Spacer()
                                    }
                                    .background(age == draftAge ? .gray.opacity(0.2) : colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
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
                        if genders.count > 6 {
                            ScrollView {
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
                        } else {
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
                    }
                    
                    Divider()
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Weight Class")
                                .secondaryText()
                                .padding(.bottom, 0.5)
                            Text("\(String(draftWeight == 0 ? selectedWeight : draftWeight))kg")
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
                                    
                                    ForEach(weightClass, id: \.self) { weight in
                                        HStack {
                                            Button(action: {
                                                draftWeight = weight
                                                isWeightDropdownShowing = false
                                            }) {
                                                Text("\(String(weight))kg")
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
                                
                                ForEach(weightClass, id: \.self) { weight in
                                    HStack {
                                        Button(action: {
                                            draftWeight = weight
                                            isWeightDropdownShowing = false
                                        }) {
                                            Text("\(String(weight))kg")
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
                        if club.count > 6 {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 0) {
                                    Divider()
                                    
                                    ForEach(club, id: \.self) { team in
                                        HStack {
                                            Button(action: {
                                                draftClub = team
                                                isClubDropdownShowing = false
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
                                }
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 0) {
                                Divider()
                                
                                ForEach(club, id: \.self) { team in
                                    HStack {
                                        Button(action: {
                                            draftClub = team
                                            isClubDropdownShowing = false
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
                        if adaptive.count > 6 {
                            ScrollView {
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
                        } else {
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
