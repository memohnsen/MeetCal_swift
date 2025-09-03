//
//  ScheduleView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/1/25.
//

import SwiftUI

struct Session: Identifiable {
    let id: Int
    let date: String
    let groups: [Group]

    struct Group: Identifiable {
        let id = UUID()
        let platform: String
        let weightClass: String
    }
}

struct ScheduleView: View {
    @State private var meets: [String] = ["Virus Weightlifting Series 2", "Masters Worlds", "AO Finals", "National Championships", "Carolina WSO Championships"]
    @State private var selectedMeet: String = ""
    
    var body: some View {
        NavigationStack{
            VStack {
                HStack {
                    Text("Selected Meet: ")
                        .bold()
                    Spacer()
                    Picker(selectedMeet.isEmpty ? "Select Your Meet" : selectedMeet, selection: $selectedMeet) {
                        ForEach(meets, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.menu)
                }
                .padding(.horizontal, 20)
                
                SessionElementsView()
                }
            }
            .onAppear{
                selectedMeet = meets[0]
            }
    }
}

struct SessionElementsView: View {
    @State private var date: Date = Date.now

    let sessions: [Session] = [
        Session(id: 1, date: "8/9/2025", groups: [
            .init(platform: "Red", weightClass: "88kg"),
            .init(platform: "Blue", weightClass: "94kg")
        ]),
        Session(id: 2, date: "8/9/2025", groups: [
            .init(platform: "Red", weightClass: "60kg"),
            .init(platform: "Blue", weightClass: "71kg")
        ]),
        Session(id: 3, date: "8/9/2025", groups: [
            .init(platform: "Red", weightClass: "60kg"),
            .init(platform: "Blue", weightClass: "71kg")
        ]),
        Session(id: 4, date: "8/9/2025", groups: [
            .init(platform: "Red", weightClass: "60kg"),
            .init(platform: "Blue", weightClass: "71kg")
        ]),
        Session(id: 5, date: "8/9/2025", groups: [
            .init(platform: "Red", weightClass: "60kg"),
            .init(platform: "Blue", weightClass: "71kg")
        ]),
        Session(id: 6, date: "8/9/2025", groups: [
            .init(platform: "Red", weightClass: "60kg"),
            .init(platform: "Blue", weightClass: "71kg")
        ]),
    ]
    
    var body: some View {
        List {
            ForEach(sessions) { session in
                Section(header: Text("Session \(session.id)").foregroundStyle(.black)) {
                    ForEach(session.groups) { group in
                        NavigationLink(destination: ScheduleView()) {
                            HStack {
                                Platform(text: group.platform)
                                
                                VStack(alignment: .leading) {
                                    Text(group.weightClass)
                                        .padding(.vertical, 2)
                                    Text("Start: 9:00am PDT")
                                        .padding(.vertical, 2)
                                }
                                .padding(.leading, 10)
                                .secondaryText()
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(date.formatted(date: .complete, time: .omitted))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ScheduleView()
}
