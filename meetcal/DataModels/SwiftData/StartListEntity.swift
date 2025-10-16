//
//  StartListEntity.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 10/16/25.
//

import SwiftUI
import SwiftData

@Model
class StartListEntity {
    @Attribute(.unique) var member_id: String
    var name: String
    var age: Int
    var club: String
    var gender: String
    var weight_class: String
    var entry_total: Int
    var session_number: Int?
    var session_platform: String?
    var meet: String
    var adaptive: Bool
    var lastSynced: Date
    
    init(member_id: String, name: String, age: Int, club: String, gender: String, weight_class: String, entry_total: Int, session_number: Int? = nil, session_platform: String? = nil, meet: String, adaptive: Bool, lastSynced: Date) {
        self.member_id = member_id
        self.name = name
        self.age = age
        self.club = club
        self.gender = gender
        self.weight_class = weight_class
        self.entry_total = entry_total
        self.session_number = session_number
        self.session_platform = session_platform
        self.meet = meet
        self.adaptive = adaptive
        self.lastSynced = lastSynced
    }
}
