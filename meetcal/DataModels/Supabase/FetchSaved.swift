//
//  FetchSaved.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/12/25.
//

import SwiftUI
import Supabase
import Combine
import Clerk
import WidgetKit
import SwiftData

struct SessionsRow: Decodable, Identifiable, Hashable, Sendable, Encodable {
    let id: String
    let clerk_user_id: String
    let meet: String
    let session_number: Int
    let platform: String
    let weight_class: String
    let start_time: String
    let date: String
    let notes: String?
    let athlete_names: [String]?

    var formattedStartTime: String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "HH:mm:ss"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")

        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .none
        outputFormatter.timeStyle = .short
        outputFormatter.locale = Locale(identifier: "en_US")

        if let time = inputFormatter.date(from: start_time) {
            return outputFormatter.string(from: time)
        }
        return start_time
    }

    var weighInTime: String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "HH:mm:ss"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")

        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .none
        outputFormatter.timeStyle = .short
        outputFormatter.locale = Locale(identifier: "en_US")

        if let time = inputFormatter.date(from: start_time) {
            let weighInTime = time.addingTimeInterval(-7200)
            return outputFormatter.string(from: weighInTime)
        }
        return start_time
    }

    func dateAsDate(in timeZone: TimeZone) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = timeZone
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: date) ?? Date()
    }

    var dateAsDate: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: date) ?? Date()
    }

    var formattedDate: String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")

        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .full
        outputFormatter.timeStyle = .none
        outputFormatter.locale = Locale(identifier: "en_US")

        if let dateObj = inputFormatter.date(from: date) {
            return outputFormatter.string(from: dateObj)
        }
        return date
    }
}

nonisolated struct SaveSessionRequest: Encodable {
    let id: String
    let clerk_user_id: String
    let meet: String
    let session_number: Int
    let platform: String
    let weight_class: String
    let start_time: String
    let date: String
    let athlete_names: [String]
    let notes: String
}

