//
//  TextStyles.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/3/25.
//

import SwiftUI

struct SecondaryTextStyling: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(Color(red: 102/255, green: 102/255, blue: 102/255))
    }
}

extension View {
    func secondaryText() -> some View {
        self.modifier(SecondaryTextStyling())
    }
}
