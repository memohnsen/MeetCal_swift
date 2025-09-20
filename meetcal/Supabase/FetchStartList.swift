//
//  FetchStartList.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/16/25.
//

import SwiftUI
import Supabase
import Combine

struct AthleteRow: Decodable {
    let member_id: String
    let name: String
    let age: Int
    let club: String
    let gender: String
    let weight_class: String
    let entry_total: Int
    let session_number: Int?
    let session_platform: String?
    let meet: String
    let adaptive: Bool
}

@MainActor
class StartListModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var athletes: [AthleteRow] = []
    @Published var schedule: [ScheduleRow] = []
    @Published var weightClass: [AthleteRow] = []
    @Published var ages: [AthleteRow] = []
    
    func loadStartList(meet: String) async {
        isLoading = true
        error = nil
        
        do {
            let response = try await supabase
                .from("athletes")
                .select()
                .eq("meet", value: meet)
                .order("name")
                .execute()
            
            let row = try JSONDecoder().decode([AthleteRow].self, from: response.data)
            
            self.athletes = row
        } catch {
            print("Error: \(error)")
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
}
