//
//  StationViewController.swift
//  Powietrze
//
//  Created by Krzysztof Niestrój on 12.06.2018.
//  Copyright © 2018 Krzysztof Niestrój. All rights reserved.
//

import UIKit

class StationViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    private let locationMetadata = LocationMetadata()

    private var selectedStation: Station?
    private var selectedItem: IndexPath?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let userStation = UserDefaults.standard.value(forKey: "selectedStation") as? Data {
            do {
                selectedStation = try PropertyListDecoder().decode(Station.self, from: userStation)
            } catch let err {
                onFailure("NSUserDefaults decoding: \(err)")
            }
        }

        reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // FIXME: Scrolling doesn't work if row doesn't fit into first screen and view is not entirely loaded
        // Scrolling to previously selected item
        DispatchQueue.main.async {
            if let selectedItem = self.selectedItem {
                self.tableView.scrollToRow(at: selectedItem, at: .middle, animated: true)
            }
        }
    }

    private func reloadData() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        let reloadDataGroup = DispatchGroup()
        reloadDataGroup.enter()

        RESTManager.sharedInstance.getAllStations(onSuccess: { stations in
            self.locationMetadata.fill(with: stations)
            reloadDataGroup.leave()
        }, onFailure: onFailure)

        reloadDataGroup.notify(queue: .main) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.tableView.reloadData()
        }
    }

    private func onFailure(_ error: String) {
        print("[ERROR] \(error)")
    }
}

extension StationViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return locationMetadata.countProvinces()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationMetadata.countCities(for: section)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return locationMetadata.getProvince(for: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let city = locationMetadata.getCity(for: indexPath)

        // Configuring table view cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "station", for: indexPath) as? StationCell
        else {
            onFailure("Configuring StationCell failed")
            return UITableViewCell()
        }

        cell.configure(with: city)

        // Marking selected station and saving row index path
        if city.id == selectedStation?.id {
            cell.accessoryType = .checkmark
            selectedItem = indexPath
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Unmarking previously selected cell
        if let selectedCell = selectedItem, let previousCell = tableView.cellForRow(at: selectedCell) {
            previousCell.accessoryType = .none
        }

        // Marking selected row and saving row index path and station data in user defaults
        if let cell = tableView.cellForRow(at: indexPath) as? StationCell {
            cell.accessoryType = .checkmark
            selectedItem = indexPath
            UserDefaults.standard.set(try? PropertyListEncoder().encode(cell.station), forKey: "selectedStation")
        }
    }
}
