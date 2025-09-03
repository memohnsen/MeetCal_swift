//
//  Platform.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/3/25.
//

import SwiftUI

struct Platform: View {
    let text: String
    
    func platformColor() -> Color {
        if text == "Red" {
            return Color.red  
        } else if text == "White" {
            return Color.gray
        } else if text == "Stars" {
            return Color.indigo
        } else if text == "Stripes" {
            return Color.green
        } else if text == "Rogue" {
            return Color.black
        } else {
            return Color.blue
        }
    }
    
    var body: some View {
        Text(text)
            .frame(width: 50, height: 40)
            .padding(.horizontal, 10)
            .background(platformColor())
            .foregroundStyle(.white)
            .cornerRadius(10)
    }
}
