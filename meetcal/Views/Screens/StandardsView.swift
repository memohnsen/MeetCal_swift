//
//  StandardsView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/5/25.
//

import SwiftUI

struct Standards: Hashable {
    let id = UUID()
    let ageGroup: String
    let weightClass: String
    let aStandard: String
    let bStandard: String
}

struct StandardsView: View {
    let standards = [
        Standards(ageGroup: "Senior", weightClass: "60kg", aStandard: "200kg", bStandard: "300kg"),
        Standards(ageGroup: "Senior", weightClass: "60kg", aStandard: "200kg", bStandard: "300kg"),
        Standards(ageGroup: "Senior", weightClass: "60kg", aStandard: "200kg", bStandard: "300kg"),
        Standards(ageGroup: "Senior", weightClass: "60kg", aStandard: "200kg", bStandard: "300kg"),
        Standards(ageGroup: "Senior", weightClass: "60kg", aStandard: "200kg", bStandard: "300kg"),
        Standards(ageGroup: "Senior", weightClass: "60kg", aStandard: "200kg", bStandard: "300kg"),
        Standards(ageGroup: "Senior", weightClass: "60kg", aStandard: "200kg", bStandard: "300kg")
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
                            
                            ForEach(standards, id: \.self) { total in
                                HStack {
                                    DataSectionView(weightClass: total.weightClass, data: total.aStandard, width: 160)
                                    Text(total.bStandard)
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
            .navigationTitle("A/B Standards")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    StandardsView()
}
