//
//  ScheduleDetails.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/1/25.
//

import SwiftUI

struct ScheduleDetailsView: View {
    @State private var date: Date = Date.now
    
    let athletes: [Athlete] = [
        Athlete(id: 1, name: "Alexander Nordstrom", details: [
            .init(age: 25, weightClass: "88kg", club: "POWER & GRACE PERFORMANCE.", entryTotal: 130)
        ]),
        Athlete(id: 2, name: "Ashlie Pankonin", details: [
            .init(age: 30, weightClass: "77kg", club: "POWER & GRACE PERFORMANCE.", entryTotal: 200)
        ]),
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    TopView(sessionNum: "1", platformColor: "Red", weightClass: "88kg A", weighTime: "7:00 AM EST", startTime: "9:00 AM EST")
                        .padding(.bottom, 8)
                    
                    VStack(alignment: .leading) {
                        Text("Session Athletes")
                            .bold()
                            .padding(.vertical)
                        
                        Divider()
                        
                        ForEach(athletes) {athlete in
                            Text(athlete.name)
                                .bold()
                            
                            ForEach(athlete.details) {details in
                                Text("Age: \(details.age) • Weight Class: \(details.weightClass)")
                                    .secondaryText()
                                Text(details.club)
                                    .secondaryText()
                                
                                HStack {
                                    VStack {
                                        Text("Entry Total")
                                            .secondaryText()
                                        Text("230kg")
                                            .bold()
                                    }
                                    
                                    VStack {
                                        Text("Best Sn")
                                            .secondaryText()
                                        Text("100kg")
                                            .bold()
                                    }
                                    
                                    VStack {
                                        Text("Best CJ")
                                            .secondaryText()
                                        Text("130kg")
                                            .bold()
                                    }
                                    
                                    VStack {
                                        Text("Best Total")
                                            .secondaryText()
                                        Text("230kg")
                                            .bold()
                                    }
                                }
                                .padding(.vertical, 8)

                                
                                NavigationLink(destination: ScheduleView()) {
                                    Text("See All Meet Results")
                                }
                                
                                Divider()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .background(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .navigationTitle(date.formatted(date: .long, time: .omitted))
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

struct TopView: View {
    let sessionNum: String
    let platformColor: String
    let weightClass: String
    let weighTime: String
    let startTime: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Session \(sessionNum) • \(platformColor) • \(startTime)")
                .secondaryText()
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
        .padding()
        .frame(maxWidth: .infinity)
        .background(.white)
        .cornerRadius(12)
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

#Preview {
    ScheduleDetailsView()
}
