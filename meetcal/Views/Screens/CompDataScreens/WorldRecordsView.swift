//
//  AmericanRecordsView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/5/25.
//

import SwiftUI
import Supabase
import Combine

struct WorldRecordsView: View {
    @StateObject private var viewModel = WorldRecordsModel()
    @StateObject private var customerManager = CustomerInfoManager()
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var modelContext

    @State private var isModalShowing: Bool = false
    @State private var isModal1DropdownShowing: Bool = false
    @State private var isModal2DropdownShowing: Bool = false
    
    @State var appliedGender: String = "Men"
    @State var appliedAge: String = "Senior"
    
    @State var draftGender: String = "Men"
    @State var draftAge: String = "Senior"
    
    var worldRecords: [WorldRecords] { viewModel.worldRecords }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack {
                    FilterButton(
                        filter1: appliedAge,
                        filter2: appliedGender,
                        filter3: nil,
                        action: {
                            draftAge = appliedAge
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
                                    
                                    ForEach(viewModel.worldRecords, id: \.self) { record in
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
            .navigationTitle("IWF World Records")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .tabBar)
        }
        .overlay(WorldRecordsFilter(
            isModalShowing: $isModalShowing,
            appliedGender: $draftGender,
            appliedAge: $draftAge,
            onApply: {
                appliedGender = draftGender
                appliedAge = draftAge
                Task {
                    viewModel.worldRecords.removeAll()
                    await viewModel.loadRecords(gender: appliedGender, age_category: appliedAge)
                }
                isModalShowing = false
            }))
        .task {
            AnalyticsManager.shared.trackScreenView("World Records")
            viewModel.worldRecords.removeAll()
            await viewModel.loadRecords(gender: appliedGender, age_category: appliedAge)
            await customerManager.fetchCustomerInfo()
        }
        .onChange(of: appliedGender) {
            Task {
                viewModel.worldRecords.removeAll()
                await viewModel.loadRecords(gender: appliedGender, age_category: appliedAge)
            }
        }
        .onChange(of: appliedAge) {
            Task {
                viewModel.worldRecords.removeAll()
                await viewModel.loadRecords(gender: appliedGender, age_category: appliedAge)
            }
        }
    }
}

struct WorldRecordsFilter: View {
    @Environment(\.colorScheme) var colorScheme

    @Binding var isModalShowing: Bool
    @State private var isModal1DropdownShowing: Bool = false
    @State private var isModal2DropdownShowing: Bool = false
    
    @Binding var appliedGender: String
    @Binding var appliedAge: String
    
    let genders: [String] = ["Men", "Women"]
    let ageGroups: [String] = ["Senior", "Junior", "Youth"]
    let onApply: () -> Void
    
    var body: some View {
        Group {
            if isModalShowing {
                Color(colorScheme == .light ? .black.opacity(0.4) : .black.opacity(0.7))
                    .ignoresSafeArea()
                    .onTapGesture {
                        isModalShowing = false
                        isModal1DropdownShowing = false
                        isModal2DropdownShowing = false
                    }
                
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Gender")
                                .secondaryText()
                                .padding(.bottom, 0.5)
                            Text(appliedGender.isEmpty ? "Men" : appliedGender)
                        }
                        Spacer()
                        Image(systemName: isModal1DropdownShowing ? "chevron.down" : "chevron.right")
                    }
                    .padding()
                    .background(colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isModal1DropdownShowing.toggle()
                    }
                    
                    if isModal1DropdownShowing {
                        VStack(alignment: .leading, spacing: 0) {
                            Divider()
                            
                            ForEach(genders, id: \.self) { gender in
                                HStack {
                                    Button(action: {
                                        appliedGender = gender
                                        isModal1DropdownShowing = false
                                    }) {
                                        Text(gender)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading, 0)
                                            .padding()
                                            .foregroundStyle(gender == appliedGender ? Color.blue : colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                                    }


                                    Spacer()
                                    if gender == appliedGender {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.blue)
                                    }
                                    Spacer()
                                }
                                .background(gender == appliedGender ? .gray.opacity(0.2) : colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))

                                Divider()
                            }
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Age Group")
                                .secondaryText()
                                .padding(.bottom, 0.5)
                            Text(appliedAge)
                        }
                        Spacer()
                        Image(systemName: isModal2DropdownShowing ? "chevron.down" : "chevron.right")
                    }
                    .padding()
                    .background(colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isModal2DropdownShowing.toggle()
                    }

                    if isModal2DropdownShowing {
                        VStack(alignment: .leading, spacing: 0) {
                            Divider()
                            
                            ForEach(ageGroups, id: \.self) { age in
                                HStack {
                                    Button(action: {
                                        appliedAge = age
                                        isModal2DropdownShowing = false
                                    }) {
                                        Text(age)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading, 0)
                                            .padding()
                                            .foregroundStyle(age == appliedAge ? Color.blue : colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                                    }


                                    Spacer()
                                    if age == appliedAge {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.blue)
                                    }
                                    Spacer()
                                }
                                .background(age == appliedAge ? .gray.opacity(0.2) : colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))

                                Divider()
                            }
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Apply")
                            .bold()
                            .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(.white)
                    .background(.blue)
                    .cornerRadius(12)
                    .padding()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onApply()
                    }
                }
                .frame(maxWidth: 350)
                .background(colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
                .cornerRadius(16)
                .shadow(radius: 20)
                .padding(.horizontal, 30)
            }
        }
    }
}

#Preview {
    WorldRecordsView()
}
