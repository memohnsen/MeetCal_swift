//
//  SavedEntity.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 10/16/25.
//

import SwiftUI
import SwiftData

@Model
class SavedEntity {
    @Attribute(.unique) var id: String
    var clerk_user_id: String
    var meet: String
    var session_number: Int
    var platform: String
    var weight_class: String
    var start_time: String
    var date: String
    var athlete_names: [String]?
    var lastSynced: Date
    
    init(id: String, clerk_user_id: String, meet: String, session_number: Int, platform: String, weight_class: String, start_time: String, date: String, athlete_names: [String]? = nil, lastSynced: Date) {
        self.id = id
        self.clerk_user_id = clerk_user_id
        self.meet = meet
        self.session_number = session_number
        self.platform = platform
        self.weight_class = weight_class
        self.start_time = start_time
        self.date = date
        self.athlete_names = athlete_names
        self.lastSynced = lastSynced
    }
}
