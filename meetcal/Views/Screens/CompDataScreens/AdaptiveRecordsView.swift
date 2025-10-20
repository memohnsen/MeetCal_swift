//
//  StandardsView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/5/25.
//

import Combine
import SwiftUI
import Supabase

struct AdaptiveRecordsView: View {
    @StateObject private var viewModel = AdaptiveRecordsModel()
    @StateObject private var customerManager = CustomerInfoManager()
    @Environment(\.colorScheme) var colorScheme

    @State private var appliedGender: String = "Men"
    
    let genders: [String] = ["Men", "Women"]

    func getWeightClasses(for gender: String) -> [String] {
        switch gender {
        case "Men":
            return ["60kg", "65kg", "71kg", "79kg", "88kg", "94kg", "110kg", "110+kg"]
        case "Women":
            return ["48kg", "53kg", "58kg", "63kg", "69kg", "77kg", "86kg", "86+kg"]
        default:
            return []
        }
    }

    var filteredRecords: [AdaptiveRecord] {
        let validWeightClasses = Set(getWeightClasses(for: appliedGender))
        return viewModel.groupedRecords.filter { validWeightClasses.contains($0.weightClass) }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack {
                    Picker("\(appliedGender)", selection: $appliedGender) {
                        ForEach(genders, id: \.self) {
                            Text($0)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .pickerStyle(.segmented)
                    
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
                            List {
                                HStack {
                                    Text("Class")
                                        .frame(width: 60, alignment: .leading)
                                    Spacer()
                                    Text("Snatch")
                                        .frame(width: 60, alignment: .leading)
                                    Spacer()
                                    Text("CJ")
                                        .frame(width: 60, alignment: .leading)
                                    Spacer()
                                    Text("Total")
                                        .frame(width: 60, alignment: .leading)
                                }
                                .bold()
                                .foregroundStyle(colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)

                                ForEach(filteredRecords) { record in
                                    VStack(spacing: 4) {
                                        HStack {
                                            Text(record.weightClass)
                                                .frame(width: 60, alignment: .leading)
                                            Spacer()
                                            Text("\(String(Int(record.snatch_best)))kg")
                                                .frame(width: 60, alignment: .leading)
                                            Spacer()
                                            Text("\(String(Int(record.cj_best)))kg")
                                                .frame(width: 60, alignment: .leading)
                                            Spacer()
                                            Text("\(String(Int(record.total)))kg")
                                                .frame(width: 60, alignment: .leading)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                    .padding(.top, -10)
                    
                }
            }
            .navigationTitle("Adaptive American Records")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .tabBar)
        }
        .task {
            AnalyticsManager.shared.trackScreenView("Adaptive Records")
            AnalyticsManager.shared.trackStandardsViewed()
            await customerManager.fetchCustomerInfo()
        }
        .task {
            viewModel.groupedRecords.removeAll()
            await viewModel.loadAdaptiveRecords(gender: appliedGender)
        }
        .onChange(of: appliedGender) {
            Task {
                viewModel.groupedRecords.removeAll()
                await viewModel.loadAdaptiveRecords(gender: appliedGender)
            }
        }
    }
}

#Preview {
    AdaptiveRecordsView()
}
