//
//  NationalRankings.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 10/4/25.
//

import SwiftUI
import Combine
import Supabase

struct NationalRankingsView: View {
    @StateObject private var viewModel = NationalRankingsModel()
    @StateObject private var customerManager = CustomerInfoManager()
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var modelContext

    @State private var isModalShowing: Bool = false
    @State private var isModal1DropdownShowing: Bool = false
    @State private var isModal2DropdownShowing: Bool = false
    @State private var isModal3DropdownShowing: Bool = false

    @State private var appliedGender: String = "Men"
    @State private var appliedAge: String = "Senior"
    @State private var appliedClass: String = "Open Men's 60kg"

    @State private var draftGender: String = "Men"
    @State private var draftAge: String = "Senior"
    @State private var draftClass: String = "Open Men's 60kg"

    @State private var availableWeightClasses: [String] = []
    
    var results: [AthleteResults] { viewModel.rankings }

    let ageGroups = [
        "U11", "U13", "U15", "U17", "Junior", "Senior",
        "Masters 35", "Masters 40", "Masters 45", "Masters 50", "Masters 55",
        "Masters 60", "Masters 65", "Masters 70", "Masters 75", "Masters 80",
        "Masters 85", "Masters 90+"
    ]

    func getWeightClasses(for gender: String, ageGroup: String) -> [String] {
        let prefix: String

        switch ageGroup {
        case "U11":
             prefix = "\(gender)'s 11 Under Age Group"
        case "U13":
            prefix = "\(gender)'s 13 Under Age Group"
        case "U15":
            prefix = "\(gender)'s 14-15 Age Group"
        case "U17":
            prefix = "\(gender)'s 16-17 Age Group"
        case "Junior":
            prefix = "Junior \(gender)"
        case "Senior":
            prefix = "Open \(gender)"
        case "Masters 35":
            prefix = "\(gender)'s Masters (35-39)"
        case "Masters 40":
            prefix = "\(gender)'s Masters (40-44)"
        case "Masters 45":
            prefix = "\(gender)'s Masters (45-49)"
        case "Masters 50":
            prefix = "\(gender)'s Masters (50-54)"
        case "Masters 55":
            prefix = "\(gender)'s Masters (55-59)"
        case "Masters 60":
            prefix = "\(gender)'s Masters (60-64)"
        case "Masters 65":
            prefix = "\(gender)'s Masters (65-69)"
        case "Masters 70":
            prefix = "\(gender)'s Masters (70-74)"
        case "Masters 75":
            prefix = "\(gender)'s Masters (75-79)"
        case "Masters 80":
            prefix = "\(gender)'s Masters (80-84)"
        case "Masters 85":
            prefix = "\(gender)'s Masters (85-89)"
        case "Masters 90+":
            prefix = "\(gender)'s Masters (90+)"

        default:
            prefix = "Open \(gender)"
        }

        switch (gender, ageGroup) {
        case ("Men", "Masters 35"), ("Men", "Masters 40"), ("Men", "Masters 45"), ("Men", "Masters 50"), ("Men", "Masters 55"), ("Men", "Masters 60"), ("Men", "Masters 65"), ("Men", "Masters 70"), ("Men", "Masters 75"), ("Men", "Masters 80"), ("Men", "Masters 85"), ("Men", "Masters 90+"):
            return ["60kg", "65kg", "71kg", "79kg", "88kg", "94kg", "110kg", "110+kg"].map { "\(prefix) \($0)" }
        case ("Women", "Masters 35"), ("Women", "Masters 40"), ("Women", "Masters 45"), ("Women", "Masters 50"), ("Women", "Masters 55"), ("Women", "Masters 60"), ("Women", "Masters 65"), ("Women", "Masters 70"), ("Women", "Masters 75"), ("Women", "Masters 80"), ("Women", "Masters 85"), ("Women", "Masters 90+"):
            return ["48kg", "53kg", "58kg", "63kg", "69kg", "77kg", "86kg", "86+kg"].map { "\(prefix) \($0)" }
        case ("Men", "Junior"), ("Men", "Senior"):
            return ["60kg", "65kg", "71kg", "79kg", "88kg", "94kg", "110kg", "110+kg"].map { "\(prefix)'s \($0)" }
        case ("Women", "Junior"), ("Women", "Senior"):
            return ["48kg", "53kg", "58kg", "63kg", "69kg", "77kg", "86kg", "86+kg"].map { "\(prefix)'s \($0)" }
        case ("Men", "U17"):
            return ["56kg", "60kg", "65kg", "71kg", "79kg", "88kg", "94kg", "94+kg"].map { "\(prefix) \($0)" }
        case ("Women", "U17"):
            return ["44kg", "48kg", "53kg", "58kg", "63kg", "69kg", "77kg", "77+kg"].map { "\(prefix) \($0)" }
        case ("Men", "U15"):
            return ["48kg", "52kg", "56kg", "60kg", "65kg", "71kg", "79kg", "79+kg"].map { "\(prefix) \($0)" }
        case ("Women", "U15"):
            return ["40kg", "44kg", "48kg", "53kg", "58kg", "63kg", "69kg", "69+kg"].map { "\(prefix) \($0)" }
        case ("Men", "U13"), ("Men", "U11"):
            return ["40kg", "44kg", "48kg", "52kg", "56kg", "60kg", "65kg", "65+kg"].map { "\(prefix) \($0)" }
        case ("Women", "U13"), ("Women", "U11"):
            return ["36kg", "40kg", "44kg", "48kg", "53kg", "58kg", "63kg", "63+kg"].map { "\(prefix) \($0)" }
        default:
            return []
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack {
                    HStack {
                        Spacer()
                       
                        Text("\(appliedClass)")
                            .foregroundStyle(colorScheme == .light ? .black : .white)
                            .bold()
                        Image(systemName: "chevron.down")
                            .foregroundStyle(colorScheme == .light ? .black : .white)
                            .bold()
                        
                        Spacer()
                    }
                    .cardStyling()
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .onTapGesture {
                        draftAge = appliedAge
                        draftGender = appliedGender
                        draftClass = appliedClass
                        isModalShowing = true
                    }
                    
                    Divider()
                        .padding(.top)
                        .padding(.bottom, 2)
                    
                    
                    VStack {
                        if viewModel.isLoading {
                            VStack {
                                Spacer()
                                ProgressView("Loading...")
                                Spacer()
                            }
                            .padding(.top, -10)
                        } else {
                            List {
                                HStack {
                                    Text("Rank")
                                        .frame(width: 40, alignment: .leading)
                                    Spacer()
                                    Text("Name")
                                        .frame(width: 150, alignment: .leading)
                                    Spacer()
                                    Text("Total")
                                        .frame(width: 70, alignment: .leading)
                                }
                                .bold()
                                .foregroundStyle(colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)

                                ForEach(Array(results.enumerated()), id: \.element.name) { index, athlete in
                                    HStack {
                                        Text("\(index + 1)")
                                            .frame(width: 40, alignment: .leading)
                                        Spacer()
                                        Text(athlete.name)
                                            .frame(width: 150, alignment: .leading)
                                        Spacer()
                                        Text("\(Int(athlete.total))kg")
                                            .frame(width: 70, alignment: .leading)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, -10)
                    
                }
            }
            .navigationTitle("National Rankings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .tabBar)
        }
        .task {
            viewModel.setModelContext(modelContext)
            AnalyticsManager.shared.trackScreenView("National Rankings")
            AnalyticsManager.shared.trackRankingsViewed(filters: ["gender": appliedGender, "age": appliedAge, "class": appliedClass])

            availableWeightClasses = getWeightClasses(for: appliedGender, ageGroup: appliedAge)
            viewModel.rankings.removeAll()
            await viewModel.loadWeightClasses(age: appliedClass)
            await customerManager.fetchCustomerInfo()
        }
        .onChange(of: draftGender) {
            availableWeightClasses = getWeightClasses(for: draftGender, ageGroup: draftAge)
            if !availableWeightClasses.isEmpty {
                appliedClass = availableWeightClasses[0]
                draftClass = availableWeightClasses[0]
            }
        }
        .onChange(of: draftAge) {
            availableWeightClasses = getWeightClasses(for: draftGender, ageGroup: draftAge)
            if !availableWeightClasses.isEmpty {
                appliedClass = availableWeightClasses[0]
                draftClass = availableWeightClasses[0]
            }
        }
        .onChange(of: appliedClass) {
            Task {
                viewModel.rankings.removeAll()
                await viewModel.loadWeightClasses(age: appliedClass)
            }
        }
        .overlay(RankingsFilter(
            isModalShowing: $isModalShowing,
            isModal1DropdownShowing: $isModal1DropdownShowing,
            isModal2DropdownShowing: $isModal2DropdownShowing,
            isModal3DropdownShowing: $isModal3DropdownShowing,
            selectedGender: $appliedGender,
            selectedAge: $appliedAge,
            selectedClass: $appliedClass,
            draftGender: $draftGender,
            draftAge: $draftAge,
            draftClass: $draftClass,
            ageGroups: ageGroups,
            classes: availableWeightClasses,
            onApply: {
                appliedGender = draftGender
                appliedAge = draftAge
                appliedClass = draftClass

                AnalyticsManager.shared.trackFiltersApplied(
                    type: "national_rankings",
                    values: ["gender": appliedGender, "age": appliedAge, "class": appliedClass]
                )

                isModalShowing = false
            }
        ))
    }
}

struct RankingsFilter: View {
    @Environment(\.colorScheme) var colorScheme

    @Binding var isModalShowing: Bool
    @Binding var isModal1DropdownShowing: Bool
    @Binding var isModal2DropdownShowing: Bool
    @Binding var isModal3DropdownShowing: Bool
    
    @Binding var selectedGender: String
    @Binding var selectedAge: String
    @Binding var selectedClass: String
    
    @Binding var draftGender: String
    @Binding var draftAge: String
    @Binding var draftClass: String
    
    let genders: [String] = ["Men", "Women"]
    var ageGroups: [String]
    var classes: [String]
    var onApply: () -> Void
    
    var body: some View {
        Group {
            if isModalShowing {
                Color(colorScheme == .light ? .black.opacity(0.4) : .black.opacity(0.7))
                    .ignoresSafeArea()
                    .onTapGesture {
                        isModalShowing = false
                        isModal1DropdownShowing = false
                        isModal2DropdownShowing = false
                        isModal3DropdownShowing = false
                    }
                
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Gender")
                                .secondaryText()
                                .padding(.bottom, 0.5)
                            Text(draftGender.isEmpty ? selectedGender : draftGender)
                        }
                        Spacer()
                        Image(systemName: isModal1DropdownShowing ? "chevron.down" : "chevron.right")
                    }
                    .padding()
                    .background(colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isModal1DropdownShowing.toggle()
                        isModal2DropdownShowing = false
                        isModal3DropdownShowing = false
                    }
                    
                    if isModal1DropdownShowing {
                        if genders.count > 6 {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 0) {
                                    Divider()
                                    
                                    ForEach(genders, id: \.self) { gender in
                                        HStack {
                                            Button(action: {
                                                draftGender = gender
                                                isModal1DropdownShowing = false
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
                                            isModal1DropdownShowing = false
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
                            Text("Age Group")
                                .secondaryText()
                                .padding(.bottom, 0.5)
                            Text(draftAge.isEmpty ? selectedAge.capitalized : draftAge.capitalized)
                        }
                        Spacer()
                        Image(systemName: isModal2DropdownShowing ? "chevron.down" : "chevron.right")
                    }
                    .padding()
                    .background(colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isModal2DropdownShowing.toggle()
                        isModal3DropdownShowing = false
                        isModal1DropdownShowing = false
                    }
                    
                    if isModal2DropdownShowing {
                        if ageGroups.count > 6 {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 0) {
                                    Divider()
                                    
                                    ForEach(ageGroups, id: \.self) { age in
                                        HStack {
                                            Button(action: {
                                                draftAge = age
                                                isModal2DropdownShowing = false
                                            }) {
                                                Text(age.capitalized)
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
                                            isModal2DropdownShowing = false
                                        }) {
                                            Text(age.capitalized)
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
                            Text("Weight Class")
                                .secondaryText()
                                .padding(.bottom, 0.5)
                            Text(draftClass.isEmpty ? selectedClass : draftClass)
                        }
                        Spacer()
                        Image(systemName: isModal3DropdownShowing ? "chevron.down" : "chevron.right")
                    }
                    .padding()
                    .background(colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isModal3DropdownShowing.toggle()
                        isModal2DropdownShowing = false
                        isModal1DropdownShowing = false
                    }
                                        
                    if isModal3DropdownShowing {
                        if classes.count > 6 {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 0) {
                                    Divider()
                                    
                                    ForEach(classes, id: \.self) { meet in
                                        HStack {
                                            Button(action: {
                                                draftClass = meet
                                                isModal3DropdownShowing = false
                                            }) {
                                                Text(meet)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding(.leading, 0)
                                                    .padding()
                                                    .foregroundStyle(meet == draftClass ? Color.blue : colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                                            }
                                            
                                            
                                            Spacer()
                                            if meet == draftClass {
                                                Image(systemName: "checkmark")
                                                    .foregroundStyle(.blue)
                                            }
                                            Spacer()
                                        }
                                        .background(meet == draftClass ? .gray.opacity(0.2) : colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                                        
                                        Divider()
                                    }
                                }
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 0) {
                                Divider()
                                
                                ForEach(classes, id: \.self) { meet in
                                    HStack {
                                        Button(action: {
                                            draftClass = meet
                                            isModal3DropdownShowing = false
                                        }) {
                                            Text(meet)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.leading, 0)
                                                .padding()
                                                .foregroundStyle(meet == draftClass ? Color.blue : colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                                        }
                                        
                                        
                                        Spacer()
                                        if meet == draftClass {
                                            Image(systemName: "checkmark")
                                                .foregroundStyle(.blue)
                                        }
                                        Spacer()
                                    }
                                    .background(meet == draftClass ? .gray.opacity(0.2) : colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
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
    NationalRankingsView()
}

