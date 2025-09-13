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
    
    @State var appliedGender: String = "Men"
    @State var appliedAge: String = "Senior"
    @State var appliedMeet: String = "USAW Nationals"
    
    @State var draftGender: String = "Men"
    @State var draftAge: String = "Senior"
    @State var draftMeet: String = "USAW Nationals"
    
    let genders: [String] = ["Men", "Women"]
    // age group will change based on meet query
    var ageGroups: [String] { viewModel.ageGroups }
    let meets: [String] = ["USAW Nationals", "Virus Series", "Virus Finals", "Master's Pan Ams", "IMWA Worlds"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack {
                    FilterButton(
                        filter1: appliedMeet,
                        filter2: appliedGender,
                        filter3: appliedAge,
                        action: {
                            draftAge = appliedAge
                            draftMeet = appliedMeet
                            draftGender = appliedGender
                            isModalShowing = true
                        }
                    )
                    
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
            selectedGender: $appliedGender,
            selectedAge: $appliedAge,
            selectedMeet: $appliedMeet,
            draftGender: $draftGender,
            draftAge: $draftAge,
            draftMeet: $draftMeet,
            ageGroups: ageGroups,
            meets: meets,
            title: "Meet",
            onApply: {
                appliedGender = draftGender
                appliedAge = draftAge
                appliedMeet = draftMeet
                Task {
                    await viewModel.loadAgeGroup(for: appliedGender, event_name: appliedMeet)
                    
                    await viewModel.loadTotals(gender: appliedGender, age_category: appliedAge, event_name: appliedMeet)
                }
                isModalShowing = false
            }
        ))
        .task {
            await viewModel.loadTotals(gender: appliedGender, age_category: appliedAge, event_name: appliedMeet)
        }
        .task {
            await viewModel.loadAgeGroup(for: appliedGender, event_name: appliedMeet)
        }
        .onChange(of: appliedGender) { _ in
            Task { await viewModel.loadTotals(gender: appliedGender, age_category: appliedAge, event_name: appliedMeet) }
        }
        .onChange(of: appliedAge) { _ in
            Task { await viewModel.loadTotals(gender: appliedGender, age_category: appliedAge, event_name: appliedMeet) }
        }
        .onChange(of: appliedMeet) { _ in
            Task { await viewModel.loadTotals(gender: appliedGender, age_category: appliedAge, event_name: appliedMeet) }
        }
        .onChange(of: draftMeet) {
            Task { await viewModel.loadAgeGroup(for: draftGender, event_name: draftMeet)
                draftAge = viewModel.ageGroups.first ?? "Senior"
            }
        }
    }
}

#Preview {
    QualifyingTotalsView()
}
