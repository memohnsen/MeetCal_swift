//
//  MeetResults.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/4/25.
//

import SwiftUI

struct MeetResultsView: View {
    @State var meets: [MeetHistory] = [
        MeetHistory(name: "Alexander Nordstrom", meetName: "Virus Weightlifting Series 2, Powered by Rogue", meetDate: "08/29/2025", weightClass: "Open Men's 88kg", snatch1: 115, snatch2: 120, snatch3: 125, cj1: 145, cj2: 150, cj3: 155, snatchBest: 125, CJBest: 155, total: 280),
        MeetHistory(name: "Alexander Nordstrom", meetName: "Virus Weightlifting Series 2, Powered by Rogue", meetDate: "08/29/2025", weightClass: "Open Men's 88kg", snatch1: 115, snatch2: -120, snatch3: 125, cj1: -145, cj2: 150, cj3: 155, snatchBest: 125, CJBest: 155, total: 280)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    MakeRate(meets: meets)
                        .padding(.bottom, 12)
                        .padding(.horizontal)

                    
                    MeetInfo(meets: meets)
                        .padding(.horizontal)
                }
                .navigationTitle(meets[0].name)
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

struct MeetHistory: Hashable {
    let name: String
    let meetName: String
    let meetDate: String
    let weightClass: String
    
    let snatch1: Int
    let snatch2: Int
    let snatch3: Int
    let cj1: Int
    let cj2: Int
    let cj3: Int
    let snatchBest: Int
    let CJBest: Int
    let total: Int
}

struct MakeRate: View {
    let meets: [MeetHistory]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Success Rates")
                .bold()
                .font(.title3)
            
            Divider()
                .padding(.vertical, 8)
            
            HStack {
                VStack {
                    HStack {
                        Text("Snatch")
                            .secondaryText()
                        Spacer()
                        Text("74.4%")
                            .bold()
//                          .foregroundStyle(if percent is greater than 80% green, if 70-80 yellow, if sub 70 red)

                    }
                    .padding(.bottom, 8)
                    
                    HStack {
                        Text("1")
                            .secondaryText()
                        Spacer()
                        Text("75.0%")
                        //                          .foregroundStyle(if percent is greater than 80% green, if 70-80 yellow, if sub 70 red)

                        Spacer()
                        Text("21/28")
                            .secondaryText()
                    }
                    
                    HStack {
                        Text("2")
                            .secondaryText()
                        Spacer()
                        Text("85.0%")
                        //                          .foregroundStyle(if percent is greater than 80% green, if 70-80 yellow, if sub 70 red)
                        
                        Spacer()
                        Text("24/28")
                            .secondaryText()
                    }
                    .padding(.vertical, 6)
                    
                    HStack {
                        Text("3")
                            .secondaryText()
                        Spacer()
                        Text("55.0%")
                        //                          .foregroundStyle(if percent is greater than 80% green, if 70-80 yellow, if sub 70 red)

                        Spacer()
                        Text("15/28")
                            .secondaryText()
                    }
                }
                
                Rectangle()
                    .frame(width: 0.35)
                    .frame(height: 120)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                
                VStack {
                    HStack {
                        Text("C&J")
                            .secondaryText()
                        Spacer()
                        Text("74.4%")
                            .bold()
                    }
                    .padding(.bottom, 8)

                    HStack {
                        Text("1")
                            .secondaryText()
                        Spacer()
                        Text("75.0%")
                        //                          .foregroundStyle(if percent is greater than 80% green, if 70-80 yellow, if sub 70 red)

                        Spacer()
                        Text("21/28")
                            .secondaryText()
                    }
                    
                    HStack {
                        Text("2")
                            .secondaryText()
                        Spacer()
                        Text("85.0%")
                        //                          .foregroundStyle(if percent is greater than 80% green, if 70-80 yellow, if sub 70 red)

                        Spacer()
                        Text("24/28")
                            .secondaryText()
                    }
                    .padding(.vertical, 6)

                    HStack {
                        Text("3")
                            .secondaryText()
                        Spacer()
                        Text("55.0%")
                        //                          .foregroundStyle(if percent is greater than 80% green, if 70-80 yellow, if sub 70 red)

                        Spacer()
                        Text("15/28")
                            .secondaryText()
                    }
                }
            }
            
            HStack {
                
            }
        }
        .cardStyling()

    }
}

struct MeetInfo: View {
    let meets: [MeetHistory]
    
    var body: some View {
        VStack {
            ForEach(meets, id: \.self) {meet in
                VStack(alignment: .leading) {
                    Text(meet.meetName)
                        .bold()
                        .font(.headline)
                    
                    Text(meet.meetDate)
                        .secondaryText()
                        .font(.system(size: 16))
                        .padding(.vertical, 0.5)
                    
                    Text(meet.weightClass)
                        .secondaryText()
                        .font(.system(size: 16))
                    
                    Divider()
                        .padding(.vertical, 12)
                    
                    HStack(alignment: .center) {
                        Text("Snatch")
                            .secondaryText()
                            .frame(width: 160, alignment: .leading) // adjust width as desired
                        HStack {
                            Text(String(meet.snatch1))
                                .foregroundStyle(meet.snatch1 > 0 ? .green : .red)
                                .bold()
                            Spacer()
                            Text(String(meet.snatch2))
                                .foregroundStyle(meet.snatch2 > 0 ? .green : .red)
                                .bold()
                            Spacer()
                            Text(String(meet.snatch3))
                                .foregroundStyle(meet.snatch3 > 0 ? .green : .red)
                                .bold()
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 12)
                    
                    HStack(alignment: .center) {
                        Text("Clean & Jerk")
                            .secondaryText()
                            .frame(width: 160, alignment: .leading) // match width to the above
                        HStack {
                            Text(String(meet.cj1))
                                .foregroundStyle(meet.cj1 > 0 ? .green : .red)
                                .bold()
                            Spacer()
                            Text(String(meet.cj2))
                                .foregroundStyle(meet.cj2 > 0 ? .green : .red)
                                .bold()
                            Spacer()
                            Text(String(meet.cj3))
                                .foregroundStyle(meet.cj3 > 0 ? .green : .red)
                                .bold()
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 12)
                    
                    Text("\(String(meet.snatchBest))/\(String(meet.CJBest))/\(String(meet.total))")
                        .frame(maxWidth: .infinity)
                        .bold()
                }
                .cardStyling()
                .padding(.bottom, 8)
            }
        }
      
    }
}

#Preview {
    MeetResultsView()
}
