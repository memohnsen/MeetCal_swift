//
//  Bundle+Version.swift
//  meetcal
//
//  Created by OpenAI on 10/8/25.
//

import Foundation

extension Bundle {
    var appVersionString: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
    }
}
