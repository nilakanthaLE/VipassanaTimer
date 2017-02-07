//
//  MeineKurseTableVC.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 30.01.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import UIKit

class MeineKurseTableVC: UITableViewController {
    var kurse = Kurs.getAll()
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return kurse.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let kurs = kurse[indexPath.row]
        
        if let _view = cell.contentView.subviews[0] as? KursTableCellView{
            _view.kurs = kurs
        }
        return cell
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        kurse   = Kurs.getAll()
        tableView.reloadData()
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            kurse[indexPath.row].delete()
            kurse.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    

   

}
class KursTableCellView:NibLoadingView{
    @IBOutlet weak var kursTitleLabel: UILabel!
    @IBOutlet weak var kursDatumLabel: UILabel!
    @IBOutlet weak var kursStatistikLabel: UILabel!
    
    var kurs:Kurs?{
        didSet{
            kursTitleLabel.text     = kurs?.name ?? "Fehler - name fehlt"
            let sortedMeditations   = kurs?.sortedMeditations
            if let last = sortedMeditations?.last?.start, let first = sortedMeditations?.first?.start{
                kursDatumLabel.text = (first as Date).string("dd.MM.yyyy") + " bis " + (last as Date).string("dd.MM.yyyy")
            }
            if let gesamtDauer         = kurs?.gesamtDauerMeditationen{
                kursStatistikLabel.text = "∑ \(gesamtDauer.hhmmString) h"
            }else{
                kursStatistikLabel.text = "Fehler - Dauer"
            }
            
        }
    }
    
}
