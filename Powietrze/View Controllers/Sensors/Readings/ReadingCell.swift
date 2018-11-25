//
//  ReadingCell.swift
//  Powietrze
//
//  Created by Krzysztof Niestrój on 25.11.2018.
//  Copyright © 2018 Krzysztof Niestrój. All rights reserved.
//

import UIKit

class ReadingCell: UITableViewCell {
    func configure(with result: Result, for row: Int) {
        let reading = result.values[row]
        let value = reading.value ?? 0.0

        textLabel?.text = DateFormatter.giosGovFormat.string(from: reading.date)
        detailTextLabel?.text = String(format: "%.2f", value)

        // Background
        if result.getAddmisibleLevel() == -Float.infinity {
            backgroundColor = UIColor.white
        } else if value > result.getAddmisibleLevel() {
            backgroundColor = UIColor(red: 252.0/255.0, green: 40.0/255.0, blue: 71.0/255.0, alpha: 1.0)
        } else if value <= result.getAddmisibleLevel() {
            backgroundColor = UIColor(red: 197.0/255.0, green: 227.0/255.0, blue: 132.0/255.0, alpha: 1.0)
        }
    }
}