@MainActor
class SavedViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var saved: [SessionsRow] = []
    @Published var isUsingOfflineData = false

    private var modelContext: ModelContext?

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    private func hasOfflineSaved(meet: String) -> Bool {
        guard let context = modelContext else { return false }
        guard let userId = Clerk.shared.user?.id else { return false }

        var descriptor = FetchDescriptor<SavedEntity>(
            predicate: #Predicate<SavedEntity> {
                $0.meet == meet && $0.clerk_user_id == userId
            }
        )
        descriptor.fetchLimit = 1
        let results = try? context.fetch(descriptor)
        return !(results?.isEmpty ?? true)
    }

    private func getOfflineLastSynced(meet: String) -> Date? {
        guard let context = modelContext else { return nil }
        guard let userId = Clerk.shared.user?.id else { return nil }

        let descriptor = FetchDescriptor<SavedEntity>(
            predicate: #Predicate<SavedEntity> {
                $0.meet == meet && $0.clerk_user_id == userId
            }
        )

        if let entities = try? context.fetch(descriptor),
           let firstEntity = entities.first {
            return firstEntity.lastSynced
        }
        return nil
    }

    private func loadSavedFromSwiftData(meet: String) throws -> [SessionsRow] {
        guard let context = modelContext else {
            throw NSError(domain: "Saved", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContext not set"])
        }
        guard let userId = Clerk.shared.user?.id else {
            throw NSError(domain: "Saved", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }

        let descriptor = FetchDescriptor<SavedEntity>(
            predicate: #Predicate<SavedEntity> {
                $0.meet == meet && $0.clerk_user_id == userId
            },
            sortBy: [SortDescriptor(\.session_number), SortDescriptor(\.start_time)]
        )

        let entities = try context.fetch(descriptor)

        return entities.map { entity in
            SessionsRow(
                id: entity.id,
                clerk_user_id: entity.clerk_user_id,
                meet: entity.meet,
                session_number: entity.session_number,
                platform: entity.platform,
                weight_class: entity.weight_class,
                start_time: entity.start_time,
                date: entity.date,
                notes: nil,
                athlete_names: entity.athlete_names
            )
        }
    }

    func saveSavedToSwiftData() throws {
        guard let context = modelContext else {
            throw NSError(domain: "Saved", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContext not set"])
        }
        guard let userId = Clerk.shared.user?.id else {
            throw NSError(domain: "Saved", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }

        // Get the meet name from the saved sessions
        guard let meetName = saved.first?.meet else {
            return // Nothing to save
        }

        // Delete existing saved sessions for this meet and user
        let fetchDescriptor = FetchDescriptor<SavedEntity>(
            predicate: #Predicate { $0.meet == meetName && $0.clerk_user_id == userId }
        )
        let existingRecords = try context.fetch(fetchDescriptor)
        for record in existingRecords {
            context.delete(record)
        }

        // Insert the current saved sessions
        for session in saved {
            let entity = SavedEntity(
                id: session.id,
                clerk_user_id: session.clerk_user_id,
                meet: session.meet,
                session_number: session.session_number,
                platform: session.platform,
                weight_class: session.weight_class,
                start_time: session.start_time,
                date: session.date,
                athlete_names: session.athlete_names,
                lastSynced: Date()
            )
            context.insert(entity)
        }
        try context.save()
    }

    private func deleteFromSwiftData(meet: String, sessionNumber: Int, platform: String) {
        guard let context = modelContext else { return }
        guard let userId = Clerk.shared.user?.id else { return }

        let descriptor = FetchDescriptor<SavedEntity>(
            predicate: #Predicate<SavedEntity> {
                $0.meet == meet &&
                $0.clerk_user_id == userId &&
                $0.session_number == sessionNumber &&
                $0.platform == platform
            }
        )

        if let entities = try? context.fetch(descriptor) {
            for entity in entities {
                context.delete(entity)
            }
            try? context.save()
        }
    }

    private func deleteAllFromSwiftData(meet: String) {
        guard let context = modelContext else { return }
        guard let userId = Clerk.shared.user?.id else { return }

        let descriptor = FetchDescriptor<SavedEntity>(
            predicate: #Predicate<SavedEntity> {
                $0.meet == meet && $0.clerk_user_id == userId
            }
        )

        if let entities = try? context.fetch(descriptor) {
            for entity in entities {
                context.delete(entity)
            }
            try? context.save()
        }
    }

    func loadSaved(meet: String) async {
        isLoading = true
        error = nil
        isUsingOfflineData = false

        guard let userId = Clerk.shared.user?.id else {
            print("No user logged in")
            isLoading = false
            return
        }

        let hasOffline = hasOfflineSaved(meet: meet)
        let lastSynced = getOfflineLastSynced(meet: meet)

        if OfflineManager.shared.shouldUseOfflineData(
            hasOfflineData: hasOffline,
            lastSynced: lastSynced
        ) {
            do {
                let offlineSaved = try loadSavedFromSwiftData(meet: meet)
                self.saved = offlineSaved
                self.isUsingOfflineData = true

                // Update App Group for widget
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(offlineSaved) {
                    UserDefaults.appGroup.set(encoded, forKey: "savedSessions")
                    WidgetCenter.shared.reloadAllTimelines()
                }
            } catch {
                self.error = error
            }
            isLoading = false
            return
        }

        do {
            let client = getSupabaseClient()

            let response = try await client
                .from("user_saved_sessions")
                .select()
                .eq("clerk_user_id", value: userId)
                .eq("meet", value: meet)
                .order("session_number")
                .order("start_time")
                .execute()

            let row = try JSONDecoder().decode([SessionsRow].self, from: response.data)

            self.saved = row
            self.isUsingOfflineData = false

            // Save to SwiftData for offline access
            try? saveSavedToSwiftData()

            // Save to App Group for widget access
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(row) {
                UserDefaults.appGroup.set(encoded, forKey: "savedSessions")
                // Tell the widget to reload
                WidgetCenter.shared.reloadAllTimelines()
            }
        } catch {
            // Fallback to offline data
            if hasOffline {
                do {
                    let offlineSaved = try loadSavedFromSwiftData(meet: meet)
                    self.saved = offlineSaved
                    self.isUsingOfflineData = true

                    let encoder = JSONEncoder()
                    if let encoded = try? encoder.encode(offlineSaved) {
                        UserDefaults.appGroup.set(encoded, forKey: "savedSessions")
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                } catch {
                    self.error = error
                }
            } else {
                print("Error: \(error)")
                self.error = error
            }
        }
        isLoading = false
    }
    
    func saveSession(meet: String, sessionNumber: Int, platform: String, weightClass: String, startTime: String, date: Date, athleteNames: [String], notes: String) async throws {
        guard let userId = Clerk.shared.user?.id else {
            throw NSError(domain: "SavedViewModel", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let dateString = dateFormatter.string(from: date)

        let sessionId = UUID().uuidString

        let session = SaveSessionRequest(
            id: sessionId,
            clerk_user_id: userId,
            meet: meet,
            session_number: sessionNumber,
            platform: platform,
            weight_class: weightClass,
            start_time: startTime,
            date: dateString,
            athlete_names: athleteNames,
            notes: notes
        )

        try await supabase
            .from("user_saved_sessions")
            .insert(session)
            .execute()

        // Also save to SwiftData for offline access
        saveToSwiftData(
            id: sessionId,
            userId: userId,
            meet: meet,
            sessionNumber: sessionNumber,
            platform: platform,
            weightClass: weightClass,
            startTime: startTime,
            dateString: dateString,
            athleteNames: athleteNames
        )
    }

    private func saveToSwiftData(id: String, userId: String, meet: String, sessionNumber: Int, platform: String, weightClass: String, startTime: String, dateString: String, athleteNames: [String]) {
        guard let context = modelContext else { return }

        let entity = SavedEntity(
            id: id,
            clerk_user_id: userId,
            meet: meet,
            session_number: sessionNumber,
            platform: platform,
            weight_class: weightClass,
            start_time: startTime,
            date: dateString,
            athlete_names: athleteNames,
            lastSynced: Date()
        )
        context.insert(entity)
        try? context.save()
    }

    func deleteAllSessions(meet: String) async {
        error = nil
        let userId = Clerk.shared.user?.id

        do {
            try await supabase
                .from("user_saved_sessions")
                .delete()
                .eq("clerk_user_id", value: userId)
                .eq("meet", value: meet)
                .execute()

            // Also delete from SwiftData
            deleteAllFromSwiftData(meet: meet)
        } catch {
            print("Error: \(error)")
            self.error = error
        }
    }

    func unsaveSession(meet: String, sessionNumber: Int, platform: String) async {
        error = nil
        let userId = Clerk.shared.user?.id

        do {
            try await supabase
                .from("user_saved_sessions")
                .delete()
                .eq("clerk_user_id", value: userId)
                .eq("meet", value: meet)
                .eq("session_number", value: sessionNumber)
                .eq("platform", value: platform)
                .execute()

            // Also delete from SwiftData
            deleteFromSwiftData(meet: meet, sessionNumber: sessionNumber, platform: platform)
        } catch {
            print("Error: \(error)")
            self.error = error
        }
    }
}
