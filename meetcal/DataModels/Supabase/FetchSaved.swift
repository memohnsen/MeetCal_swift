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

            self.saved.removeAll { $0.meet == meet }
            self.saved.append(contentsOf: row)
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
}
