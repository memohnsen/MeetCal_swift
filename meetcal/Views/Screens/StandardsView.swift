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
    @State var selectedGender: String = "Men"
    @State var selectedAge: String = "Senior"
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack {
                    FilterButton(filter1: selectedGender, filter2: selectedAge, filter3: nil, action: {isModalShowing = true})
                    
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
        .overlay(StandardFilter(isModalShowing: $isModalShowing, selectedGender: $selectedGender, selectedAge: $selectedAge))
        .task {
            await viewModel.loadStandards(gender: selectedGender, ageCategory: selectedAge)
        }
        .onChange(of: selectedGender) { _ in
            Task { await viewModel.loadStandards(gender: selectedGender, ageCategory: selectedAge) }
        }
        .onChange(of: selectedAge) { _ in
            Task { await viewModel.loadStandards(gender: selectedGender, ageCategory: selectedAge) }
        }
    }
}

struct StandardFilter: View {
    @Binding var isModalShowing: Bool
    @State private var isModal1DropdownShowing: Bool = false
    @State private var isModal2DropdownShowing: Bool = false
    
    @Binding var selectedGender: String
    @Binding var selectedAge: String
    
    let genders: [String] = ["Men", "Women"]
    let ageGroups: [String] = ["U13", "U15", "U17", "Junior", "Senior"]
    
    var body: some View {
        Group {
            if isModalShowing {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isModalShowing = false
                    }
                
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Gender")
                                .secondaryText()
                                .padding(.bottom, 0.5)
                            Text(selectedGender.isEmpty ? "Men" : selectedGender)
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
                                        selectedGender = gender
                                        isModal1DropdownShowing = false
                                    }) {
                                        Text(gender)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading, 0)
                                            .padding()
                                            .foregroundStyle(gender == selectedGender ? Color.blue : Color(red: 102/255, green: 102/255, blue: 102/255))
                                    }


                                    Spacer()
                                    if gender == selectedGender {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.blue)
                                    }
                                    Spacer()
                                }
                                .background(gender == selectedGender ? .gray.opacity(0.2) : .white)

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
                            Text(selectedAge)
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
                                        selectedAge = age
                                        isModal2DropdownShowing = false
                                    }) {
                                        Text(age)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading, 0)
                                            .padding()
                                            .foregroundStyle(age == selectedAge ? Color.blue : Color(red: 102/255, green: 102/255, blue: 102/255))
                                    }


                                    Spacer()
                                    if age == selectedAge {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.blue)
                                    }
                                    Spacer()
                                }
                                .background(age == selectedAge ? .gray.opacity(0.2) : .white)

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
                        isModalShowing = false
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
