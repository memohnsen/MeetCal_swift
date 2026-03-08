//
//  ReleaseNotesSheet.swift
//  meetcal
//
//  Created by OpenAI on 10/8/25.
//

import SwiftUI

struct ReleaseNotesEntry: Identifiable {
    let id = UUID()
    let title: String
    let changes: [String]
}

struct ReleaseNotesCatalog {
    static let entries: [String: ReleaseNotesEntry] = [
        "1.0": ReleaseNotesEntry(
            title: "Welcome to MeetCal",
            changes: [
                "Track meets and schedules in one place.",
                "Save your favorite events for quick access.",
                "Search the start list to find athletes fast."
            ]
        )
    ]

    static func entry(for version: String) -> ReleaseNotesEntry {
        entries[version] ?? ReleaseNotesEntry(
            title: "What's New in v\(version)",
            changes: [
                "Performance and reliability improvements.",
                "Fresh tweaks across the app experience."
            ]
        )
    }
}

struct ReleaseNotesSheet: View {
    let version: String
    let entry: ReleaseNotesEntry
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text(entry.title)
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Version \(version)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 12) {
                    ForEach(entry.changes, id: \.self) { change in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "sparkles")
                                .foregroundStyle(.accent)
                            Text(change)
                                .font(.body)
                        }
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("What's New")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ReleaseNotesSheet(
        version: "1.0",
        entry: ReleaseNotesCatalog.entry(for: "1.0")
    )
}
