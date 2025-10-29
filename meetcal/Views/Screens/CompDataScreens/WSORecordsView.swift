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
    @StateObject private var customerManager = CustomerInfoManager()
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var modelContext
    
    @State private var isModalShowing: Bool = false
    @State private var isModal1DropdownShowing: Bool = false
    @State private var isModal2DropdownShowing: Bool = false
    @State private var isModal3DropdownShowing: Bool = false
    
    @State var appliedGender: String = "Men"
    @State var appliedAge: String = "Senior"
    @State var appliedMeet: String = "Carolina"
    
    @State var draftGender: String = "Men"
    @State var draftAge: String = "Senior"
    @State var draftWSO: String = "Carolina"
    
    var ageGroups: [String] {viewModel.ageGroups}
    var wso: [String] {viewModel.wso}
    
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
                            draftWSO = appliedMeet
                            draftGender = appliedGender
                            isModalShowing = true
                        })
                    
                    Divider()
                        .padding(.top)
                        .padding(.bottom, 2)
                    
                    
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
                                
                                ForEach(viewModel.wsoRecords, id: \.self) { record in
                                    HStack {
                                        Text(String("\(record.weight_class)kg"))
                                            .frame(width: 60, alignment: .leading)
                                        Spacer()
                                        Text(record.snatch_record.map { "\($0)kg" } ?? "")
                                            .frame(width: 60, alignment: .leading)
                                        Spacer()
                                        Text(record.cj_record.map { "\($0)kg" } ?? "")
                                            .frame(width: 60, alignment: .leading)
                                        Spacer()
                                        Text(record.total_record.map { "\($0)kg" } ?? "")
                                            .frame(width: 60, alignment: .leading)
                                    }
                                }
                            }
                        }
                        .padding(.top, -10)
                    }
                }
            }
            .navigationTitle("WSO Records")
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
                    draftMeet: $draftWSO,
                    ageGroups: ageGroups,
                    meets: wso,
                    title: "WSO",
                    onApply: {
                        appliedAge = draftAge
                        appliedMeet = draftWSO
                        appliedGender = draftGender
                        isModalShowing = false
                    }
                ))
        .task {
            viewModel.setModelContext(modelContext)
            AnalyticsManager.shared.trackScreenView("WSO Records")
            AnalyticsManager.shared.trackRecordsViewed(type: "wso")
            viewModel.wsoRecords.removeAll()
            await viewModel.loadRecords(gender: appliedGender, ageCategory: appliedAge, wso: appliedMeet)
            await customerManager.fetchCustomerInfo()
        }
        .task {
            await viewModel.loadWSO()
        }
        .task{
            await viewModel.loadAgeGroups(gender: appliedGender, wso: appliedMeet)
        }
        .onChange(of: appliedGender) {
            Task {
                viewModel.wsoRecords.removeAll()
                await viewModel.loadRecords(gender: appliedGender, ageCategory: appliedAge, wso: appliedMeet)
            }
        }
        .onChange(of: appliedAge) {
            Task {
                viewModel.wsoRecords.removeAll()
                await viewModel.loadRecords(gender: appliedGender, ageCategory: appliedAge, wso: appliedMeet)
            }
        }
        .onChange(of: appliedMeet) {
            Task {
                viewModel.wsoRecords.removeAll()
                await viewModel.loadRecords(gender: appliedGender, ageCategory: appliedAge, wso: appliedMeet)
            }
        }
        .onChange(of: draftWSO) {
            Task { await viewModel.loadAgeGroups(gender: draftGender, wso: draftWSO )}
        }
    }
}

#Preview {
    WSORecordsView()
}
