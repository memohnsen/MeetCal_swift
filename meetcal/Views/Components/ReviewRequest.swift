//
//  ReviewRequest.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 10/31/25.
//

import SwiftUI

struct ReviewRequest: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color(red: 36/255, green: 40/255, blue: 49/255)
                .ignoresSafeArea()
            
            VStack(alignment: .center) {
                Spacer()
                
                Text("Please leave a review!")
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)

                Image("meetcal-logo")
                    .resizable()
                    .frame(width: 140, height: 140)
                    .shadow(color: .white.opacity(0.35), radius: 8)
                    .padding(.vertical, 16)
                
                Text("If you love MeetCal, it would help us a ton if you took a minute to leave us review!")
                    .multilineTextAlignment(.center)

                Spacer()

                Link(destination: URL(string: "https://apps.apple.com/us/app/meetcal/id6741133286")!) {
                    Text("Leave A Review")
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                }
                .padding(.bottom, 16)
            }
            .padding(.horizontal)
        }
    }
}
