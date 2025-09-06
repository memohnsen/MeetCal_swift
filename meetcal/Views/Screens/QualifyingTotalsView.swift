//
//  QualifyingTotalsView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/4/25.
//

import SwiftUI

struct QualifyingTotal: Hashable {
    let id = UUID()
    let ageGroup: String
    let weightClass: String
    let total: String
}

struct QualifyingTotalsView: View {
    @State private var isModalShowing: Bool = false
    @State private var isModal1DropdownShowing: Bool = false
    @State private var isModal2DropdownShowing: Bool = false
    @State private var isModal3DropdownShowing: Bool = false
    
    @State var selectedGender: String = "Men"
    @State var selectedAge: String = "Senior"
    @State var selectedMeet: String = "USAW Nationals"
    
    let genders: [String] = ["Men", "Women"]
    let ageGroups: [String] = ["U13", "U15", "U17", "Junior", "University", "Senior", "Masters"]
    let meets: [String] = ["USAW Nationals", "AO1", "AO2", "AOF", "USAMW Nationals", "IMWA Worlds", "IMWA Pan Ams"]
    
    let qualifyingTotals: [QualifyingTotal] = [
        QualifyingTotal(ageGroup: "Senior", weightClass: "60kg", total: "209kg"),
        QualifyingTotal(ageGroup: "Senior", weightClass: "65kg", total: "227kg"),
        QualifyingTotal(ageGroup: "Senior", weightClass: "71kg", total: "256kg"),
        QualifyingTotal(ageGroup: "Senior", weightClass: "79kg", total: "272kg"),
        QualifyingTotal(ageGroup: "Senior", weightClass: "88kg", total: "289kg"),
        QualifyingTotal(ageGroup: "Senior", weightClass: "94kg", total: "300kg"),
        QualifyingTotal(ageGroup: "Senior", weightClass: "110kg", total: "309kg"),
        QualifyingTotal(ageGroup: "Senior", weightClass: "110+kg", total: "312kg")
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
                                    .frame(width: 200, alignment: .leading)
                                    .bold()
                                Text("Total")
                                Spacer()
                            }
                            .bold()
                            .secondaryText()
                            
                            ForEach(qualifyingTotals, id: \.self) { total in
                                DataSectionView(weightClass: total.weightClass, data: total.total, width: 200)
                            }
                        }
                    }
                    .padding(.top, -10)
                    
                    Spacer()
                }
            }
            .navigationTitle("Qualifying Totals")
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
    QualifyingTotalsView()
}
