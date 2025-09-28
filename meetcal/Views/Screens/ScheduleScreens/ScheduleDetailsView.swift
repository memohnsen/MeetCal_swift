//
//  ScheduleDetails.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/1/25.
//

import SwiftUI
import Foundation
import RevenueCatUI
import RevenueCat
import EventKit

struct ScheduleDetailsView: View {
    @AppStorage("selectedMeet") private var selectedMeet: String = ""
    @StateObject private var viewModel = ScheduleDetailsModel()
    @StateObject private var viewModel2 = MeetsScheduleModel()
    @StateObject private var customerManager = CustomerInfoManager()
    
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
                    TopView(date: date, sessionNum: sessionNum, platformColor: platformColor, weightClass: weightClass, startTime: startTime)
                        .padding(.bottom, 8)
                    
                    BottomView(viewModel: viewModel)
                }
                .padding(.horizontal)
                .navigationTitle(date.formatted(date: .long, time: .omitted))
                .navigationBarTitleDisplayMode(.inline)
//                .toolbar{
//                    ToolbarItem{
//                        Image(systemName: "bookmark.fill")
//                    }
//                    ToolbarItem{
//                        Image(systemName: "calendar")
//                    }
//                }
            }
            .toolbar(.hidden, for: .tabBar)
        }
        .task {
            await viewModel.loadAthletes(meet: meet, sessionID: sessionNum, platform: platformColor)
            await viewModel2.loadMeetDetails(meetName: selectedMeet)
            await viewModel.loadAllResults()
        }
    }
}

struct TopView: View {
    @AppStorage("selectedMeet") private var selectedMeet: String = ""
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = MeetsScheduleModel()
    
    @State private var alertShowing: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    var meetDetails: [MeetDetailsRow] { viewModel.meetDetails }

    let date: Date
    let sessionNum: Int
    let platformColor: String
    let weightClass: String
    let startTime: String
    
    func convert24hourTo12hour(time24hour: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "HH:mm:ss"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let date = inputFormatter.date(from: time24hour) else {
            return nil
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "h:mm a"
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let time12hour = outputFormatter.string(from: date)
        
        return time12hour
    }
    
    func timeZoneShortHand() -> String {
        let timeZone = meetDetails.first(where: { $0.name == selectedMeet })?.time_zone ?? "Unknown"

        switch timeZone {
        case "America/New_York": return "Eastern"
        case "America/Los_Angeles": return "Pacific"
        case "America/Denver": return "Mountain"
        default: return "Central"
        }
    }
    
    func addToCal() {
        let eventStore = EKEventStore()
        
        let authStatus = EKEventStore.authorizationStatus(for: .event)
        print("Current auth status: \(authStatus.rawValue)")
        
        eventStore.requestWriteOnlyAccessToEvents { (granted, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error requesting access: \(error.localizedDescription)")
                    return
                }
                
                if granted {
                    self.createEvent(eventStore: eventStore)
                } else {
                    print("Calendar access denied")
                }
            }
        }
    }
    
    private func createEvent(eventStore: EKEventStore) {
        let event = EKEvent(eventStore: eventStore)
        event.title = "Session \(sessionNum) \(platformColor) - \(weightClass)"
        
        let calendar = Calendar.current
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let timeDate = timeFormatter.date(from: startTime) {
            let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: timeDate)
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            
            var combinedComponents = DateComponents()
            combinedComponents.year = dateComponents.year
            combinedComponents.month = dateComponents.month
            combinedComponents.day = dateComponents.day
            combinedComponents.hour = timeComponents.hour
            combinedComponents.minute = timeComponents.minute
            combinedComponents.second = timeComponents.second
            
            if let eventStartDate = calendar.date(from: combinedComponents) {
                event.startDate = eventStartDate
                event.endDate = eventStartDate.addingTimeInterval(7200)
            } else {
                event.startDate = date
                event.endDate = date.addingTimeInterval(7200)
            }
        } else {
            event.startDate = date
            event.endDate = date.addingTimeInterval(7200)
        }
        
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            try eventStore.save(event, span: .thisEvent)
            print("Event saved successfully!")
            alertTitle = "Event Saved Successfully"
            alertMessage = "Session \(sessionNum) \(platformColor) - \(weightClass) is now in your calendar"
            alertShowing = true
        } catch let error as NSError {
            print("Failed to save event: \(error.localizedDescription)")
            alertTitle = "Error saving to calendar"
            alertMessage = "Failed to save event: \(error.localizedDescription)"
            alertShowing = true
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Session \(sessionNum) • \(convert24hourTo12hour(time24hour: startTime) ?? "TBD") \(timeZoneShortHand())")
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
                    addToCal()
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
        .alert(alertTitle, isPresented: $alertShowing) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
}

