//
//  CompDataView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/13/25.
//

import SwiftUI

struct CompDataView: View {
    @State private var darkMode: Bool = false
    var body: some View {
        NavigationStack{
            List {
                NavigationLink(destination: EventInfoView()) {
                    Text("Event Info")
                }
//                    NavigationLink(destination: ScheduleView()) {
//                        Text("Weightlifting Wrapped")
//                    }
                NavigationLink(destination: QualifyingTotalsView()) {
                    Text("Qualifying Totals")
                }
                
                Section("Records") {
                    NavigationLink(destination: AmericanRecordsView()) {
                        Text("American Records")
                    }
                    NavigationLink(destination: WSORecordsView()) {
                        Text("WSO Records")
                    }
//                    NavigationLink(destination: ScheduleView()) {
//                        Text("Adaptive Records")
//                    }
                }
                
                Section("International") {
                    NavigationLink(destination: StandardsView()) {
                        Text("A/B Standards")
                    }
                    NavigationLink(destination: InternationalRankingsView()) {
                        Text("International Rankings")
                    }
                }
                



            }
            .navigationTitle("Competition Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .tabBar)
            .padding(.top, -10)
        }
    }
}

#Preview {
    CompDataView()
}
