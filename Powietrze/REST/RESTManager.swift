//
//  RESTManager.swift
//  Powietrze
//
//  Created by Krzysztof Niestrój on 12.06.2018.
//  Copyright © 2018 Krzysztof Niestrój. All rights reserved.
//

import Foundation

class RESTManager {
    static let sharedInstance = RESTManager()

    private var cache = RESTCache()

    func getAllStations(onSuccess: @escaping([Station]) -> Void, onFailure: @escaping(String) -> Void) {
        let url = "http://api.gios.gov.pl/pjp-api/rest/station/findAll"
        getDataWith(url, type: [Station].self, onSuccess: onSuccess, onFailure: onFailure)
    }

    func getSensorsOn(_ stationId: Int, onSuccess: @escaping([Sensor]) -> Void, onFailure: @escaping(String) -> Void) {
        let url = "http://api.gios.gov.pl/pjp-api/rest/station/sensors/\(stationId)"
        getDataWith(url, type: [Sensor].self, onSuccess: onSuccess, onFailure: onFailure)
    }

    func getResultsFrom(_ sensorId: Int, onSuccess: @escaping(Result) -> Void, onFailure: @escaping(String) -> Void) {
        let url = "http://api.gios.gov.pl/pjp-api/rest/data/getData/\(sensorId)"
        getDataWith(url, type: Result.self, onSuccess: onSuccess, onFailure: onFailure)
    }

    private func getDataWith<T>(_ url: String,
                                type: T.Type,
                                onSuccess: @escaping(T) -> Void,
                                onFailure: @escaping(String) -> Void) where T: Decodable {

        if let response = cache.getRecentResponse(from: url) as? T {
            onSuccess(response)
        } else {
            networkCall(url, type: type, onSuccess: onSuccess, onFailure: onFailure)
        }
    }

    private func networkCall<T>(_ url: String,
                                type: T.Type,
                                onSuccess: @escaping(T) -> Void,
                                onFailure: @escaping(String) -> Void) where T: Decodable {

        guard let resultUrl = URL(string: url)
        else {
            onFailure("Cannot process url: \(url)")
            return
        }

        URLSession.shared.dataTask(with: resultUrl) { (data, response, error) in
            guard error == nil
            else {
                onFailure("DataTask failed with: \(String(describing: error))")
                return
            }

            guard let data = data
            else {
                onFailure("No data for url: \(url)")
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.giosGovFormat)
                let results = try decoder.decode(type, from: data)

                self.cache.add(response: results, from: url)
                onSuccess(results)
            } catch let err {
                onFailure("JSON decoding: \(err)")
            }
        }.resume()
    }
}
