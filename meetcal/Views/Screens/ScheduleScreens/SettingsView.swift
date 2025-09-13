//
//  ScheduleView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/1/25.
//

import SwiftUI

struct SettingsView: View {
    @State var darkMode: Bool = false

    var body: some View {
        NavigationStack{
            List {
                Section("Settings") {
                    NavigationLink(destination: ProfileView()) {
                        Text("My Profile")
                    }
                    Toggle("Dark Mode", isOn: $darkMode)
                        .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                }
                
                Section("Danger Zone") {
                    Button("Reset Saved Sessions", role: .destructive) {
                        
                    }
                    Button("Reset Saved Warmups", role: .destructive) {
                        
                    }
                }
            }
            .navigationTitle("Info")
            .navigationBarTitleDisplayMode(.inline)
            .padding(.top, -10)
        }
    }
}

#Preview {
    SettingsView()
}
