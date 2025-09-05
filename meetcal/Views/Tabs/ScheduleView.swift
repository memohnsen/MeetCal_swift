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
    @State private var showingMeetsOverlay: Bool = false
    
    @State private var meets: [String] = ["Virus Weightlifting Series 2", "Masters Worlds", "AO Finals", "National Championships", "Carolina WSO Championships"]
    @State private var selectedMeet: String = ""
    
    var body: some View {
        NavigationStack{
            VStack {
                ZStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Selected Meet")
                                .bold()
                                .padding(.bottom, 0.5)
                            Text(!selectedMeet.isEmpty ? selectedMeet : meets[0])
                        }
                        Spacer()
                        Image(systemName: "chevron.down")
                            .secondaryText()
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .onTapGesture {
                        showingMeetsOverlay = true
                    }
                }
                .frame(height: 100)

                SessionElementsView()
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
        .onAppear{
            if selectedMeet == "" {
                selectedMeet = meets[0]
            }
        }
        .overlay(
            Group {
                if showingMeetsOverlay {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture { showingMeetsOverlay = false }

                    VStack(spacing: 0) {
                        Text("Select Your Meet")
                            .font(.headline)
                            .padding()
                        Divider()
                        
                        ForEach(meets, id: \.self) { meet in
                            HStack {
                                Button(action: {
                                    selectedMeet = meet
                                    showingMeetsOverlay = false
                                }) {
                                    Text(meet)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .foregroundStyle(meet == selectedMeet ? Color.blue : Color.black)
                                }
                                Spacer()
                                if meet == selectedMeet {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                                Spacer()
                            }
                            .background(meet == selectedMeet ? Color.gray.opacity(0.1) : Color.white)
                            
                            Divider()
                        }
                    }
                    .frame(maxWidth: 350)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(radius: 20)
                    .padding(.horizontal, 30)
                }
            }
        )
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
                        NavigationLink(destination: ScheduleDetailsView()) {
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
