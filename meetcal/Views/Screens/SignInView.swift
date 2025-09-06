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
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                Image("meetcal-logo")
                    .resizable()
                    .frame(width: 140, height: 140)
                    .shadow(radius: 8)
                
                Spacer()
                
                Text("Welcome to MeetCal")
                    .font(.title)
                    .bold()
                    .padding(.bottom, 4)
                Text("Sign in to start your journey")
                    .secondaryText()
                
                Spacer()
                
                SignInWithAppleButton(onRequest: { request in
                    
                }, onCompletion: { result in
                    
                })
                .frame(height: 45)
                .cornerRadius(12)
                
                Button{
                    
                } label: {
                    Image("google")
                        .resizable()
                        .frame(width: 15, height: 15)
                    Text("Sign In With Google")
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
                
                Spacer()
                
                Text("Your weightlifting meets, perfectly organized")
                    .secondaryText()
                    .padding(.bottom)
                    .font(.system(size: 14))
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    SignInView()
}
