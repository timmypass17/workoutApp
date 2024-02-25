//
//  PrivacyTableViewController.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 2/25/24.
//

import UIKit

class PrivacyTableViewController: UITableViewController {

    var privacyText = "Your workout data is locally stored on your device, ensuring complete privacy. No one else can access or view your data, guaranteeing the confidentiality of your personal fitness data."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PrivacyCell")
        navigationItem.title = "Privacy Policy"
        navigationItem.largeTitleDisplayMode = .never
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrivacyCell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = privacyText
        cell.contentConfiguration = config
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Data Privacy"
    }

}
