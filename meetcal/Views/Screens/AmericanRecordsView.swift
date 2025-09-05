//
//  AmericanRecordsView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/5/25.
//

import SwiftUI

struct Records: Hashable {
    let id = UUID()
    let ageGroup: String
    let weightClass: String
    let snatchRecord: String
    let cjRecord: String
    let totalRecord: String
}

struct AmRecordsModal: Hashable {
    let id = UUID()
    let federation: String
    let weightClass: String
    let gender: String
}

struct AmericanRecordsView: View {
    @State private var isModalShowing: Bool = false
    @State private var federationDefault: String = "USAW"
    @State private var weightClassDefault: String = "60kg"
    @State private var genderDefault: String = "Men"
    
    let amRecordsModal: [AmRecordsModal] = [
        AmRecordsModal(federation: "USAW", weightClass: "60kg", gender: "Men"),
        AmRecordsModal(federation: "USAW", weightClass: "65kg", gender: "Women"),
        AmRecordsModal(federation: "USAW", weightClass: "77kg", gender: "Men"),
        AmRecordsModal(federation: "USAW", weightClass: "88kg", gender: "Women"),
        AmRecordsModal(federation: "USAMW", weightClass: "94kg", gender: "Men"),
        AmRecordsModal(federation: "USAMW", weightClass: "86kg", gender: "Women"),
        AmRecordsModal(federation: "USAMW", weightClass: "110kg", gender: "Men"),
        AmRecordsModal(federation: "USAMW", weightClass: "48kg", gender: "Women"),

    ]
    
    let amRecords = [
        Records(ageGroup: "Senior", weightClass: "60kg", snatchRecord: "160kg", cjRecord: "200kg", totalRecord: "360kg"),
        Records(ageGroup: "Senior", weightClass: "60kg", snatchRecord: "160kg", cjRecord: "200kg", totalRecord: "360kg"),
        Records(ageGroup: "Senior", weightClass: "60kg", snatchRecord: "160kg", cjRecord: "200kg", totalRecord: "360kg"),
        Records(ageGroup: "Senior", weightClass: "60kg", snatchRecord: "160kg", cjRecord: "200kg", totalRecord: "360kg"),
        Records(ageGroup: "Senior", weightClass: "60kg", snatchRecord: "160kg", cjRecord: "200kg", totalRecord: "360kg"),
        Records(ageGroup: "Senior", weightClass: "60kg", snatchRecord: "160kg", cjRecord: "200kg", totalRecord: "360kg"),
        Records(ageGroup: "Senior", weightClass: "60kg", snatchRecord: "160kg", cjRecord: "200kg", totalRecord: "360kg")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack {
                    FilterButton(filter1: "USAW", filter2: "60kg", filter3: "Men")
                    
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
                            
                            ForEach(amRecords, id: \.self) { record in
                                HStack {
                                    DataSectionView(weightClass: record.weightClass, data: record.snatchRecord, width: 120)
                                    Text(record.cjRecord)
                                    Spacer()
                                    Spacer()
                                    Spacer()
                                    Text(record.totalRecord)
                                    Spacer()
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding(.top, -10)
                    
                    Spacer()
                }
            }
            .navigationTitle("American Records")
            .navigationBarTitleDisplayMode(.inline)
        }
//        .overlay(
//            Group {
//                if isModalShowing {
//                    Color.black.opacity(0.4)
//                        .ignoresSafeArea()
//                        .onTapGesture { isModalShowing = false }
//
//                    VStack(spacing: 0) {
//                        ForEach(amRecordsModal, id: \.self) { options in
//                            HStack {
//                                Button(action: {
//                                    showingMeetsOverlay = false
//                                }) {
//                                    Text(options)
//                                        .padding()
//                                        .frame(maxWidth: .infinity)
//                                        .foregroundStyle(meet == selectedMeet ? Color.blue : Color.black)
//                                }
//                                Spacer()
//                                if options == selectedMeet {
//                                    Image(systemName: "checkmark")
//                                        .foregroundStyle(.blue)
//                                }
//                                Spacer()
//                            }
//                            .background(meet == selectedMeet ? Color.gray.opacity(0.1) : Color.white)
//                            
//                            Divider()
//                        }
//                    }
//                    .frame(maxWidth: 350)
//                    .background(Color.white)
//                    .cornerRadius(16)
//                    .shadow(radius: 20)
//                    .padding(.horizontal, 30)
//                }
//            }
//        )
    }
}

#Preview {
    AmericanRecordsView()
}
