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

struct SessionsRow: Decodable, Identifiable, Hashable, Sendable {
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
    
    func loadSaved(meet: String) async {
        isLoading = true
        error = nil

        guard let userId = Clerk.shared.user?.id else {
            print("No user logged in")
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
        } catch {
            print("Error: \(error)")
            self.error = error
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

        let session = SaveSessionRequest(
            id: UUID().uuidString,
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
        } catch {
            print("Error: \(error)")
            self.error = error
        }
    }
}
