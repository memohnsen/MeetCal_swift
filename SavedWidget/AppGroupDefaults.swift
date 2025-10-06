//
//  AppGroupDefaults.swift
//  SavedWidget
//
//  Created by Claude on 10/6/25.
//

import Foundation

extension UserDefaults {
    static let appGroup: UserDefaults = {
        guard let defaults = UserDefaults(suiteName: "group.com.memohnsen.meetcal") else {
            fatalError("Failed to initialize App Group UserDefaults. Ensure the App Group capability is properly configured.")
        }
        return defaults
    }()
}
