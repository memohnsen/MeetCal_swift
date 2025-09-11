//
//  FilterButton.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/5/25.
//

import SwiftUI

struct FilterButton: View {
    let filter1: String
    let filter2: String
    let filter3: String?
    let action: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
           
            Text("\(filter1) • \(filter2) \((filter3 != nil) ? "• \(filter3 ?? "")" : "")")
                .secondaryText()
                .bold()
            Image(systemName: "chevron.down")
                .secondaryText()
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
