//
//  RESTCache.swift
//  Powietrze
//
//  Created by Krzysztof Niestrój on 24.11.2018.
//  Copyright © 2018 Krzysztof Niestrój. All rights reserved.
//

import Foundation

struct RESTCache {
    private struct CacheEntry {
        var date: Date
        var response: Decodable
    }

    private var cachedEntries = [String: CacheEntry]()

    mutating func add(response: Decodable, from url: String) {
        cachedEntries[url] = CacheEntry(date: Date(), response: response)
    }

    func getRecentResponse(from url: String) -> Decodable? {
        guard let entry = cachedEntries[url]
        else { return nil }

        let now = Date()
        let responseDatePlus15Minut = entry.date.addingTimeInterval(900)

        if now <= responseDatePlus15Minut {
            return entry.response
        }

        return nil
    }
}
