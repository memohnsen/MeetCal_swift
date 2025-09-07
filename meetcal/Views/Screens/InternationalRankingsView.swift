//
//  InternationalRankingsView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/5/25.
//

import SwiftUI
import Supabase
import Combine

struct Rankings: Identifiable, Hashable, Decodable, Sendable {
    let id: Int
    let meet: String
    let name: String
    let weight_class: String
    let total: Int
    let percent_a: Float
    let gender: String
    let age_category: String
}

@MainActor
class IntlRankingsViewModel: ObservableObject {
    @Published var rankings: [Rankings] = []
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    func loadRankings(gender: String, ageCategory: String, meet: String) async {
        isLoading = true
        error = nil
        do {
            let response = try await supabase
                .from("intl_rankings")
                .select()
                .eq("gender", value: gender)
                .eq("age_category", value: ageCategory)
                .eq("meet", value: meet)
                .order("ranking")
                .execute()
            print(response)
            let decoder = JSONDecoder()
            let rankingsData = try decoder.decode([Rankings].self, from: response.data)
            self.rankings = rankingsData
            print(rankings)
        } catch {
            print("Error: \(error)")
            self.error = error
        }
        isLoading = false
    }
}

struct InternationalRankingsView: View {
    @StateObject private var viewModel = IntlRankingsViewModel()
    @State private var isModalShowing: Bool = false
    @State private var isModal1DropdownShowing: Bool = false
    @State private var isModal2DropdownShowing: Bool = false
    @State private var isModal3DropdownShowing: Bool = false
    
    @State var selectedGender: String = "Men"
    @State var selectedAge: String = "Senior"
    @State var selectedMeet: String = "2025 Worlds"
    
    let genders: [String] = ["Men", "Women"]
    let ageGroups: [String] = ["U13", "U15", "U17", "Junior", "Senior"]
    let meets: [String] = ["2025 Worlds", "2025 Pan Ams"]
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack {
                    FilterButton(filter1: selectedMeet, filter2: selectedAge, filter3: selectedGender, action: {isModalShowing = true})
                    
                    Divider()
                        .padding(.top)
                        .padding(.bottom, 2)
                    
                    
                    VStack {
                        List {
                            HStack {
                                Text("Name")
                                    .frame(width: 130, alignment: .leading)
                                    .padding(.leading, 6)
                                Spacer()
                                Spacer()
                                Spacer()
                                Text("Total")
                                    .frame(width: 60, alignment: .leading)
                                Spacer()
                                Spacer()
                                Spacer()
                                Text("% of A")
                                    .frame(width: 60, alignment: .leading)
                                Spacer()
                                Spacer()
                            }
                            .bold()
                            .secondaryText()
                            
                            ForEach(viewModel.rankings, id: \.self) { ranking in
                                HStack {
                                    DataSectionView(weightClass: nil, data: ranking.name, width: 0)
                                    Text("\(ranking.total)kg")
                                        .frame(width: 50, alignment: .leading)
                                    Spacer()
                                    Spacer()
                                    Spacer()
                                    Spacer()
                                    Spacer()
                                    Text("\(String(format: "%.1f", ranking.percent_a))%")
                                        .frame(width: 60, alignment: .leading)
                                    Spacer()
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding(.top, -10)
                    
                }
            }
            .navigationTitle("International Rankings")
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
            genders: genders,
            ageGroups: ageGroups,
            meets: meets,
            title: "Meet"
        ))
        .task {
            await viewModel.loadRankings(gender: selectedGender, ageCategory: selectedAge, meet: selectedMeet)
        }
        .onChange(of: selectedGender) { _ in
            Task { await viewModel.loadRankings(gender: selectedGender, ageCategory: selectedAge, meet: selectedMeet) }
        }
        .onChange(of: selectedAge) { _ in
            Task { await viewModel.loadRankings(gender: selectedGender, ageCategory: selectedAge, meet: selectedMeet) }
        }
        .onChange(of: selectedMeet) { _ in
            Task { await viewModel.loadRankings(gender: selectedGender, ageCategory: selectedAge, meet: selectedMeet) }
        }
    }
}

#Preview {
    InternationalRankingsView()
}

