//
//  InternationalRankingsView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/5/25.
//

import SwiftUI
import Supabase
import Combine

struct InternationalRankingsView: View {
    @StateObject private var viewModel = IntlRankingsViewModel()
    @Environment(\.colorScheme) var colorScheme

    @State private var isModalShowing: Bool = false
    @State private var isModal1DropdownShowing: Bool = false
    @State private var isModal2DropdownShowing: Bool = false
    @State private var isModal3DropdownShowing: Bool = false
    
    @State var appliedGender: String = "Men"
    @State var appliedAge: String = "Senior"
    @State var appliedMeet: String = "2025 Worlds"
    
    @State var draftGender: String = "Men"
    @State var draftAge: String = "Senior"
    @State var draftMeet: String = "2025 Worlds"
    
    var ageGroups: [String] {viewModel.ageGroups}
    var meets: [String] {viewModel.meets}
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack {
                    FilterButton(
                        filter1: appliedMeet,
                        filter2: appliedAge,
                        filter3: appliedGender,
                        action: {
                            draftAge = appliedAge
                            draftMeet = appliedMeet
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
                                        Text("Name")
                                            .frame(width: 100, alignment: .leading)

                                        Spacer()
                                        Text("Total")
                                            .frame(width: 50, alignment: .leading)
                                        Spacer()
                                        Text("% of A")
                                            .frame(width: 60, alignment: .leading)
                                    }
                                    .bold()
                                    .foregroundStyle(colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)

                                    ForEach(viewModel.rankings, id: \.self) { ranking in
                                        HStack {
                                            Text(ranking.name)
                                                .frame(width: 100, alignment: .leading)
                                            Spacer()
                                            Text("\(ranking.total)kg")
                                                .frame(width: 50, alignment: .leading)
                                            Spacer()
                                            Text("\(String(format: "%.1f", ranking.percent_a))%")
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
            .navigationTitle("International Rankings")
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
            selectedMeet: $appliedMeet,
            draftGender: $draftGender,
            draftAge: $draftAge,
            draftMeet: $draftMeet,
            ageGroups: ageGroups,
            meets: meets,
            title: "Meet",
            onApply: {
                appliedAge = draftAge
                appliedMeet = draftMeet
                appliedGender = draftGender
                Task {
                    await viewModel.loadMeet(gender: appliedGender, ageCategory: appliedAge)
                    await viewModel.loadRankings(gender: appliedGender, ageCategory: appliedAge, meet: appliedMeet)
                    await viewModel.loadAgeGroups(meet: appliedMeet, gender: appliedGender)
                }
                isModalShowing = false
            }
        ))
        .task {
            await viewModel.loadRankings(gender: appliedGender, ageCategory: appliedAge, meet: appliedMeet)
        }
        .task {
            await viewModel.loadMeet(gender: appliedGender, ageCategory: appliedAge)
        }
        .task {
            await viewModel.loadAgeGroups(meet: appliedMeet, gender: appliedGender)
        }
        .onChange(of: appliedGender) {
            Task { await viewModel.loadRankings(gender: appliedGender, ageCategory: appliedAge, meet: appliedMeet) }
        }
        .onChange(of: appliedAge) {
            Task { await viewModel.loadRankings(gender: appliedGender, ageCategory: appliedAge, meet: appliedMeet) }
        }
        .onChange(of: appliedMeet) {
            Task { await viewModel.loadRankings(gender: appliedGender, ageCategory: appliedAge, meet: appliedMeet) }
        }
        .onChange(of: draftMeet) {
            Task {
                await viewModel.loadAgeGroups(meet: draftMeet, gender: draftGender)
                draftAge = viewModel.ageGroups.first ?? draftAge
            }
        }
    }
}

#Preview {
    InternationalRankingsView()
}

