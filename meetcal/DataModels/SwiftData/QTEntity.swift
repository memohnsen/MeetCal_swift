//
//  QTEntity.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 10/16/25.
//

import SwiftUI
import SwiftData

@Model
class QTEntity {
    @Attribute(.unique) var id: Int
    var event_name: String
    var gender: String
    var age_category: String
    var weight_class: String
    var qualifying_total: Int
    var lastSynced: Date
    
    init(id: Int, event_name: String, gender: String, age_category: String, weight_class: String, qualifying_total: Int, lastSynced: Date) {
        self.id = id
        self.event_name = event_name
        self.gender = gender
        self.age_category = age_category
        self.weight_class = weight_class
        self.qualifying_total = qualifying_total
        self.lastSynced = lastSynced
    }
}
