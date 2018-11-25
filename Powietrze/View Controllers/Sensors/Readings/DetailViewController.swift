//
//  DetailViewController.swift
//  Powietrze
//
//  Created by Krzysztof Niestrój on 24.11.2018.
//  Copyright © 2018 Krzysztof Niestrój. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    private let refreshControl = UIRefreshControl()

    private var result: Result?

    var sensorData: Sensor? {
        didSet {
            reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        refreshControl.attributedTitle = NSAttributedString(string: "Pociągnij, aby odświeżyć")
        refreshControl.addTarget(self, action: #selector(DetailViewController.refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }

    @objc func refresh(sender: AnyObject) {
        reloadData()
    }

    private func reloadData() {
        if let sensor = sensorData {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true

            let reloadDataGroup = DispatchGroup()
            reloadDataGroup.enter()

            RESTManager.sharedInstance.getResultsFrom(sensor.id, onSuccess: { result in
                self.result = result
                reloadDataGroup.leave()
            }, onFailure: onFailure)

            reloadDataGroup.notify(queue: .main) {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }

    private func onFailure(_ error: String) {
        print("[ERROR] \(error)")
    }
}

extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result?.values.count ?? 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sensor = sensorData {
            return sensor.param.paramName
        }
        return "Odczyty"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "reading", for: indexPath) as? ReadingCell,
            let result = result
        else {
            onFailure("Configuring ReadingCell failed")
            return UITableViewCell()
        }

        cell.configure(with: result, for: indexPath.row)

        return cell
    }
}
