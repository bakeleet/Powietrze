//
//  StationsMetadata.swift
//  Powietrze
//
//  Created by Krzysztof Niestrój on 25.11.2018.
//  Copyright © 2018 Krzysztof Niestrój. All rights reserved.
//

import Foundation

class LocationMetadata {
    private(set) var stations = [Station]() {
        didSet {
            // Unique set of provinces
            var provincesSet = Set<String>()
            stations.forEach { provincesSet.insert($0.city.commune.provinceName) }

            // Sorting provinces alphabetically
            var provincesArray = Array(provincesSet)
            provincesArray.sort { $0.compare($1, locale: Locale(identifier: "pl")) == .orderedAscending }

            // Saving array of provinces in property
            provinces = provincesArray
        }
    }

    private(set) var provinces = [String]() {
        didSet {
            provinces.forEach { province in
                // Array of cities in province
                var citiesArray = [Station]()

                stations.forEach { station in
                    // Appending station to array of cities for current province
                    if station.city.commune.provinceName == province {
                        citiesArray.append(station)
                    }
                }

                // Sorting stations by name alphabetically
                citiesArray.sort { $0.stationName.compare($1.stationName,
                                                          locale: Locale(identifier: "pl")) == .orderedAscending }

                // Setting array of cities for each province in property
                cities[province] = citiesArray
            }
        }
    }

    private(set) var cities = [String: [Station]]()

    func fill(with stations: [Station]) {
        self.stations = stations
    }

    // MARK: - Getters

    func getProvince(for section: Int) -> String {
        return provinces[section]
    }

    func getCities(for section: Int) -> [Station] {
        return cities[getProvince(for: section)] ?? []
    }

    func getCity(for indexPath: IndexPath) -> Station {
        return getCities(for: indexPath.section)[indexPath.row]
    }

    // MARK: - Counters

    func countProvinces() -> Int {
        return provinces.count
    }

    func countCities(for section: Int) -> Int {
        return getCities(for: section).count
    }
}
