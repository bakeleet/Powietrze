//
//  CityCell.swift
//  Powietrze
//
//  Created by Krzysztof Niestrój on 12.06.2018.
//  Copyright © 2018 Krzysztof Niestrój. All rights reserved.
//

import UIKit

class StationCell: UITableViewCell {
    var station: Station?

    func configure(station: Station) {
        self.station = station
        textLabel?.text = station.stationName
    }
}
