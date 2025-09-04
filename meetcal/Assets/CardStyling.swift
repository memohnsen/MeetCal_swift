//
//  CardStyling.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/4/25.
//

import SwiftUI

struct CardStyling: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .padding()
            .background(.white)
            .cornerRadius(12)
    }
}

extension View {
    func cardStyling() -> some View {
        self.modifier(CardStyling())
    }
}
