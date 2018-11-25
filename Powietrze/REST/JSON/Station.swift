//
//  Station.swift
//  Powietrze
//
//  Created by Krzysztof Niestrój on 12.06.2018.
//  Copyright © 2018 Krzysztof Niestrój. All rights reserved.
//

import Foundation

struct Station: Codable {
    // swiftlint:disable identifier_name
    let id: Int
    let stationName: String
    let gegrLat: String
    let gegrLon: String
    let city: City
    let addressStreet: String?

    struct City: Codable {
        // swiftlint:disable identifier_name
        let id: Int
        let name: String
        let commune: Commune

        // swiftlint:disable nesting
        struct Commune: Codable {
            let communeName: String
            let districtName: String
            let provinceName: String
        }
    }
}
