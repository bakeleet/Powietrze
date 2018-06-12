//
//  Result.swift
//  Powietrze
//
//  Created by Krzysztof Niestrój on 12.06.2018.
//  Copyright © 2018 Krzysztof Niestrój. All rights reserved.
//

import Foundation
import UIKit

struct Result: Codable {
    let key: String
    let values: [Reading]

    struct Reading: Codable {
        let date: Date
        let value: Float?
    }

    func getResultWithLatestDate() -> Result {
        var readingWithoutNils = values.filter { (reading: Reading) -> Bool in
            return reading.value != nil
        }
        var latestReading = Reading(date: Date(), value: 0.0)
        if readingWithoutNils.count > 0 {
            latestReading = readingWithoutNils.reduce(readingWithoutNils[0], {
                $0.date.timeIntervalSinceReferenceDate > $1.date.timeIntervalSinceReferenceDate ? $0 : $1
            })
        }
        return Result(key: key, values: [latestReading])
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
