//
//  FetchMeetsSchedule.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/12/25.
//

import SwiftUI
import Supabase
import Combine

private struct MeetsRow: Decodable {
    let name: String
}

private struct ScheduleRow: Decodable {
    let session_id: Int
    let weight_class: String
    let start_time: String
    let platform: String
}

@MainActor
class MeetsScheduleModel: ObservableObject {
    @Published var meets: [String] = []
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var schedule = []
    
    func loadMeets() async {
        isLoading = true
        error = nil
        do {
            let response = try await supabase
                .from("meets")
                .select("name")
                .neq("status", value: "completed")
                .order("start_date", ascending: true)
                .execute()
            
            let row = try JSONDecoder().decode([MeetsRow].self, from: response.data)
            let unique = Array(row.map { $0.name })
            
            self.meets = unique
        } catch {
            print("error: \(error)")
            self.error = error
        }
        isLoading = false
    }
    
    func loadMeetSchedule(meet: String) async {
        isLoading = true
        error = nil
        do {
            let response = try await supabase
                .from("session_schedule")
                .select()
                .eq("meet", value: meet)
                .order("session_id", ascending: true)
                .execute()
            
            let row = try JSONDecoder().decode([ScheduleRow].self, from: response.data)
            
            self.schedule = row
            
            print(row)
            print(schedule)
        } catch {
            print("Error: \(error)")
            self.error = error
        }
    }
}
