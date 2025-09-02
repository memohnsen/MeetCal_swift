//
//  ScheduleView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/1/25.
//

import SwiftUI

struct SavedView: View {
    var body: some View {
        NavigationStack {
            VStack {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        ButtonComponent(image: "plus", action: {}, title: "Create Session")
                        ButtonComponent(image: "calendar", action: {}, title: "Add to Calendar")
                    }
                    HStack {
                        ButtonComponent(image: "bookmark", action: {}, title: "Saved Warmups")
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal)

                Divider()
                
                List {
                    Section {
                        Text("element")
                        Text("element")
                        Text("element")
                        Text("element")
                        Text("element")
                        Text("element")
                        Text("element")
                        Text("element")
                        Text("element")
                        Text("element")
                        Text("element")
                        Text("element")
                        Text("element")
                        Text("element")
                        Text("element")
                        Text("element")

                
                    }
                }
                .padding(.top, -8)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Saved")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SavedView()
}
