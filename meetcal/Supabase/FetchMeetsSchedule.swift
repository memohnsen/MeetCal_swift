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

struct ScheduleRow: Decodable {
    let id: Int
    let date: Date
    let session_id: Int
    let weight_class: String
    let start_time: String
    let platform: String
    let meet: String?
}

struct MeetDetailsRow: Decodable {
    let name: String
    let venue_name: String
    let venue_street: String
    let venue_city: String
    let venue_state: String
    let venue_zip: String
    let time_zone: String
    let start_date: String
    let end_date: String
}

@MainActor
class MeetsScheduleModel: ObservableObject {
    @Published var meets: [String] = []
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var schedule: [ScheduleRow] = []
    @Published var meetDetails: [MeetDetailsRow] = []
    
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
            
            let decoder = JSONDecoder()
            let df = DateFormatter()
            df.calendar = Calendar(identifier: .gregorian)
            df.locale = Locale(identifier: "en_US_POSIX")
            df.timeZone = TimeZone.current
            df.dateFormat = "yyyy-MM-dd"
            decoder.dateDecodingStrategy = .formatted(df)
            
            let row = try decoder.decode([ScheduleRow].self, from: response.data)
            self.schedule = row
            
        } catch {
            print("Error: \(error)")
            self.error = error
        }
        isLoading = false
    }
    
    func loadMeetDetails(meetName: String) async {
        error = nil
        isLoading = true
        do {
            let response = try await supabase
                .from("meets")
                .select()
                .eq("name", value: meetName)
                .execute()
            
            let row = try JSONDecoder().decode([MeetDetailsRow].self, from: response.data)
            
            self.meetDetails = row
        } catch {
            print("Error: \(error)")
            self.error = error
        }
        isLoading = false
    }
}
