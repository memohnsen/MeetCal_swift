//
//  QualifyingTotalsView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/4/25.
//

import SwiftUI
import Supabase
import Combine

struct QualifyingTotalsView: View {
    @StateObject private var viewModel = QualifyingTotalModel()
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
                            
                            ForEach(viewModel.totals, id: \.self) { total in
                                DataSectionView(weightClass: total.weight_class, data: String("\(total.qualifying_total)kg"), width: 200)
                            }
                        }
                    }
                    .padding(.top, -10)
                    
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
        .task {
            await viewModel.loadTotals(gender: selectedGender, age_category: selectedAge, event_name: selectedMeet)
        }
        .onChange(of: selectedGender) { _ in
            Task { await viewModel.loadTotals(gender: selectedGender, age_category: selectedAge, event_name: selectedMeet) }
        }
        .onChange(of: selectedAge) { _ in
            Task { await viewModel.loadTotals(gender: selectedGender, age_category: selectedAge, event_name: selectedMeet) }
        }
        .onChange(of: selectedMeet) { _ in
            Task { await viewModel.loadTotals(gender: selectedGender, age_category: selectedAge, event_name: selectedMeet) }
        }
    }
}

#Preview {
    QualifyingTotalsView()
}
