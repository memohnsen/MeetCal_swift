//
//  ScheduleDetails.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/1/25.
//

import SwiftUI

struct ScheduleDetailsView: View {
    @StateObject private var viewModel = ScheduleDetailsModel()
    
    let meet: String
    let date: Date
    let sessionNum: Int
    let platformColor: String
    let weightClass: String
    let startTime: String
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    TopView(sessionNum: sessionNum, platformColor: platformColor, weightClass: weightClass, startTime: startTime)
                        .padding(.bottom, 8)
                    
                    BottomView(viewModel: viewModel)
                }
                .padding(.horizontal)
                .navigationTitle(date.formatted(date: .long, time: .omitted))
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .task {
            await viewModel.loadAthletes(meet: meet, sessionID: sessionNum, platform: platformColor)
        }
    }
}

struct TopView: View {
    @Environment(\.colorScheme) var colorScheme

    let sessionNum: Int
    let platformColor: String
    let weightClass: String
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
        .cornerRadius(32)
    }
}

struct BottomView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: ScheduleDetailsModel

    var athletes: [AthleteRow] { viewModel.athletes }
    var results: [AthleteResults] { viewModel.athleteResults }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Session Athletes")
                .bold()
                .padding(.bottom, 4)
                .padding(.top, 12)
            
            Divider()
            
            ForEach(athletes, id: \.member_id) { athlete in
                Text(athlete.name)
                    .bold()
                    .padding(.top, 8)
                
                VStack(alignment: .leading) {
                    Text("Age: \(athlete.age) • Weight Class: \(athlete.weight_class)")
                        .foregroundStyle(colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                        .padding(.top, 0.5)
                        .font(.system(size: 16))
                    
                    Text(athlete.club)
                        .foregroundStyle(colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                        .padding(.top, 0.5)
                        .font(.system(size: 16))
                    
                    HStack {
                        VStack {
                            Text("Entry Total")
                                .secondaryText()
                                .padding(.bottom, 0.5)
                            Text("\(athlete.entry_total)kg")
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
        .cornerRadius(32)
    }
}

#Preview {
    ScheduleDetailsView(meet: "2025 New England WSO Championships", date: .now, sessionNum: 1, platformColor: "Blue", weightClass: "F 58B", startTime: "8:00")
}
