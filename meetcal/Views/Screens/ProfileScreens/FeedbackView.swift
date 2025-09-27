//
//  FeedbackView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/27/25.
//

import SwiftUI

struct FeedbackView: View {
    @State private var feedbackText: String = ""
    let firstName: String
    let lastName: String
    let email: String
    
    var body: some View {
        ZStack{
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            NavigationStack{
                VStack(spacing: 12) {
                    HStack{
                        VStack(alignment: .leading){
                            Text("First Name")
                                .padding(.bottom, 2)
                                .bold()
                            Text(firstName)
                                .secondaryText()
                        }
                        Spacer()
                    }
                    .cardStyling()
                    
                    HStack{
                        VStack(alignment: .leading){
                            Text("Last Name")
                                .padding(.bottom, 2)
                                .bold()
                            Text(lastName)
                                .secondaryText()
                        }
                        Spacer()
                    }
                    .cardStyling()
                    
                    HStack{
                        VStack(alignment: .leading){
                            Text("Email")
                                .padding(.bottom, 2)
                                .bold()
                            Text(email)
                                .secondaryText()
                        }
                        Spacer()
                    }
                    .cardStyling()
                    
                    HStack{
                        VStack(alignment: .leading){
                            Text("Feedback")
                                .padding(.bottom, 2)
                                .bold()
                            TextField("This is the best app ever made...", text: $feedbackText, axis: .vertical)
                        }
                        Spacer()
                    }
                    .cardStyling()
                    
                    HStack {
                        Text("Send Feedback")
                            .bold()
                            .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(.white)
                    .background(.blue)
                    .cornerRadius(12)
                    .contentShape(Rectangle())
                    
                    Spacer()
                }
                .navigationTitle("Submit Feedback")
                .navigationBarTitleDisplayMode(.inline)
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    FeedbackView(firstName: "Maddisen", lastName: "Mohnsen", email: "memohnsen@gmail.com")
}
