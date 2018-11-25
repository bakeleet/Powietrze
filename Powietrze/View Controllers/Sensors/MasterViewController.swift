//
//  MasterViewController.swift
//  Powietrze
//
//  Created by Krzysztof Niestrój on 12.06.2018.
//  Copyright © 2018 Krzysztof Niestrój. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    private var sensors = [Sensor]()
    private var selectedStation: Station?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let userData = UserDefaults.standard.value(forKey: "selectedStation") as? Data {
            do {
                selectedStation = try PropertyListDecoder().decode(Station.self, from: userData)
            } catch let err {
                onFailure("NSUserDefaults decoding: \(err)")
            }
        }

        reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showReadings" {
            if let indexPath = tableView.indexPathForSelectedRow,
               let detailController = segue.destination as? DetailViewController {
                detailController.sensorData = sensors[indexPath.row]
            }
        }
    }

    @IBAction func getBackToStationsButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    private func reloadData() {
        if let station = selectedStation {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true

            let reloadDataGroup = DispatchGroup()
            reloadDataGroup.enter()

            RESTManager.sharedInstance.getSensorsOn(station.id, onSuccess: { sensors in
                self.sensors = sensors
                reloadDataGroup.leave()
            }, onFailure: onFailure)

            reloadDataGroup.notify(queue: .main) {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.tableView.reloadData()
            }
        }
    }

    private func onFailure(_ error: String) {
        print("[ERROR] \(error)")
    }
}

extension MasterViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // First for information about station, second for list of sensors
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 5
        } else {
            return sensors.count
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionName: String
        switch section {
        case 0:
            sectionName = "Stacja"
        case 1:
            sectionName = "Sensory"
        default:
            sectionName = ""
        }
        return sectionName
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "sensor", for: indexPath)

            let sensor = sensors[indexPath.row]
            cell.textLabel?.text = sensor.param.paramName

            return cell
        }
        return UITableViewCell()
    }
}
