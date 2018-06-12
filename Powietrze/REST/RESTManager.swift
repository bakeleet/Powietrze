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

    func getAllStations(onSuccess: @escaping([Station]) -> Void, onFailure: @escaping(String) -> Void) {
        let url = "http://api.gios.gov.pl/pjp-api/rest/station/findAll"
        self.getDataWith(url, type: [Station].self, onSuccess: onSuccess, onFailure: onFailure)
    }

    func getSensorsWith(id: Int, onSuccess: @escaping([Sensor]) -> Void, onFailure: @escaping(String) -> Void) {
        let url = "http://api.gios.gov.pl/pjp-api/rest/station/sensors/\(id)"
        self.getDataWith(url, type: [Sensor].self, onSuccess: onSuccess, onFailure: onFailure)
    }

    func getResultsWith(sensorId: Int, onSuccess: @escaping(Result) -> Void, onFailure: @escaping(String) -> Void) {
        let url = "http://api.gios.gov.pl/pjp-api/rest/data/getData/\(sensorId)"
        self.getDataWith(url, type: Result.self, onSuccess: onSuccess, onFailure: onFailure)
    }

    func getDataWith<T>(_ url: String,
                        type: T.Type,
                        onSuccess: @escaping(T) -> Void,
                        onFailure: @escaping(String) -> Void) where T: Decodable {
        guard let resultUrl = URL(string: url) else {
            onFailure("Cannot process url: \(url)")
            return
        }

        URLSession.shared.dataTask(with: resultUrl) { (data, response, error) in
            guard error == nil else {
                onFailure("DataTask failed with: \(String(describing: error))")
                return
            }

            guard let data = data else {
                onFailure("No data for url: \(url)")
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.myFormatter)
                let results = try decoder.decode(type, from: data)
                onSuccess(results)
            } catch let err {
                onFailure("JSON decoding: \(err)")
            }
        }.resume()
    }
}

extension DateFormatter {
    static let myFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
}
