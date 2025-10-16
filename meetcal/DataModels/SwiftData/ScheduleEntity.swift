//
//  ScheduleEntity.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 10/16/25.
//

import SwiftUI
import SwiftData

@Model
class ScheduleEntity {
    @Attribute(.unique) var id: Int
    var date: Date
    var session_id: Int
    var weight_class: String
    var start_time: String
    var platform: String
    var meet: String?
    var lastSynced: Date
    
    init(id: Int, date: Date, session_id: Int, weight_class: String, start_time: String, platform: String, meet: String? = nil, lastSynced: Date) {
        self.id = id
        self.date = date
        self.session_id = session_id
        self.weight_class = weight_class
        self.start_time = start_time
        self.platform = platform
        self.meet = meet
        self.lastSynced = lastSynced
    }
}

@Model
class MeetsEntity {
    @Attribute(.unique) var name: String
    var lastSynced: Date
    
    init(name: String, lastSynced: Date) {
        self.name = name
        self.lastSynced = lastSynced
    }
}


@Model
class MeetDetailsEntity {
    @Attribute(.unique) var name: String
    var venue_name: String
    var venue_street: String
    var venue_city: String
    var venue_state: String
    var venue_zip: String
    var time_zone: String
    var start_date: String
    var end_date: String
    var lastSynced: Date
    
    init(name: String, venue_name: String, venue_street: String, venue_city: String, venue_state: String, venue_zip: String, time_zone: String, start_date: String, end_date: String, lastSynced: Date) {
        self.name = name
        self.venue_name = venue_name
        self.venue_street = venue_street
        self.venue_city = venue_city
        self.venue_state = venue_state
        self.venue_zip = venue_zip
        self.time_zone = time_zone
        self.start_date = start_date
        self.end_date = end_date
        self.lastSynced = lastSynced
    }
}
