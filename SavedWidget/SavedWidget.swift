//
//  SavedWidget.swift
//  SavedWidget
//
//  Created by Maddisen Mohnsen on 10/5/25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), sessions: [], selectedMeet: "")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = loadEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = loadEntry()
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }

    private func loadEntry() -> SimpleEntry {
        print("Widget: loadEntry called")

        guard let sharedDefaults = UserDefaults(suiteName: "group.com.memohnsen.meetcal") else {
            print("Widget: Failed to access App Group")
            return SimpleEntry(date: Date(), sessions: [], selectedMeet: "No App Group")
        }

        let selectedMeet = sharedDefaults.string(forKey: "selectedMeet") ?? ""
        print("Widget: selectedMeet = \(selectedMeet)")

        guard let savedSessionsData = sharedDefaults.data(forKey: "savedSessions") else {
            print("Widget: No saved sessions data found")
            return SimpleEntry(date: Date(), sessions: [], selectedMeet: selectedMeet)
        }

        let decoder = JSONDecoder()
        guard let savedSessions = try? decoder.decode([SessionsRowForWidget].self, from: savedSessionsData) else {
            print("Widget: Failed to decode sessions")
            return SimpleEntry(date: Date(), sessions: [], selectedMeet: selectedMeet)
        }

        print("Widget: Decoded \(savedSessions.count) sessions")

        let widgetSessions = savedSessions.map { session in
            WidgetSession(
                platform: session.platform,
                sessionNumber: session.session_number,
                startTime: session.start_time,
                weightClass: session.weight_class
            )
        }

        return SimpleEntry(date: Date(), sessions: widgetSessions, selectedMeet: selectedMeet)
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

// Simplified version of SessionsRow for widget decoding
struct SessionsRowForWidget: Codable {
    let platform: String
    let session_number: Int
    let start_time: String
    let weight_class: String
}

struct WidgetSession: Codable {
    let platform: String
    let sessionNumber: Int
    let startTime: String
    let weightClass: String

    var formattedStartTime: String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "HH:mm:ss"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")

        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .none
        outputFormatter.timeStyle = .short
        outputFormatter.locale = Locale(identifier: "en_US")

        if let time = inputFormatter.date(from: startTime) {
            return outputFormatter.string(from: time)
        }
        return startTime
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let sessions: [WidgetSession]
    let selectedMeet: String
}

struct Platform: View {
    let text: String
    
    func platformColor() -> Color {
        if text == "Red" {
            return Color.red
        } else if text == "White" {
            return Color.gray
        } else if text == "Stars" {
            return Color.indigo
        } else if text == "Stripes" {
            return Color.green
        } else if text == "Rogue" {
            return Color.black
        } else {
            return Color.blue
        }
    }
    
    var body: some View {
        Text(text)
            .frame(width: 45, height: 20)
            .font(.caption)
            .padding(.horizontal, 10)
            .background(platformColor())
            .foregroundStyle(.white)
            .cornerRadius(10)
    }
}

struct SessionView: View {
    var session: WidgetSession

    var body: some View {
        HStack {
            Platform(text: session.platform)
            VStack(alignment: .leading, spacing: 2) {
                Text("Session \(session.sessionNumber) • \(session.formattedStartTime)")
                    .font(.caption)
                    .bold()
                Text("\(session.weightClass)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.bottom, 2)
    }
}

struct MediumWidgetView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.blue)
                Text(entry.selectedMeet.isEmpty ? "MeetCal" : entry.selectedMeet)
                    .font(.caption)
                    .bold()
                    .foregroundStyle(.blue)
                    .lineLimit(1)
                Spacer()
            }
            .padding(.top)

            Divider()

            if entry.sessions.isEmpty {
                Text("No saved sessions")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                ForEach(entry.sessions.prefix(3).indices, id: \.self) { index in
                    SessionView(session: entry.sessions[index])
                }
                Spacer()
            }
        }
    }
}

struct LargeWidgetView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.blue)
                Text(entry.selectedMeet.isEmpty ? "MeetCal" : entry.selectedMeet)
                    .font(.caption)
                    .bold()
                    .foregroundStyle(.blue)
                    .lineLimit(1)
                Spacer()
            }
            .padding(.top)


            Divider()

            if entry.sessions.isEmpty {
                Text("No saved sessions")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                ForEach(entry.sessions.prefix(8).indices, id: \.self) { index in
                    SessionView(session: entry.sessions[index])
                }
                Spacer()
            }
        }
    }
}

struct SavedWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            MediumWidgetView(entry: entry)
        }
    }
}

struct SavedWidget: Widget {
    let kind: String = "SavedWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SavedWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Saved Sessions")
        .description("Get a quick glance at your saved sessions.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}


//MEDIUM CAN DISPLAY 3
#Preview(as: .systemMedium) {
    SavedWidget()
} timeline: {
    SimpleEntry(
        date: .now,
        sessions: [
            WidgetSession(platform: "Red", sessionNumber: 1, startTime: "08:00:00", weightClass: "M81"),
            WidgetSession(platform: "Stripes", sessionNumber: 2, startTime: "10:30:00", weightClass: "W71"),
            WidgetSession(platform: "Stars", sessionNumber: 3, startTime: "14:00:00", weightClass: "M102")
        ],
        selectedMeet: "2025 New England WSO Championships"
    )
}

//LARGE CAN DISPLAY 9
#Preview(as: .systemLarge) {
    SavedWidget()
} timeline: {
    SimpleEntry(
        date: .now,
        sessions: [
            WidgetSession(platform: "Red", sessionNumber: 1, startTime: "08:00:00", weightClass: "M81"),
            WidgetSession(platform: "Blue", sessionNumber: 2, startTime: "10:30:00", weightClass: "W71"),
            WidgetSession(platform: "Stars", sessionNumber: 3, startTime: "14:00:00", weightClass: "M102"),
            WidgetSession(platform: "White", sessionNumber: 4, startTime: "16:00:00", weightClass: "W59"),
            WidgetSession(platform: "Stripes", sessionNumber: 5, startTime: "18:30:00", weightClass: "M89"),
            WidgetSession(platform: "Rogue", sessionNumber: 6, startTime: "20:00:00", weightClass: "W76"),
            WidgetSession(platform: "Red", sessionNumber: 7, startTime: "09:00:00", weightClass: "M73"),
            WidgetSession(platform: "Blue", sessionNumber: 8, startTime: "12:00:00", weightClass: "W64"),
            WidgetSession(platform: "Stars", sessionNumber: 9, startTime: "15:30:00", weightClass: "M96")
        ],
        selectedMeet: "2025 New England WSO Championships"
    )
}
