//
//  StandardsView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/5/25.
//

import Combine
import SwiftUI
import Supabase

struct StandardsView: View {
    @StateObject private var viewModel = StandardsViewModel()
    @State private var isModalShowing: Bool = false
    @State var appliedGender: String = "Men"
    @State var appliedAge: String = "Senior"
    @State private var draftGender: String = "Men"
    @State private var draftAge: String = "Senior"
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack {
                    FilterButton(
                        filter1: appliedGender,
                        filter2: appliedAge,
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
                            ProgressView("Loading...")
                        } else if let error = viewModel.error {
                            Text("Failed to load: \(error.localizedDescription)").foregroundColor(.red)
                        } else {
                            List {
                                HStack {
                                    Text("Weight Class")
                                        .frame(width: 160, alignment: .leading)
                                        .bold()
                                    Text("A")
                                    Spacer()
                                    Spacer()
                                    Text("B")
                                    Spacer()
                                }
                                .bold()
                                .secondaryText()
                                
                                ForEach(viewModel.standards) { total in
                                    HStack {
                                        DataSectionView(weightClass: total.weight_class, data: String("\(total.standard_a)kg"), width: 160)
                                        Text("\(total.standard_b)kg")
                                        Spacer()
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, -10)
                    
                }
            }
            .navigationTitle("A/B Standards")
            .navigationBarTitleDisplayMode(.inline)
        }
        .overlay(StandardFilter(
                isModalShowing: $isModalShowing,
                appliedGender: $draftGender,
                appliedAge: $draftAge,
                ageGroups: viewModel.ageGroups,
                onApply: {
                    appliedGender = draftGender
                    appliedAge = draftAge
                    Task {
                        await viewModel.loadAgeGroups(for: appliedGender)
                        
                        await viewModel.loadStandards(gender: appliedGender, ageCategory: appliedAge)
                    }
                    isModalShowing = false
                }
        ))
        .task {
            await viewModel.loadStandards(gender: appliedGender, ageCategory: appliedAge)
        }
        .task {
            await viewModel.loadAgeGroups(for: appliedGender)
        }
        .onChange(of: appliedGender) { _ in
            Task { await viewModel.loadStandards(gender: appliedGender, ageCategory: appliedAge) }
            Task { await viewModel.loadAgeGroups(for: appliedGender) }
        }
        .onChange(of: appliedAge) { _ in
            Task { await viewModel.loadStandards(gender: appliedGender, ageCategory: appliedAge) }
        }
    }
}

struct StandardFilter: View {
    @Binding var isModalShowing: Bool
    @State private var isModal1DropdownShowing: Bool = false
    @State private var isModal2DropdownShowing: Bool = false
    
    @Binding var appliedGender: String
    @Binding var appliedAge: String
    
    let genders: [String] = ["Men", "Women"]
    let ageGroups: [String]
    let onApply: () -> Void
    
    var body: some View {
        Group {
            if isModalShowing {
                Color.black.opacity(0.4)
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
                    .background(Color.white)
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
                                            .foregroundStyle(gender == appliedGender ? Color.blue : Color(red: 102/255, green: 102/255, blue: 102/255))
                                    }


                                    Spacer()
                                    if gender == appliedGender {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.blue)
                                    }
                                    Spacer()
                                }
                                .background(gender == appliedGender ? .gray.opacity(0.2) : .white)

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
                    .background(Color.white)
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
                                            .foregroundStyle(age == appliedAge ? Color.blue : Color(red: 102/255, green: 102/255, blue: 102/255))
                                    }


                                    Spacer()
                                    if age == appliedAge {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.blue)
                                    }
                                    Spacer()
                                }
                                .background(age == appliedAge ? .gray.opacity(0.2) : .white)

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
                .background(.white)
                .cornerRadius(16)
                .shadow(radius: 20)
                .padding(.horizontal, 30)
            }
        }
    }
}

#Preview {
    StandardsView()
}
