//
//  AdaptiveRecordEntity.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 10/15/25.
//

import SwiftData
import SwiftUI

@Model
class AdaptiveRecordModel {
    @Attribute(.unique) var id: Int
    var age: String
    var gender: String
    var weight_class: String
    var snatch_best: Float
    var cj_best: Float
    var total: Float
    var name: String
    var lastSynced: Date
    
    init(id: Int, age: String, gender: String, weight_class: String, snatch_best: Float, cj_best: Float, total: Float, name: String, lastSynced: Date) {
        self.id = id
        self.age = age
        self.gender = gender
        self.weight_class = weight_class
        self.snatch_best = snatch_best
        self.cj_best = cj_best
        self.total = total
        self.name = name
        self.lastSynced = lastSynced
    }
}
