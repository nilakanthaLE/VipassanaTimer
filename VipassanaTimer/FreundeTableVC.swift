//
//  FreundeTableVC.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 22.03.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import UIKit

class FreundeTableVC: UITableViewController {
    private var freundeUndAnfragen = [Freund.getFreundesAnfragen(),Freund.getFreunde()]
        {didSet{tableView.reloadData()}}
    

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int { return 2 }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return freundeUndAnfragen[section].count }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell                = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text    = freundeUndAnfragen[indexPath.section][indexPath.row].freundNick
        cell.textLabel?.textColor = DesignPatterns.mocha
        
        if indexPath.section == 0{
            let button              = UIButton()
            button.backgroundColor  = UIColor.green
            button.tag              = indexPath.row
            button.setTitle(" bestätigen ", for: .normal)
            button.addTarget(self, action: #selector(confirmButtonPressed(_:)), for: .touchUpInside)
            button.sizeToFit()
            cell.accessoryView      = button
        }else{
            cell.accessoryView      = nil
        }
        
        
        return cell
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return [NSLocalizedString("Freundesanfragen", comment: "Freundesanfragen"),NSLocalizedString("meineFreunde", comment: "meineFreunde")][section]
    }
    @objc private func confirmButtonPressed(_ button:UIButton){
        freundeUndAnfragen[0][button.tag].confirmFriendShip()
    }
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateFreundeUndFreundesAnfragenList), name: NSNotification.Name.MyNames.updateFreundesUndFreundesAnfragenListe, object: nil)
        MyCloudKit.updateFreundeUndFreundesAnfragen()
    }
    @objc private func updateFreundeUndFreundesAnfragenList(){
        freundeUndAnfragen = [Freund.getFreundesAnfragen(),Freund.getFreunde()]
    }
    deinit { NotificationCenter.default.removeObserver(self) }
    

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let freund = freundeUndAnfragen[indexPath.section][indexPath.row]
            freund.meinStatus   = FreundesStatus.rejected
            freund.cloudNeedsUpdate = true
            Singleton.sharedInstance.myCloudKit?.updateNow()
            freundeUndAnfragen = [Freund.getFreundesAnfragen(),Freund.getFreunde()]
        }
    }


    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        if indexPath.section == 0{
            return NSLocalizedString("freundesAnfrageAbweisen", comment: "freundesAnfrageAbweisen")
        }else{
            return NSLocalizedString("freundschaftBeenden", comment: "freundschaftBeenden")
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = DesignPatterns.backgroundcolor
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = DesignPatterns.mocha
    }
    
    
    
}
