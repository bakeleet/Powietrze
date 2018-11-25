//
//  Result.swift
//  Powietrze
//
//  Created by Krzysztof Niestrój on 12.06.2018.
//  Copyright © 2018 Krzysztof Niestrój. All rights reserved.
//

import Foundation

struct Result: Codable {
    let key: String
    let values: [Reading]

    struct Reading: Codable {
        let date: Date
        let value: Float?
    }

    func getAddmisibleLevel() -> Float {
        switch key {
        case "PM10":
            return 50
        case "PM2.5":
            return 25
        case "SO2": // dwutlenek siarki
            return 350
        case "NO2": // dwutlenek azotu
            return 200
        case "CO": // tlenek wegla
            return 10000
        case "C6H6": // benzen
            return 5
        case "O3": // ozon
            return 120
        default:
            return -Float.infinity
        }
    }
}

extension DateFormatter {
    static let giosGovFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
}
