//
//  OfflineModeView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 10/14/25.
//

import SwiftUI
import RevenueCat
import RevenueCatUI

struct OfflineModeView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = MeetsScheduleModel()

    @State private var isDownloaded: Bool = false
    
    var meets: [MeetsRow] { viewModel.threeWeeksMeets }
    
    var body: some View {
        NavigationStack {
            List {
                Section("Schedules") {
                    MeetButtonComponent(colorScheme: colorScheme, meets: meets, isDownloaded: isDownloaded)
                }
                
                Section("Start Lists") {
                    MeetButtonComponent(colorScheme: colorScheme, meets: meets, isDownloaded: isDownloaded)
                }
                
                Section("Competition Data") {
                    ListButtonComponent(colorScheme: colorScheme, title: "A/B Standards", isDownloaded: isDownloaded)
                    ListButtonComponent(colorScheme: colorScheme, title: "Adaptive American Records", isDownloaded: isDownloaded)
                    ListButtonComponent(colorScheme: colorScheme, title: "American Records", isDownloaded: isDownloaded)
                    ListButtonComponent(colorScheme: colorScheme, title: "International Rankings", isDownloaded: isDownloaded)
                    ListButtonComponent(colorScheme: colorScheme, title: "National Rankings", isDownloaded: isDownloaded)
                    ListButtonComponent(colorScheme: colorScheme, title: "Qualifying Totals", isDownloaded: isDownloaded)
                    ListButtonComponent(colorScheme: colorScheme, title: "WSO Records", isDownloaded: isDownloaded)
                }
            }
            .navigationTitle("Offline Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem {
                    Button{
                        
                    } label: {
                        Image(systemName: "arrow.trianglehead.counterclockwise.icloud")
                    }
                }
                ToolbarSpacer()
                ToolbarItem {
                    Button {
                        
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        .task {
            await viewModel.loadMeets3Weeks()
        }
    }
}

struct ListButtonComponent: View {
    let colorScheme: ColorScheme
    let title: String
    let isDownloaded: Bool
    
    var body: some View {
        if isDownloaded {
            Button {
                
            } label: {
                HStack {
                    Text(title)
                        .foregroundStyle(colorScheme == .light ? .black : .white)
                    Spacer()
                    Image(systemName: "checkmark.circle")
                        .foregroundStyle(.green)
                }
            }
        } else {
            Button {
                
            } label: {
                HStack {
                    Text(title)
                        .foregroundStyle(colorScheme == .light ? .black : .white)
                    Spacer()
                    Image(systemName: "arrow.down.circle")
                }
            }
        }
    }
}

struct MeetButtonComponent: View {
    let colorScheme: ColorScheme
    let meets: [MeetsRow]
    let isDownloaded: Bool
    
    var body: some View {
        ForEach(meets, id: \.self) { meet in
            if isDownloaded {
                Button {
                    
                } label: {
                    HStack {
                        Text(meet.name)
                            .foregroundStyle(colorScheme == .light ? .black : .white)
                        Spacer()
                        Image(systemName: "checkmark.circle")
                            .foregroundStyle(.green)
                    }
                }
            } else {
                Button {
                    
                } label: {
                    HStack {
                        Text(meet.name)
                            .foregroundStyle(colorScheme == .light ? .black : .white)
                        Spacer()
                        Image(systemName: "arrow.down.circle")
                    }
                }
            }
        }
    }
}

#Preview {
    OfflineModeView()
}
