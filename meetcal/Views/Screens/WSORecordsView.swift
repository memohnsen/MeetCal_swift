//
//  WSORecordsView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/5/25.
//

import SwiftUI

struct WSORecordsView: View {
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
                    FilterButton(filter1: "Carolina", filter2: "60kg", filter3: "Men")
                    
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
            .navigationTitle("WSO Records")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    WSORecordsView()
}
