//
//  InternationalRankingsView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/5/25.
//

import SwiftUI

struct Rankings: Hashable {
    let id = UUID()
    let lastName: String
    let weightClass: String
    let total: String
    let percentA: String
}

struct InternationalRankingsView: View {
    let rankings = [
        Rankings(lastName: "Morris", weightClass: "67kg", total: "313", percentA: "105.03%"),
        Rankings(lastName: "Morris", weightClass: "67kg", total: "313", percentA: "105.03%"),
        Rankings(lastName: "Morris", weightClass: "67kg", total: "313", percentA: "105.03%"),
        Rankings(lastName: "Morris", weightClass: "67kg", total: "313", percentA: "105.03%"),
        Rankings(lastName: "Morris", weightClass: "67kg", total: "313", percentA: "105.03%"),
        Rankings(lastName: "Morris", weightClass: "67kg", total: "313", percentA: "105.03%"),
        Rankings(lastName: "Morris", weightClass: "67kg", total: "313", percentA: "105.03%"),
        Rankings(lastName: "Morris", weightClass: "67kg", total: "313", percentA: "105.03%"),
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack {
                    FilterButton(filter1: "2025 Worlds", filter2: "Senior", filter3: "Men")
                    
                    Divider()
                        .padding(.top)
                        .padding(.bottom, 2)
                    
                    
                    VStack {
                        List {
                            HStack {
                                Text("Class")
                                    .frame(width: 90, alignment: .leading)
                                Text("Name")
                                Spacer()
                                Spacer()
                                Spacer()
                                Text("Total")
                                Spacer()
                                Spacer()
                                Spacer()
                                Text("% of A")
                                Spacer()
                                Spacer()
                            }
                            .bold()
                            .secondaryText()
                            
                            ForEach(rankings, id: \.self) { ranking in
                                HStack {
                                    DataSectionView(weightClass: ranking.weightClass, data: ranking.lastName, width: 90)
                                    Text(ranking.total)
                                    Spacer()
                                    Spacer()
                                    Spacer()
                                    Spacer()
                                    Spacer()
                                    Text(ranking.percentA)
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
            .navigationTitle("International Rankings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    InternationalRankingsView()
}

