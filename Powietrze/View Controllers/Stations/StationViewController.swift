//
//  StationViewController.swift
//  Powietrze
//
//  Created by Krzysztof Niestrój on 12.06.2018.
//  Copyright © 2018 Krzysztof Niestrój. All rights reserved.
//

import UIKit

class StationViewController: UITableViewController {
    private var stations: Array<Station>?
    private var provinces: Array<String>?
    private var cities: Dictionary<String, Array<Station>>?
    private var selectedStation: Station?
    private var selectedItem: IndexPath?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.allowsMultipleSelection = false

        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pociągnij, aby odświeżyć")
        refreshControl?.addTarget(self, action: #selector(StationViewController.refresh), for: .valueChanged)

        let selectedCommune = Station.City.Commune(communeName: "Kraków", districtName: "Kraków", provinceName: "MAŁOPOLSKIE")
        let selectedCity = Station.City(id: 415, name: "Kraków", commune: selectedCommune)
        selectedStation = Station(id: 400, stationName: "Kraków, Aleja Krasińskiego", gegrLat: "50.057678", gegrLon: "19.926189", city: selectedCity, addressStreet: "al. Krasińskiego")

        if let userStation = UserDefaults.standard.value(forKey:"selectedStation") as? Data,
            let userItem = UserDefaults.standard.value(forKey:"selectedItem") as? Data {
            do {
                selectedStation = try PropertyListDecoder().decode(Station.self, from: userStation)
                selectedItem = try PropertyListDecoder().decode(IndexPath.self, from: userItem)
            } catch let err {
                onFailure("NSUserDefaults decoding: \(err)")
            }
        }

        self.stations = Array<Station>()
        self.provinces = Array<String>()
        self.cities = Dictionary<String, Array<Station>>()
        self.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let selectedItem = selectedItem {
            tableView.scrollToRow(at: selectedItem, at: .middle, animated: true)
        }
    }

    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @objc func refresh(sender: AnyObject) {
        self.reloadData()
    }

    func reloadData() {
        let reloadDataGroup = DispatchGroup()

        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        // Fetching sensors data
        reloadDataGroup.enter()
        RESTManager.sharedInstance.getAllStations(onSuccess: { stations in
            self.stations = stations
            reloadDataGroup.leave()
        }, onFailure: self.onFailure)

        // Reloading UI
        reloadDataGroup.notify(queue: .main) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.setListOfAllProvinces()
            self.setDictOfAllCities()
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }

    func onFailure(_ error: String) {
        print("[ERROR] \(error)")
    }

    // MARK: - UITableView helpers

    func setListOfAllProvinces() {
        var provincesSet = Set<String>()
        self.stations?.forEach { provincesSet.insert($0.city.commune.provinceName) }
        var provincesArray = Array(provincesSet)
        provincesArray.sort { $0.compare($1, locale: Locale(identifier: "pl")) == .orderedAscending }
        self.provinces = provincesArray
    }

    func setDictOfAllCities() {
        self.provinces?.forEach { province in
            var citiesArray = [Station]()
            self.stations?.forEach { station in
                if station.city.commune.provinceName == province {
                    citiesArray.append(station)
                }
            }
            citiesArray.sort { $0.stationName.compare($1.stationName, locale: Locale(identifier: "pl")) == .orderedAscending }
            self.cities?[province] = citiesArray
        }
    }

    // MARK: - UITableView methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let provinceName = self.provinces?[section], let cities = self.cities?[provinceName] else {
            onFailure("Getting provinces and cities failed")
            return 0
        }
        return cities.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "station", for: indexPath) as? StationCell
            else {
                onFailure("Cannot configure StationCell")
                return UITableViewCell()
            }

        guard let provinceName = self.provinces?[indexPath.section], let cities = self.cities?[provinceName] else {
            onFailure("Getting provinces and cities failed")
            return UITableViewCell()
        }
        let city = cities[indexPath.row]
        cell.configure(station: city)

        if city.id == selectedStation?.id {
            cell.accessoryType = .checkmark
            selectedItem = indexPath
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? StationCell {
            if let selectedItem = selectedItem, let previousCell = tableView.cellForRow(at: selectedItem) {
                previousCell.accessoryType = .none
                self.selectedItem = indexPath
            }

            cell.accessoryType = .checkmark
            UserDefaults.standard.set(try? PropertyListEncoder().encode(cell.station), forKey: "selectedStation")
            UserDefaults.standard.set(try? PropertyListEncoder().encode(indexPath), forKey: "selectedItem")
            dismiss(animated: true, completion: nil)
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.provinces?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.provinces?[section]
    }
}
