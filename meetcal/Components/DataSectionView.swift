//
//  DataSectionView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/5/25.
//

import SwiftUI

struct DataSectionView: View {
    let weightClass: String?
    let data: String
    let width: CGFloat
    
    var body: some View {
        HStack{
            Text(weightClass ?? "")
                .frame(width: width, alignment: .leading)
            HStack {
                Text(data)
                Spacer()
            }
        }
    }
}

#Preview {
    DataSectionView(weightClass: "60kg", data: "100kg", width: 200)
}
