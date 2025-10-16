//
//  StandardsEntity.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 10/16/25.
//

import SwiftUI
import SwiftData

@Model
class StandardsEntity {
    @Attribute(.unique) var id: Int
    var age_category: String
    var gender: String
    var weight_class: String
    var standard_a: Int
    var standard_b: Int
    var lastSynced: Date
    
    init(id: Int, age_category: String, gender: String, weight_class: String, standard_a: Int, standard_b: Int, lastSynced: Date) {
        self.id = id
        self.age_category = age_category
        self.gender = gender
        self.weight_class = weight_class
        self.standard_a = standard_a
        self.standard_b = standard_b
        self.lastSynced = lastSynced
    }
}
