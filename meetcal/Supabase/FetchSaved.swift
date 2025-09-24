//
//  FetchSaved.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/12/25.
//

import SwiftUI
import Supabase
import Combine

struct SessionsRow: Decodable, Identifiable, Hashable {
    let id: String
    let user_id: String
    let meet: String
    let session_number: Int
    let platform: String
    let weight_class: String
    let start_time: String
    let notes: String
    let athlete_names: [String]
}

@MainActor
class SavedViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var saved: [SessionsRow] = []
    
    func loadSaved(meet: String) async {
        isLoading = true
        error = nil
        do {
            let response = try await supabase
                .from("saved_sessions")
                .select()
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
}
