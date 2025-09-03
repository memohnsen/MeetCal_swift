//
//  Button.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/2/25.
//

import SwiftUI

struct ButtonComponent: View {
    let image: String
    let action: () -> Void
    let title: String
    
    var body: some View {
        Button(action: action) {
            Image(systemName: image)
            Text(title)
        }
        .frame(maxWidth: .infinity, minHeight: 40)
        .secondaryText()
        .background(.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}
