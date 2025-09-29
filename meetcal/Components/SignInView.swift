//
//  SignInView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/6/25.
//

import SwiftUI
import AuthenticationServices
import GoogleSignIn
import GoogleSignInSwift

struct SignInView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let action: () -> Void

    var body: some View {
        ZStack {
            Color(colorScheme == .light ? .systemGroupedBackground : .secondarySystemGroupedBackground)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                Image("meetcal-logo")
                    .resizable()
                    .frame(width: 140, height: 140)
                    .shadow(color: colorScheme == .light ? .black.opacity(0.35) : .white.opacity(0.35), radius: 8)
                                
                Spacer()
                
                Text("Welcome to MeetCal!")
                    .font(.title)
                    .bold()
                    .padding(.bottom, 80)
                
                HStack {
                    Text("Sign In To Get Started")
                        .font(.system(size: 16))
                }
                .foregroundStyle(.black)
                .frame(height: 45)
                .frame(maxWidth: .infinity)
                .background(.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 2)
                )
                .onTapGesture {
                    action()
                }
                
                Spacer()
                
                Text("Your weightlifting meets, perfectly organized")
                    .secondaryText()
                    .padding(.bottom)
                    .font(.system(size: 14))
            }
            .padding(.horizontal)
            .toolbar(.hidden, for: .tabBar)
        }
    }
}

#Preview {
    SignInView(action: {})
}
