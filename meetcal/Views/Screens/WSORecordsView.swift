//
//  WSORecordsView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/5/25.
//

import SwiftUI
import Supabase
import Combine

struct WSORecordsView: View {
    @StateObject private var viewModel = WSOViewModel()
    
    @State private var isModalShowing: Bool = false
    @State private var isModal1DropdownShowing: Bool = false
    @State private var isModal2DropdownShowing: Bool = false
    @State private var isModal3DropdownShowing: Bool = false
    
    @State var selectedGender: String = "Men"
    @State var selectedAge: String = "Senior"
    @State var selectedMeet: String = "Carolina"
    
    @State var draftGender: String = "Men"
    @State var draftAge: String = "Senior"
    @State var draftWSO: String = "Carolina"
    
    let ageGroups: [String] = ["U13", "U15", "U17", "Junior", "University", "Senior", "Masters"]
    let wso: [String] = ["Carolina", "Florida", "Texas-Oklahoma"]
    
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
                            
                            ForEach(viewModel.wsoRecords, id: \.self) { record in
                                HStack {
                                    DataSectionView(weightClass: String("\(record.weight_class)kg"), data: String("\(record.snatch_record)kg"), width: 120)
                                    Text("\(record.cj_record)kg")
                                    Spacer()
                                    Spacer()
                                    Spacer()
                                    Text("\(record.total_record)kg")
                                    Spacer()
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding(.top, -10)
                    
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
                    draftGender: $draftGender,
                    draftAge: $draftAge,
                    draftMeet: $draftWSO,
                    ageGroups: ageGroups,
                    meets: wso,
                    title: "WSO",
                    onApply: {isModalShowing = false}
                ))
        .task {
            await viewModel.loadRecords(gender: selectedGender, ageCategory: selectedAge, wso: selectedMeet)
        }
        .onChange(of: selectedGender) { _ in
            Task { await viewModel.loadRecords(gender: selectedGender, ageCategory: selectedAge, wso: selectedMeet) }
        }
        .onChange(of: selectedAge) { _ in
            Task { await viewModel.loadRecords(gender: selectedGender, ageCategory: selectedAge, wso: selectedMeet) }
        }
        .onChange(of: selectedMeet) { _ in
            Task { await viewModel.loadRecords(gender: selectedGender, ageCategory: selectedAge, wso: selectedMeet) }
        }
    }
}

#Preview {
    WSORecordsView()
}
