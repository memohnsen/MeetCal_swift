//
//  FeedbackView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/27/25.
//

import SwiftUI
import Supabase
import Clerk
import RevenueCat

struct FeedbackView: View {
    @Environment(\.clerk) private var clerk

    @State private var feedbackText: String = ""
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var alertTitle: String = ""
    
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
                            Text(clerk.user?.firstName ?? "Please Sign-In")
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
                            Text(clerk.user?.lastName ?? "Please Sign-In")
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
                            Text(clerk.user?.emailAddresses.first?.emailAddress ?? "Please Sign-In")
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
                    
                    Button(action: {
                        Task {
                            await sendFeedback()
                        }
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text(isLoading ? "Sending..." : "Send Feedback")
                                .bold()
                                .frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundStyle(.white)
                        .background(isLoading ? .gray : .blue)
                        .cornerRadius(12)
                        .contentShape(Rectangle())
                    }
                    .disabled(isLoading || feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    
                    Spacer()
                }
                .navigationTitle("Submit Feedback")
                .navigationBarTitleDisplayMode(.inline)
                .alert(alertTitle, isPresented: $showAlert) {
                    Button("OK") { }
                } message: {
                    Text(alertMessage)
                }
            }
            .padding(.horizontal)
        }
    }
    
    @MainActor
    private func sendFeedback() async {
        guard !feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertTitle = "Error"
            alertMessage = "Please enter your feedback before sending."
            showAlert = true
            return
        }
        
        isLoading = true
        
        do {
            let requestBody = FeedbackRequest(
                name: "\(clerk.user?.firstName ?? "Unknown") \(clerk.user?.lastName ?? "Unknown")",
                email: clerk.user?.emailAddresses.first?.emailAddress ?? "Unknown",
                role: "user",
                description: "My User ID is: \(clerk.user?.id ?? "No ID").\n\nMy Purchase ID is: \(Purchases.shared.appUserID)\n\nMy device and iOS version are: \(UIDevice.current.name) \(UIDevice.current.model) \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)." + feedbackText
            )
            
            try await supabase.functions
                .invoke(
                    "send-feedback",
                    options: FunctionInvokeOptions(
                        body: requestBody
                    )
                )
            
            alertTitle = "Success"
            alertMessage = "Your feedback has been sent successfully!"
            feedbackText = ""
            
        } catch {
            alertTitle = "Error"
            alertMessage = "An unexpected error occurred. Please try again."
            #if DEBUG
            print("Feedback error: \(error)")
            #endif
        }
        
        isLoading = false
        showAlert = true
    }
}

struct FeedbackRequest: Codable {
    let name: String
    let email: String
    let role: String
    let description: String
}

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let message):
            return message
        }
    }
}

#Preview {
    FeedbackView()
}
