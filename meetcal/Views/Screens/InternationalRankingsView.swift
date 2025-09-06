//
//  InternationalRankingsView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/5/25.
//

import SwiftUI

struct Rankings: Hashable {
    let id = UUID()
    let lastName: String
    let weightClass: String
    let total: String
    let percentA: String
}

struct InternationalRankingsView: View {
    @State private var isModalShowing: Bool = false
    @State private var isModal1DropdownShowing: Bool = false
    @State private var isModal2DropdownShowing: Bool = false
    @State private var isModal3DropdownShowing: Bool = false
    
    @State var selectedGender: String = "Men"
    @State var selectedAge: String = "Senior"
    @State var selectedMeet: String = "2025 Worlds"
    
    let genders: [String] = ["Men", "Women"]
    let ageGroups: [String] = ["U13", "U15", "U17", "Junior", "Senior"]
    let meets: [String] = ["2025 Worlds", "2025 Pan Ams"]
    
    let rankings = [
        Rankings(lastName: "Morris", weightClass: "67kg", total: "313", percentA: "105.03%"),
        Rankings(lastName: "Morris", weightClass: "67kg", total: "313", percentA: "105.03%"),
        Rankings(lastName: "Morris", weightClass: "67kg", total: "313", percentA: "105.03%"),
        Rankings(lastName: "Morris", weightClass: "67kg", total: "313", percentA: "105.03%"),
        Rankings(lastName: "Morris", weightClass: "67kg", total: "313", percentA: "105.03%"),
        Rankings(lastName: "Morris", weightClass: "67kg", total: "313", percentA: "105.03%"),
        Rankings(lastName: "Morris", weightClass: "67kg", total: "313", percentA: "105.03%"),
        Rankings(lastName: "Morris", weightClass: "67kg", total: "313", percentA: "105.03%"),
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack {
                    FilterButton(filter1: selectedMeet, filter2: selectedAge, filter3: selectedGender, action: {isModalShowing = true})
                    
                    Divider()
                        .padding(.top)
                        .padding(.bottom, 2)
                    
                    
                    VStack {
                        List {
                            HStack {
                                Text("Class")
                                    .frame(width: 90, alignment: .leading)
                                Text("Name")
                                Spacer()
                                Spacer()
                                Spacer()
                                Text("Total")
                                Spacer()
                                Spacer()
                                Spacer()
                                Text("% of A")
                                Spacer()
                                Spacer()
                            }
                            .bold()
                            .secondaryText()
                            
                            ForEach(rankings, id: \.self) { ranking in
                                HStack {
                                    DataSectionView(weightClass: ranking.weightClass, data: ranking.lastName, width: 90)
                                    Text(ranking.total)
                                    Spacer()
                                    Spacer()
                                    Spacer()
                                    Spacer()
                                    Spacer()
                                    Text(ranking.percentA)
                                    Spacer()
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding(.top, -10)
                    
                    Spacer()
                }
            }
            .navigationTitle("International Rankings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .overlay(QualifyingRankingsRecordsFilter(
            isModalShowing: $isModalShowing,
            isModal1DropdownShowing: $isModal1DropdownShowing,
            isModal2DropdownShowing: $isModal2DropdownShowing,
            isModal3DropdownShowing: $isModal3DropdownShowing,
            selectedGender: $selectedGender,
            selectedAge: $selectedAge,
            selectedMeet: $selectedMeet,
            genders: genders,
            ageGroups: ageGroups,
            meets: meets,
            title: "Meet"
        ))
    }
}

#Preview {
    InternationalRankingsView()
}

