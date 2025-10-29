//
//  WSOEntity.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 10/16/25.
//

import SwiftUI
import SwiftData

@Model
class WSOEntity {
    @Attribute(.unique) var id: Int
    var wso: String
    var gender: String
    var age_category: String
    var weight_class: String
    var snatch_record: Int?
    var cj_record: Int?
    var total_record: Int?
    var lastSynced: Date

    init(id: Int, wso: String, gender: String, age_category: String, weight_class: String, snatch_record: Int?, cj_record: Int?, total_record: Int?, lastSynced: Date) {
        self.id = id
        self.wso = wso
        self.gender = gender
        self.age_category = age_category
        self.weight_class = weight_class
        self.snatch_record = snatch_record
        self.cj_record = cj_record
        self.total_record = total_record
        self.lastSynced = lastSynced
    }
}
