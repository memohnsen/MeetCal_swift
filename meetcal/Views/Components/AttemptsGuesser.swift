//
//  AttemptsGuesser.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 11/2/25.
//

import SwiftUI

struct AttemptsGuesser: View {
    let athletes: [AthleteRow]
    
    var snatchAttemptsOut: Int = 20
    var cjAttemptsOut: Int = 13
    
    var body: some View {
        NavigationStack{
            List{
                ForEach(athletes, id: \.self){ athlete in
                    DisclosureGroup(athlete.name){
                        VStack(alignment: .leading, spacing: 8){
                            Text("Estimated Count")
                                .bold()
                            
                            Text("Snatch: \(snatchAttemptsOut) attempts out")
                                .secondaryText()
                            Text("CJ: \(cjAttemptsOut) attempts out")
                                .secondaryText()
                            
                            Divider()
                                .padding(.vertical, 12)
                            
                            Text("Estimated Attempts")
                                .bold()
                                .padding(.bottom, 8)
                            
                            Grid{
                                GridRow{
                                    Text("")
                                    Text("1")
                                        .bold()
                                    Text("2")
                                        .bold()
                                    Text("3")
                                        .bold()
                                }
                                
                                Divider()
                                
                                GridRow{
                                    Text("Snatch")
                                        .bold()
                                    Text("100")
                                        .secondaryText()
                                    Text("105")
                                        .secondaryText()
                                    Text("110")
                                        .secondaryText()
                                }
                                
                                Divider()
                                
                                GridRow{
                                    Text("CJ")
                                        .bold()
                                    Text("120")
                                        .secondaryText()
                                    Text("125")
                                        .secondaryText()
                                    Text("130")
                                        .secondaryText()
                                }
                            }
                            
                            Divider()
                                .padding(.vertical, 12)
                            
                            Text("Athlete Notes")
                                .bold()
                            
                            Text("\(athlete.name) typically takes 3kg in the Snatch and 4kg jumps in the CJ. \(athlete.name) makes their opening Snatch 67% of the time and their opening CJ 20% of the time.")
                                .secondaryText()
                        }
                    }
                }
            }
            .navigationTitle("Attempts Out Guesser")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
