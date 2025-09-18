//
//  ScheduleDetails.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/1/25.
//

import SwiftUI

struct ScheduleDetailsView: View {
    @State private var date: Date = Date.now
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    TopView(sessionNum: "1", platformColor: "Red", weightClass: "88kg A", weighTime: "7:00 AM EST", startTime: "9:00 AM EST")
                        .padding(.bottom, 8)
                    
                    BottomView()
                }
                .padding(.horizontal)
                .navigationTitle(date.formatted(date: .long, time: .omitted))
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

struct TopView: View {
    @Environment(\.colorScheme) var colorScheme

    let sessionNum: String
    let platformColor: String
    let weightClass: String
    let weighTime: String
    let startTime: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Session \(sessionNum) • \(startTime)")
                .foregroundStyle(colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                .padding(.vertical, 6)

            Divider()
            
            HStack {
                Platform(text: platformColor)
                Text(weightClass)
                    .padding(.horizontal, 6)
                    
            }
            .padding(.vertical, 6)
            
            Divider()
                .padding(.vertical, 6)
            
 

            HStack {
                Button("Save Session") {
                    
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .foregroundStyle(.white)
                .background(.blue)
                .cornerRadius(12)
                .padding(.vertical, 6)
                
                Button("Add to Calendar") {
                    
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .foregroundStyle(.white)
                .background(.green)
                .cornerRadius(12)
            }
            
        }
        .cardStyling()
    }
}

struct Athlete: Identifiable {
    let id: Int
    let name: String
    let details: [Details]

    struct Details: Identifiable {
        let id = UUID()
        let age: Int
        let weightClass: String
        let club: String
        let entryTotal: Int
    }
}

struct BottomView: View {
    @Environment(\.colorScheme) var colorScheme

    let athletes: [Athlete] = [
        Athlete(id: 1, name: "Alexander Nordstrom", details: [
            .init(age: 25, weightClass: "88kg", club: "POWER & GRACE PERFORMANCE.", entryTotal: 130)
        ]),
        Athlete(id: 2, name: "Ashlie Pankonin", details: [
            .init(age: 30, weightClass: "77kg", club: "POWER & GRACE PERFORMANCE.", entryTotal: 200)
        ]),
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Session Athletes")
                .bold()
                .padding(.bottom, 4)
                .padding(.top, 12)
            
            Divider()
            
            ForEach(athletes) {athlete in
                Text(athlete.name)
                    .bold()
                    .padding(.top, 8)
                
                ForEach(athlete.details) {details in
                    Text("Age: \(details.age) • Weight Class: \(details.weightClass)")
                        .foregroundStyle(colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                        .padding(.top, 0.5)
                        .font(.system(size: 16))
                    
                    Text(details.club)
                        .foregroundStyle(colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                        .padding(.top, 0.5)
                        .font(.system(size: 16))
                    
                    HStack {
                        VStack {
                            Text("Entry Total")
                                .secondaryText()
                                .padding(.bottom, 0.5)
                            Text("230kg")
                                .bold()
                        }
                        
                        Spacer()
                        
                        VStack {
                            Text("Best Sn")
                                .secondaryText()
                                .padding(.bottom, 0.5)
                            Text("100kg")
                                .bold()
                        }
                        
                        Spacer()
                        
                        VStack {
                            Text("Best CJ")
                                .secondaryText()
                                .padding(.bottom, 0.5)
                            Text("130kg")
                                .bold()
                        }
                        
                        Spacer()
                        
                        VStack {
                            Text("Best Total")
                                .secondaryText()
                                .padding(.bottom, 0.5)
                            Text("230kg")
                                .bold()
                        }
                    }
                    .padding(.vertical, 8)
                    .font(.system(size: 16))


                    
                    HStack {
                        Spacer()
                        NavigationLink(destination: MeetResultsView()) {
                            Text("See All Meet Results")
                            Image(systemName: "chevron.right")
                        }
                        .padding(.vertical, 8)
                        Spacer()
                    }
                    
                    Divider()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .background(colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

#Preview {
    ScheduleDetailsView()
}
