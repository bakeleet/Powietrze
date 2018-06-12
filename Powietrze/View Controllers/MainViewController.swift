//
//  MainViewController.swift
//  Powietrze
//
//  Created by Krzysztof Niestrój on 12.06.2018.
//  Copyright © 2018 Krzysztof Niestrój. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var tableView: UITableView!

    private var sensors: Array<Sensor>?
    private var results: Array<Result>?
    private var selectedStation: Station?

    private var refreshControl = UIRefreshControl()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        refreshControl.attributedTitle = NSAttributedString(string: "Pociągnij, aby odświeżyć")
        refreshControl.addTarget(self, action: #selector(MainViewController.refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)

        self.sensors = Array<Sensor>()
        self.results = Array<Result>()

        self.reloadData()
    }

    @objc func refresh(sender: AnyObject) {
        self.reloadData()
    }

    func reloadData() {
        let reloadDataGroup = DispatchGroup()

        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        let selectedCommune = Station.City.Commune(communeName: "Kraków", districtName: "Kraków", provinceName: "MAŁOPOLSKIE")
        let selectedCity = Station.City(id: 415, name: "Kraków", commune: selectedCommune)
        selectedStation = Station(id: 400, stationName: "Kraków, Aleja Krasińskiego", gegrLat: "50.057678", gegrLon: "19.926189", city: selectedCity, addressStreet: "al. Krasińskiego")

        if let data = UserDefaults.standard.value(forKey:"selectedStation") as? Data {
            do {
                selectedStation = try PropertyListDecoder().decode(Station.self, from: data)
            } catch let err {
                onFailure("NSUserDefaults decoding: \(err)")
            }
        }

        guard let selectedStation = selectedStation else {
            onFailure("Cannot unwrap selected station")
            return
        }

        // Fetching sensors data
        reloadDataGroup.enter()
        RESTManager.sharedInstance.getSensorsWith(id: selectedStation.id, onSuccess: { sensors in
            self.sensors = sensors
            reloadDataGroup.leave()
        }, onFailure: self.onFailure)

        // Waiting for sensors data
        reloadDataGroup.wait()

        // Fetching results data
        self.sensors?.forEach { sensor in
            reloadDataGroup.enter()
            RESTManager.sharedInstance.getResultsWith(sensorId: sensor.id, onSuccess: { results in
                self.results?.append(results.getResultWithLatestDate())
                reloadDataGroup.leave()
            }, onFailure: self.onFailure)
        }

        // Reloading UI
        reloadDataGroup.notify(queue: .main) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }

    func onFailure(_ error: String) {
        print("[ERROR] \(error)")
    }

    // MARK: - TableViewController methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 5
        } else {
            return self.sensors?.count ?? 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "stationName", for: indexPath)
                cell.textLabel?.text = selectedStation?.stationName
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cityName", for: indexPath)
                cell.textLabel?.text = "Miasto"
                cell.detailTextLabel?.text = selectedStation?.city.name
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "provinceName", for: indexPath)
                cell.textLabel?.text = "Województwo"
                cell.detailTextLabel?.text = selectedStation?.city.commune.provinceName
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "gegrLat", for: indexPath)
                cell.textLabel?.text = "Szerokość geograficzna"
                cell.detailTextLabel?.text = selectedStation?.gegrLat
                return cell
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: "gegrLon", for: indexPath)
                cell.textLabel?.text = "Długość geograficzna"
                cell.detailTextLabel?.text = selectedStation?.gegrLon
                return cell
            default: break
            }
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reading", for: indexPath)

            // Title text
            guard let sensors = sensors else {
                self.onFailure("No data for sensors")
                return UITableViewCell()
            }
            let sensor = sensors[indexPath.row]
            cell.textLabel?.text = sensor.param.paramName

            // Detail text
            let result = results?.filter { (result: Result) -> Bool in
                return result.key == sensor.param.paramCode
            }
            guard let reading = result?.first, let values = reading.values.first, let value = values.value else {
                cell.detailTextLabel?.text = ""
                return cell
            }
            cell.detailTextLabel?.text = String(format: "%.2f", value)

            // Background
            if reading.getAddmisibleLevel() == -Float.infinity {
                cell.backgroundColor = UIColor.white
            } else if value > reading.getAddmisibleLevel() {
                cell.backgroundColor = UIColor(red: 252.0/255.0, green: 40.0/255.0, blue: 71.0/255.0, alpha: 1.0)
            } else if value <= reading.getAddmisibleLevel() {
                cell.backgroundColor = UIColor(red: 197.0/255.0, green: 227.0/255.0, blue: 132.0/255.0, alpha: 1.0)
            }

            return cell
        }
        return UITableViewCell()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionName: String
        switch section {
        case 0:
            sectionName = "Stacja"
        case 1:
            sectionName = "Odczyty"
        default:
            sectionName = ""
        }
        return sectionName
    }
}
