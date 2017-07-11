//
//  MeineFreundesAnfragenTableVC.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 22.03.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import UIKit

class MeineFreundesAnfragenTableVC: UITableViewController {

    private var meineFreundesAnfragen = [[Freund]]()
        { didSet{tableView.reloadData()} }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        meineFreundesAnfragen = Freund.getMeineAnfragen()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meineFreundesAnfragen[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text    = meineFreundesAnfragen[indexPath.section][indexPath.row].freundNick
        cell.textLabel?.textColor = DesignPatterns.mocha
        return cell
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return [NSLocalizedString("meineAnfragen", comment: "meineAnfragen"), NSLocalizedString("zurueckGewieseneAnfragen", comment: "zurueckGewieseneAnfragen")][section]
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return true }
    

    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            meineFreundesAnfragen[indexPath.section][indexPath.row].deletionNeeded()
            meineFreundesAnfragen = Freund.getMeineAnfragen()
        }
    }
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateFreundeUndFreundesAnfragenList), name: NSNotification.Name.MyNames.updateFreundesUndFreundesAnfragenListe, object: nil)
    }
    @objc private func updateFreundeUndFreundesAnfragenList(){
        meineFreundesAnfragen = Freund.getMeineAnfragen()
    }
    deinit { NotificationCenter.default.removeObserver(self) }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = DesignPatterns.backgroundcolor
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = DesignPatterns.mocha
    }
}
