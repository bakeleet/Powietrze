//
//  Sensor.swift
//  Powietrze
//
//  Created by Krzysztof Niestrój on 12.06.2018.
//  Copyright © 2018 Krzysztof Niestrój. All rights reserved.
//

import Foundation

struct Sensor: Codable {
    let id: Int
    let stationId: Int
    let param: SensorParam

    struct SensorParam: Codable {
        let paramName: String
        let paramFormula: String
        let paramCode: String
        let idParam: Int
    }
}
