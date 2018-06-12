//
//  Station.swift
//  Powietrze
//
//  Created by Krzysztof Niestrój on 12.06.2018.
//  Copyright © 2018 Krzysztof Niestrój. All rights reserved.
//

import Foundation

struct Station: Codable {
    let id: Int
    let stationName: String
    let gegrLat: String
    let gegrLon: String
    let city: City
    let addressStreet: String?

    struct City: Codable {
        let id: Int
        let name: String
        let commune: Commune

        struct Commune: Codable {
            let communeName: String
            let districtName: String
            let provinceName: String
        }
    }
}
