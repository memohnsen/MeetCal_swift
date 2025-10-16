//
//  RankingsEntity.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 10/16/25.
//

import SwiftUI
import SwiftData

@Model
class RankingsEntity {
    @Attribute(.unique) var id: Int
    var meet: String
    var name: String
    var weight_class: String
    var total: Int
    var percent_a: Float
    var gender: String
    var age_category: String
    var lastSynced: Date
    
    init(id: Int, meet: String, name: String, weight_class: String, total: Int, percent_a: Float, gender: String, age_category: String, lastSynced: Date) {
        self.id = id
        self.meet = meet
        self.name = name
        self.weight_class = weight_class
        self.total = total
        self.percent_a = percent_a
        self.gender = gender
        self.age_category = age_category
        self.lastSynced = lastSynced
    }
}
