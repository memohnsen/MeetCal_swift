//
//  EventInfo.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/4/25.
//

import SwiftUI

struct EventInfoView: View {
    @StateObject private var viewModel = MeetsScheduleModel()
    @AppStorage("selectedMeet") private var selectedMeet = ""
    
    var meetDetails: [MeetDetailsRow] { viewModel.meetDetails }
    
    func timeZoneShortHand(timeZone: String?) -> String {
        switch timeZone {
        case "America/New_York": "Eastern"
        case "America/Los_Angeles": "Pacific"
        case "America/Denver": "Mountain"
        default: "Central"
        }
    }
    
    private func openInMaps(address: String?) {
        let encodedAddress = address?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "http://maps.apple.com/?q=\(encodedAddress)"
        if let url = URL(string: urlString) {
              UIApplication.shared.open(url)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading) {
                        Text(meetDetails.first?.name ?? "Unknown Event")
                            .bold()
                            .font(.headline)
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        Text("Location")
                            .bold()
                        Button(action: {
                            openInMaps(address: "\(meetDetails.first?.venue_street ?? "Unknown Street") \(meetDetails.first?.venue_city ?? "Unknown City, ") \(meetDetails.first?.venue_state ?? "State")")
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(meetDetails.first?.venue_name ?? "Unknown Venue")
                                    Text(meetDetails.first?.venue_street ?? "Unknown Street")
                                    Text("\(meetDetails.first?.venue_city ?? "Unknown City, "), \(meetDetails.first?.venue_state ?? "State"), \(meetDetails.first?.venue_zip ?? " and Zip Code")")
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                        }
                        .foregroundStyle(.blue)

                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        Text("Venue Time Zone")
                            .bold()
                        Text(timeZoneShortHand(timeZone: meetDetails.first?.time_zone))
                    }
                    .cardStyling()
                    .padding(.bottom, 12)
                    
                    VStack(alignment: .leading) {
                        Text("Disclaimer")
                            .bold()
                        Divider()
                        Text("MeetCal is in no way affiliated with USA Weightlifting (USAW), USA Masters Weightlifting (USAMW), or any other Governing Body. All of the information on this app is accurate based on the information provided by the event organizers. The event organizers can and do occasionally change the location of sessions, please check their Instagram for any platform or time changes.")
                    }
                    .cardStyling()
                }
                .padding(.horizontal)
            }
            .navigationTitle("Event Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .tabBar)
        }
        .task {
            await viewModel.loadMeetDetails(meetName: selectedMeet)
        }
    }
}

#Preview {
    EventInfoView()
}
