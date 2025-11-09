//
//  ScheduleView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/1/25.
//

import SwiftUI

struct SponsorView: View {
    var body: some View {
        NavigationStack{
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Support the business that support weightlifting.")
                            .multilineTextAlignment(.center)
                            .font(.system(size: UIScreen.main.bounds.width < 415 ? 15 : (UIScreen.main.bounds.width < 431 ? 16 : 17)))
                        Text("For the community, by the community.")
                            .multilineTextAlignment(.center)
                            .font(.system(size: UIScreen.main.bounds.width < 415 ? 15 : (UIScreen.main.bounds.width < 431 ? 16 : 17)))
                            .padding(.top, -15)
                        
                        Divider()
                        
                        SponsorCard(title: "The Art of Barbell", caption: "Capture The Moments That Matter Most", code: "Use code MEETCAL for 20% off!", image: "theartofbarbell", link: "https://nikkijeanphotography.pixieset.com/contact-form/cf_ZnYPcTFnBcJEyiV6tpsKab7NbOdQ")
                        SponsorCard(title: "Power & Grace Performance", caption: "Data-Driven Programming, Nation-Wide", code: "Team Support, and Coaching Education", image: "powergrace", link: "https://powerandgraceperformance.com")
                        SponsorCard(title: "War Games", caption: "Better Coaches, Better Athletes", code: "Use code MEETCAL20 for 20% off!", image: "wg-ad", link: "https://wl-wargames.com")

                        Divider()
                        
                        Text("Intested in partnering with us? Contact us at: ")
                        Link("maddisen@meetcal.app", destination: URL(string: "mailto:maddisen@meetcal.app")!)
                    }
                    .padding()
                    .navigationTitle("Partners")
                    .navigationBarTitleDisplayMode(.inline)
                    .background(Color(.systemGroupedBackground))
                }
            }
        }
        .onAppear {
            AnalyticsManager.shared.trackScreenView("Sponsors")
            AnalyticsManager.shared.trackSponsorTabViewed()
        }
    }
}

struct SponsorCard: View {
    @Environment(\.colorScheme) var colorScheme

    let title: String
    let caption: String
    let code: String
    let image: String
    let link: String

    var body: some View {
        Link(destination: URL(string: link)!) {
            VStack(alignment: .leading, spacing: 10) {
                Image(image)
                    .resizable()
                    .frame(height: 150)
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(title)
                            .font(.system(size: 18))
                            .bold()
                        Text(caption)
                            .font(.system(size: 14))
                        Text(code)
                            .font(.system(size: 14))
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding(.horizontal)
                .padding(.top, 5)
                .padding(.bottom, 10)
                .foregroundStyle(colorScheme == .light ? .black : .white)
            }
            .background(colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
            .cornerRadius(32)
        }
        .simultaneousGesture(TapGesture().onEnded {
            AnalyticsManager.shared.trackSponsorClicked(sponsorName: title)
        })
    }
}

#Preview {
    SponsorView()
}
