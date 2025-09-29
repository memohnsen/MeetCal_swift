//
//  SharedDecoders.swift
//  meetcal
//
//  Created by Assistant on 9/29/25.
//

import Foundation

extension JSONDecoder {
    /// Decoder for session_schedule dates stored as "yyyy-MM-dd".
    /// Anchors the date at 12:00 (noon) in the Gregorian calendar to avoid day shifts due to time zones.
    static func scheduleNoonDateDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            let components = dateString.split(separator: "-")
            guard components.count == 3,
                  let year = Int(components[0]),
                  let month = Int(components[1]),
                  let day = Int(components[2]) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
            }

            var dateComponents = DateComponents()
            dateComponents.year = year
            dateComponents.month = month
            dateComponents.day = day
            dateComponents.hour = 12
            dateComponents.minute = 0
            dateComponents.second = 0

            let calendar = Calendar(identifier: .gregorian)
            guard let date = calendar.date(from: dateComponents) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot create date from components")
            }

            return date
        }
        return decoder
    }
}
