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
    @Environment(\.colorScheme) var colorScheme

    @State private var isModalShowing: Bool = false
    @State private var isModal1DropdownShowing: Bool = false
    @State private var isModal2DropdownShowing: Bool = false
    @State private var isModal3DropdownShowing: Bool = false
    
    @State var appliedGender: String = "Men"
    @State var appliedAge: String = "Senior"
    @State var appliedFederation: String = "USAW"
    
    @State var draftGender: String = "Men"
    @State var draftAge: String = "Senior"
    @State var draftFederation: String = "USAW"
    
    var ageGroups: [String] {viewModel.ageGroups}
    let meets: [String] = ["USAW", "USAMW"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack {
                    FilterButton(
                        filter1: appliedFederation,
                        filter2: appliedGender,
                        filter3: appliedAge,
                        action: {
                            draftAge = appliedAge
                            draftFederation = appliedFederation
                            draftGender = appliedGender
                            isModalShowing = true
                        })
                    
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
                            VStack {
                                List {
                                    HStack {
                                        Text("Class")
                                            .frame(width: 60, alignment: .leading)
                                        Spacer()
                                        Text("Snatch")
                                            .frame(width: 60, alignment: .leading)
                                        Spacer()
                                        Text("C&J")
                                            .frame(width: 60, alignment: .leading)
                                        Spacer()
                                        Text("Total")
                                            .frame(width: 60, alignment: .leading)
                                    }
                                    .bold()
                                    .foregroundStyle(colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                                    
                                    ForEach(viewModel.records, id: \.self) { record in
                                        HStack {
                                            Text(record.weight_class)
                                                .frame(width: 60, alignment: .leading)
                                            Spacer()
                                            Text("\(record.snatch_record)kg")
                                                .frame(width: 60, alignment: .leading)
                                            Spacer()
                                            Text("\(record.cj_record)kg")
                                                .frame(width: 60, alignment: .leading)
                                            Spacer()
                                            Text("\(record.total_record)kg")
                                                .frame(width: 60, alignment: .leading)
                                        }
                                    }
                                }
                            }
                            .padding(.top, -10)
                        }
                    }
                }
            }
            .navigationTitle("American Records")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .tabBar)
        }
        .overlay(QualifyingRankingsRecordsFilter(
                    isModalShowing: $isModalShowing,
                    isModal1DropdownShowing: $isModal1DropdownShowing,
                    isModal2DropdownShowing: $isModal2DropdownShowing,
                    isModal3DropdownShowing: $isModal3DropdownShowing,
                    selectedGender: $appliedGender,
                    selectedAge: $appliedAge,
                    selectedMeet: $appliedFederation,
                    draftGender: $draftGender,
                    draftAge: $draftAge,
                    draftMeet: $draftFederation,
                    ageGroups: ageGroups,
                    meets: meets,
                    title: "Federation",
                    onApply: {
                        appliedAge = draftAge
                        appliedGender = draftGender
                        appliedFederation = draftFederation
                        Task {
                            await viewModel.loadAgeGroup(for: appliedGender, record_type: appliedFederation)
                            await viewModel.loadRecords(gender: appliedGender, ageCategory: appliedAge, record_type: appliedFederation)
                        }
                        isModalShowing = false
                    }
                ))
        .task {
            AnalyticsManager.shared.trackScreenView("American Records")
            AnalyticsManager.shared.trackRecordsViewed(type: "american")
            await viewModel.loadRecords(gender: appliedGender, ageCategory: appliedAge, record_type: appliedFederation)
        }
        .task {
            await viewModel.loadAgeGroup(for: appliedGender, record_type: appliedFederation)
        }
        .onChange(of: appliedGender) {
            Task { await viewModel.loadRecords(gender: appliedGender, ageCategory: appliedAge, record_type: appliedFederation) }
        }
        .onChange(of: appliedAge) {
            Task { await viewModel.loadRecords(gender: appliedGender, ageCategory: appliedAge, record_type: appliedFederation) }
        }
        .onChange(of: appliedFederation) {
            Task { await viewModel.loadRecords(gender: appliedGender, ageCategory: appliedAge, record_type: appliedFederation) }
        }
        .onChange(of: draftFederation) {
            Task {
                await viewModel.loadAgeGroup(for: draftGender, record_type: draftFederation)
                draftAge = viewModel.ageGroups.first ?? draftAge
            }
        }
    }
}

#Preview {
    AmericanRecordsView()
}
