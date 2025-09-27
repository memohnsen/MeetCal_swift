//
//  FilterButton.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/5/25.
//

import SwiftUI

struct FilterButton: View {
    @Environment(\.colorScheme) var colorScheme

    let filter1: String
    let filter2: String
    let filter3: String?
    let action: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
           
            Text("\(filter1) • \(filter2.capitalized) \((filter3 != nil) ? "• \(filter3?.capitalized ?? "")" : "")")
                .foregroundStyle(colorScheme == .light ? .black : .white)
                .bold()
            Image(systemName: "chevron.down")
                .foregroundStyle(colorScheme == .light ? .black : .white)
                .bold()
            
            Spacer()
        }
        .cardStyling()
        .padding(.horizontal)
        .padding(.top, 8)
        .onTapGesture {
            action()
        }
    }
}

#Preview {
    FilterButton(filter1: "Senior", filter2: "60kg", filter3: nil, action: {})
}