struct BottomView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: ScheduleDetailsModel
    @StateObject private var customerManager = CustomerInfoManager()
    @State private var navigateToPaywall: Bool = false
    @State private var navigateToResults: Bool = false

    var athletes: [AthleteRow] { viewModel.athletes }
    var results: [AthleteResults] { viewModel.athleteResults }
    
    func getBestResults(for athleteName: String) -> (snatch: Float, cleanJerk: Float, total: Float) {
        let athleteResults = results.filter { $0.name == athleteName }
        let bestSnatch = athleteResults.map { $0.snatch_best }.max() ?? 0
        let bestCleanJerk = athleteResults.map { $0.cj_best }.max() ?? 0
        let bestTotal = athleteResults.map { $0.total }.max() ?? 0
        return (bestSnatch, bestCleanJerk, bestTotal)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Session Athletes")
                .bold()
                .padding(.bottom, 4)
                .padding(.top, 20)
            
            Divider()
            
            ForEach(athletes, id: \.member_id) { athlete in
                VStack(alignment: .leading) {
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
                            
                            if customerManager.hasProAccess {
                                VStack {
                                    Text("Best Sn")
                                        .secondaryText()
                                        .padding(.bottom, 0.5)
                                    Text("\(Int(getBestResults(for: athlete.name).snatch))kg")
                                        .bold()
                                }
                            
                                Spacer()
                                
                                VStack {
                                    Text("Best CJ")
                                        .secondaryText()
                                        .padding(.bottom, 0.5)
                                    Text("\(Int(getBestResults(for: athlete.name).cleanJerk))kg")
                                        .bold()
                                }
                                
                                Spacer()

                                VStack {
                                    Text("Best Total")
                                        .secondaryText()
                                        .padding(.bottom, 0.5)
                                    Text("\(Int(getBestResults(for: athlete.name).total))kg")
                                        .bold()
                                }
                            } else {
                                HStack {
                                    Spacer()
                                    Text("PRO ACCESS ONLY")
                                        .bold()
                                    Spacer()
                                }
                                .padding()
                                .background(.ultraThickMaterial)
                                .background(.blue)
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical, 8)
                        .font(.system(size: 16))

                        if customerManager.hasProAccess {
                            HStack {
                                Spacer()
                                NavigationLink(destination: MeetResultsView(name: athlete.name)) {
                                    Text("See All Meet Results")
                                    Image(systemName: "chevron.right")
                                }
                                .padding(.vertical, 8)
                                Spacer()
                            }
                        } else {
                            Button {
                                navigateToPaywall = true
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("Get Pro To See All Meet Results")
                                        .font(.system(size: 15))
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12))
                                    Spacer()
                                }
                                .foregroundStyle(.blue)
                            }
                            .padding(.vertical, 8)
                            .sheet(isPresented: $navigateToPaywall) {
                                PaywallView()
                            }
                        }
                        Divider()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .background(colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
        .cornerRadius(32)
        .task{
            await customerManager.fetchCustomerInfo()
        }
    }
}

#Preview {
    ScheduleDetailsView(meet: "2025 New England WSO Championships", date: .now, sessionNum: 1, platformColor: "Blue", weightClass: "F 58B", startTime: "8:00")
}
