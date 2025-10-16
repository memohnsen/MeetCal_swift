//
//  NatRankingsEntity.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 10/16/25.
//

import SwiftUI
import SwiftData

@Model
class NatRankingsEntity {
    @Attribute(.unique) var id: Int
    var meet: String
    var date: String
    var name: String
    var age: String
    var body_weight: Float
    var total: Float
    var snatch1: Float
    var snatch2: Float
    var snatch3: Float
    var snatch_best: Float
    var cj1: Float
    var cj2: Float
    var cj3: Float
    var cj_best: Float
    var lastSynced: Date
    
    init(id: Int, meet: String, date: String, name: String, age: String, body_weight: Float, total: Float, snatch1: Float, snatch2: Float, snatch3: Float, snatch_best: Float, cj1: Float, cj2: Float, cj3: Float, cj_best: Float, lastSynced: Date) {
        self.id = id
        self.meet = meet
        self.date = date
        self.name = name
        self.age = age
        self.body_weight = body_weight
        self.total = total
        self.snatch1 = snatch1
        self.snatch2 = snatch2
        self.snatch3 = snatch3
        self.snatch_best = snatch_best
        self.cj1 = cj1
        self.cj2 = cj2
        self.cj3 = cj3
        self.cj_best = cj_best
        self.lastSynced = lastSynced
    }
}
