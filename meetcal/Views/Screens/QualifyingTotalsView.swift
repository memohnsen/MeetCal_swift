//
//  QualifyingTotalsView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/4/25.
//

import SwiftUI

struct QualifyingTotal: Hashable {
    let id = UUID()
    let ageGroup: String
    let weightClass: String
    let total: String
}

struct QualifyingTotalsView: View {
    let qualifyingTotals = [
        QualifyingTotal(ageGroup: "Senior", weightClass: "60kg", total: "209kg"),
        QualifyingTotal(ageGroup: "Senior", weightClass: "65kg", total: "227kg"),
        QualifyingTotal(ageGroup: "Senior", weightClass: "71kg", total: "256kg"),
        QualifyingTotal(ageGroup: "Senior", weightClass: "79kg", total: "272kg"),
        QualifyingTotal(ageGroup: "Senior", weightClass: "88kg", total: "289kg"),
        QualifyingTotal(ageGroup: "Senior", weightClass: "94kg", total: "300kg"),
        QualifyingTotal(ageGroup: "Senior", weightClass: "110kg", total: "309kg"),
        QualifyingTotal(ageGroup: "Senior", weightClass: "110+kg", total: "312kg")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack {
                    FilterButton(filter1: "Senior", filter2: "60kg", filter3: "Men")
                    
                    Divider()
                        .padding(.top)
                        .padding(.bottom, 2)
                    
                    
                    VStack {
                        List {
                            HStack {
                                Text("Weight Class")
                                    .frame(width: 200, alignment: .leading)
                                    .bold()
                                Text("Total")
                                Spacer()
                            }
                            .bold()
                            .secondaryText()
                            
                            ForEach(qualifyingTotals, id: \.self) { total in
                                DataSectionView(weightClass: total.weightClass, data: total.total, width: 200)
                            }
                        }
                    }
                    .padding(.top, -10)
                    
                    Spacer()
                }
            }
            .navigationTitle("Qualifying Totals")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    QualifyingTotalsView()
}
