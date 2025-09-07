//
//  AmericanRecordsView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/5/25.
//

import SwiftUI
import Supabase
import Combine

struct AmericanRecordsView: View {
    @StateObject private var viewModel = RecordsViewModel()

    @State private var isModalShowing: Bool = false
    @State private var isModal1DropdownShowing: Bool = false
    @State private var isModal2DropdownShowing: Bool = false
    @State private var isModal3DropdownShowing: Bool = false
    
    @State var selectedGender: String = "Men"
    @State var selectedAge: String = "Senior"
    @State var selectedFederation: String = "USAW"
    
    let genders: [String] = ["Men", "Women"]
    let ageGroups: [String] = ["U13", "U15", "U17", "Junior", "University", "Senior", "Masters"]
    let meets: [String] = ["USAW", "USAMW"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack {
                    FilterButton(filter1: selectedFederation, filter2: selectedGender, filter3: selectedAge, action: {isModalShowing = true})
                    
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
                            
                            ForEach(viewModel.records, id: \.self) { record in
                                HStack {
                                    DataSectionView(weightClass: record.weight_class, data: String("\(record.snatch_record)kg"), width: 120)
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
            .navigationTitle("American Records")
            .navigationBarTitleDisplayMode(.inline)
        }
        .overlay(QualifyingRankingsRecordsFilter(
                    isModalShowing: $isModalShowing,
                    isModal1DropdownShowing: $isModal1DropdownShowing,
                    isModal2DropdownShowing: $isModal2DropdownShowing,
                    isModal3DropdownShowing: $isModal3DropdownShowing,
                    selectedGender: $selectedGender,
                    selectedAge: $selectedAge,
                    selectedMeet: $selectedFederation,
                    genders: genders,
                    ageGroups: ageGroups,
                    meets: meets,
                    title: "Federation"
                ))
        .task {
            await viewModel.loadRecords(gender: selectedGender, ageCategory: selectedAge, federation: selectedFederation)
        }
        .onChange(of: selectedGender) { _ in
            Task { await viewModel.loadRecords(gender: selectedGender, ageCategory: selectedAge, federation: selectedFederation) }
        }
        .onChange(of: selectedAge) { _ in
            Task { await viewModel.loadRecords(gender: selectedGender, ageCategory: selectedAge, federation: selectedFederation) }
        }
        .onChange(of: selectedFederation) { _ in
            Task { await viewModel.loadRecords(gender: selectedGender, ageCategory: selectedAge, federation: selectedFederation) }
        }
    }
}

#Preview {
    AmericanRecordsView()
}
