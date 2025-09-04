//
//  EventInfo.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/4/25.
//

import SwiftUI

struct EventDetails {
    let eventName: String
    let eventVenueName: String
    let venueStreet: String
    let venueCityStateZip: String
    let timeZone: String
}

struct EventInfoView: View {
    let event: [EventDetails] = [
        EventDetails(eventName: "IMWA Master's World Championships", eventVenueName: "Westgate Resort", venueStreet: "3000 Paradise Road", venueCityStateZip: "Las Vegas, NV 89109", timeZone: "Pacific")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading) {
                        Text(event[0].eventName)
                            .bold()
                            .font(.headline)
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        Text("Location")
                            .bold()
                        NavigationLink(destination: ScheduleView(),) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(event[0].eventVenueName)
                                    Text(event[0].venueStreet)
                                    Text(event[0].venueCityStateZip)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                        }
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        Text("Venue Time Zone")
                            .bold()
                        Text(event[0].timeZone)
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
        }
        
    }
}

#Preview {
    EventInfoView()
}
