//
//  CardStyling.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/4/25.
//

import SwiftUI

struct CardStyling: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .padding()
            .background(colorScheme == .light ? .white : Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
    }
}

extension View {
    func cardStyling() -> some View {
        self.modifier(CardStyling())
    }
}
