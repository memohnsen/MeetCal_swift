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
                Section {
                    NavigationLink(destination: ScheduleView()) {
                        Text("My Profile & Settings")
                    }
                }
                
                Section("Competition Information") {
                    NavigationLink(destination: ScheduleView()) {
                        Text("Qualifying Totals")
                    }
                    NavigationLink(destination: ScheduleView()) {
                        Text("A/B Standards")
                    }
                    NavigationLink(destination: ScheduleView()) {
                        Text("International Rankings")
                    }
                    NavigationLink(destination: ScheduleView()) {
                        Text("American Records")
                    }
                    NavigationLink(destination: ScheduleView()) {
                        Text("WSO Records")
                    }
                    NavigationLink(destination: ScheduleView()) {
                        Text("Adaptive Records")
                    }
                    NavigationLink(destination: ScheduleView()) {
                        Text("Weightlifting Wrapped")
                    }
                }
                
                Section{
                    Toggle("Dark Mode", isOn: $darkMode)
                        .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                }
                
                Section {
                    Button("Reset Saved Sessions", role: .destructive) {
                        
                    }
                    Button("Reset Saved Warmups", role: .destructive) {
                        
                    }
                }
            }
            .navigationTitle("Info")
            .navigationBarTitleDisplayMode(.inline)
            .padding(.top, -40)
        }
    }
}

#Preview {
    SettingsView()
}
