//
//  MeineKurseTableVC.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 30.01.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import UIKit

//✅
class MeineKurseTableVC: DesignTableViewControllerPortrait {
    //Model
    private var kurse = Kurs.getAll()
    
    // MARK: - Table view
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)   -> Int              { return kurse.count }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)    -> UITableViewCell  { return cell(for: indexPath) }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath)    -> Bool             { return true }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) { if editingStyle == .delete {  deleteAction(indexPath: indexPath) } }
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath)     {  presentAlertController(kurs: kurse[indexPath.row]) }
    
    // VC LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "KursTableCell", bundle: .main), forCellReuseIdentifier: "cell")
        tableView.rowHeight             = UITableViewAutomaticDimension
        tableView.estimatedRowHeight    = 44
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        kurse   = Kurs.getAll()
        tableView.reloadData()
    }
    
    //helper
    private func presentAlertController(kurs:Kurs){
        let alertController = UIAlertController(title:"\(kurs.name ?? "?") \(kurs.startDate.string("MM/yy"))" ,
            message: NSLocalizedString("lehrerMessage",comment: "lehrerMessage"),
            preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("abbrechen",comment: "abbrechen") ,
                                                style: .cancel, handler: nil))
        alertController.addTextField { textfield in
            textfield.placeholder   = NSLocalizedString("abbrechen",comment: "abbrechen")
            textfield.text          = kurs.teacher
        }
        alertController.addAction(UIAlertAction(title: NSLocalizedString("nameOfTeacher",comment: "nameOfTeacher"),
                                                style: .default) {[weak self] _ in
            kurs.teacher = alertController.textFields?.first?.text
            saveContext()
            self?.kurse = Kurs.getAll()
            self?.tableView.reloadData()
        })
        present(alertController, animated: true, completion: nil)
    }
    private func deleteAction(indexPath:IndexPath){
        kurse[indexPath.row].delete(inFirebaseToo: true)
        kurse.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    private func cell(for indexPath:IndexPath) -> UITableViewCell{
        let cell        = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! KursTableCell
        cell.kurs       = kurse[indexPath.row]
        return cell
    }
    
    // deinit
    deinit { print("deinit MeineKurseTableVC") }
}





