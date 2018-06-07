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
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int { return 2 }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return meineFreundesAnfragen[section].count }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text    = meineFreundesAnfragen[indexPath.section][indexPath.row].freundNick
        cell.textLabel?.textColor = DesignPatterns.mocha
        cell.backgroundColor = DesignPatterns.controlBackground
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
            FirUserConnections.deleteUserConnection(withUserID: meineFreundesAnfragen[indexPath.section][indexPath.row].freundID)
        }
    }
    
    override func viewDidLoad() {
        meineFreundesAnfragen = Freund.getMeineAnfragen()
        Singleton.sharedInstance.freundesAnfragenEreignis = updateFreundeUndFreundesAnfragenList
        view.backgroundColor = DesignPatterns.mainBackground
    }
    
    private func updateFreundeUndFreundesAnfragenList(){
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when) { [weak self] in self?.meineFreundesAnfragen = Freund.getMeineAnfragen() }
    }
    
    deinit { print("deinit: MeineFreundesAnfragenTableVC")}

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = DesignPatterns.headerBackground
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = DesignPatterns.mocha
    }
}
