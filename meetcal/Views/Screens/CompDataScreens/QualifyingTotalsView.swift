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
    @StateObject private var customerManager = CustomerInfoManager()
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var modelContext

    @State private var isModalShowing: Bool = false
    @State private var isModal1DropdownShowing: Bool = false
    @State private var isModal2DropdownShowing: Bool = false
    @State private var isModal3DropdownShowing: Bool = false
    
    @State var appliedGender: String = "Men"
    @State var appliedAge: String = "Senior"
    @State var appliedMeet: String = "Nationals"
    
    @State var draftGender: String = "Men"
    @State var draftAge: String = "Senior"
    @State var draftMeet: String = "Nationals"
    
    let genders: [String] = ["Men", "Women"]
    // age group will change based on meet query
    var ageGroups: [String] { viewModel.ageGroups }
    let meets: [String] = ["Nationals", "Virus Series", "Virus Finals", "Master's Pan Ams", "IMWA Worlds"]
    
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
                                        Text("Weight Class")
                                            .frame(width: 150, alignment: .leading)
                                        Spacer()
                                        Text("Total")
                                            .frame(width: 100, alignment: .leading)
                                    }
                                    .bold()
                                    .foregroundStyle(colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)

                                    ForEach(viewModel.totals, id: \.self) { total in
                                        HStack {
                                            Text(total.weight_class)
                                                .frame(width: 150, alignment: .leading)
                                            Spacer()
                                            Text(String("\(total.qualifying_total)kg"))
                                                .frame(width: 100, alignment: .leading)
                                        }
                                    }
                                }
                            }
                            .padding(.top, -10)
                        }
                    }
                }
            }
            .navigationTitle("Qualifying Totals")
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
                appliedGender = draftGender
                appliedAge = draftAge
                appliedMeet = draftMeet
                Task {
                    await viewModel.loadAgeGroup(for: appliedGender, event_name: appliedMeet)

                    viewModel.totals.removeAll()
                    await viewModel.loadTotals(gender: appliedGender, age_category: appliedAge, event_name: appliedMeet)
                }
                isModalShowing = false
            }
        ))
        .task {
            viewModel.setModelContext(modelContext)
            AnalyticsManager.shared.trackScreenView("Qualifying Totals")
            AnalyticsManager.shared.trackQualifyingTotalsViewed()
            viewModel.totals.removeAll()
            await viewModel.loadTotals(gender: appliedGender, age_category: appliedAge, event_name: appliedMeet)
            await customerManager.fetchCustomerInfo()
        }
        .task {
            await viewModel.loadAgeGroup(for: appliedGender, event_name: appliedMeet)
        }
        .onChange(of: appliedGender) {
            Task {
                viewModel.totals.removeAll()
                await viewModel.loadTotals(gender: appliedGender, age_category: appliedAge, event_name: appliedMeet)
            }
        }
        .onChange(of: appliedAge) {
            Task {
                viewModel.totals.removeAll()
                await viewModel.loadTotals(gender: appliedGender, age_category: appliedAge, event_name: appliedMeet)
            }
        }
        .onChange(of: appliedMeet) {
            Task {
                viewModel.totals.removeAll()
                await viewModel.loadTotals(gender: appliedGender, age_category: appliedAge, event_name: appliedMeet)
            }
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
