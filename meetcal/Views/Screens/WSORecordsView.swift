//
//  WSORecordsView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/5/25.
//

import SwiftUI

struct WSORecordsView: View {
    @State private var isModalShowing: Bool = false
        @State private var isModal1DropdownShowing: Bool = false
        @State private var isModal2DropdownShowing: Bool = false
        @State private var isModal3DropdownShowing: Bool = false
        
        @State var selectedGender: String = "Men"
        @State var selectedAge: String = "Senior"
        @State var selectedMeet: String = "Carolina"
        
        let genders: [String] = ["Men", "Women"]
        let ageGroups: [String] = ["U13", "U15", "U17", "Junior", "University", "Senior", "Masters"]
        let meets: [String] = ["Carolina", "Florida", "Texas-Oklahoma"]
    
    let amRecords = [
        Records(ageGroup: "Senior", weightClass: "60kg", snatchRecord: "160kg", cjRecord: "200kg", totalRecord: "360kg"),
        Records(ageGroup: "Senior", weightClass: "60kg", snatchRecord: "160kg", cjRecord: "200kg", totalRecord: "360kg"),
        Records(ageGroup: "Senior", weightClass: "60kg", snatchRecord: "160kg", cjRecord: "200kg", totalRecord: "360kg"),
        Records(ageGroup: "Senior", weightClass: "60kg", snatchRecord: "160kg", cjRecord: "200kg", totalRecord: "360kg"),
        Records(ageGroup: "Senior", weightClass: "60kg", snatchRecord: "160kg", cjRecord: "200kg", totalRecord: "360kg"),
        Records(ageGroup: "Senior", weightClass: "60kg", snatchRecord: "160kg", cjRecord: "200kg", totalRecord: "360kg"),
        Records(ageGroup: "Senior", weightClass: "60kg", snatchRecord: "160kg", cjRecord: "200kg", totalRecord: "360kg")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack {
                    FilterButton(filter1: selectedMeet, filter2: selectedGender, filter3: selectedAge, action: {isModalShowing = true})
                    
                    Divider()
                        .padding(.top)
                        .padding(.bottom, 2)
                    
                    
                    VStack {
                        List {
                            HStack {
                                Text("Weight Class")
                                    .frame(width: 120, alignment: .leading)
                                    .bold()
                                Text("Snatch")
                                Spacer()
                                Text("C&J")
                                Spacer()
                                Spacer()
                                Spacer()
                                Text("Total")
                                Spacer()
                                Spacer()
                            }
                            .bold()
                            .secondaryText()
                            
                            ForEach(amRecords, id: \.self) { record in
                                HStack {
                                    DataSectionView(weightClass: record.weightClass, data: record.snatchRecord, width: 120)
                                    Text(record.cjRecord)
                                    Spacer()
                                    Spacer()
                                    Spacer()
                                    Text(record.totalRecord)
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
            .navigationTitle("WSO Records")
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
                    title: "WSO"
                ))
    }
}

#Preview {
    WSORecordsView()
}
