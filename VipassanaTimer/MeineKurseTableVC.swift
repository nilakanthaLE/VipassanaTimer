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
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return UIInterfaceOrientationMask.portrait  }
    // MARK: - Table view
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return kurse.count }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        ( cell.contentView.subviews.first as? KursTableCellView )?.viewModel = KursTableCellViewModel(kurs: kurse[indexPath.row])
        return cell
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return true }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            kurse[indexPath.row].delete(inFirebaseToo: true)
            kurse.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let kurs = kurse[indexPath.row]
        let alertController = UIAlertController(title:"\(kurs.name ?? "?") \(kurs.startDate.string("MM/yy"))" , message: "Bitte Name des Lehrers eingeben", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "abbrechen" , style: .cancel, handler: nil))
        alertController.addTextField { textfield in
            textfield.placeholder   = "Name des Lehrers"
            textfield.text          = kurs.teacher
        }
        alertController.addAction(UIAlertAction(title: "übernehmen", style: .default) {[weak self] _ in
            self?.kurse[indexPath.row].teacher = alertController.textFields?.first?.text
            saveContext()
            self?.kurse = Kurs.getAll()
            self?.tableView.reloadData()
        })
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor            = UIColor(patternImage: #imageLiteral(resourceName: "backGroundImage.png"))
        navigationController?.navigationBar.setDesignPattern()
        tableView.rowHeight             = UITableViewAutomaticDimension
        tableView.estimatedRowHeight    = 44
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        kurse   = Kurs.getAll()
        tableView.reloadData()
    }
    deinit { print("deinit MeineKurseTableVC") }
}




class KursTableCellViewModel{
    let kursTitle:String?
    let datumText:String?
    let gesamtdauerText:String?
    let lehrerText:String?
    init(kurs:Kurs){
        kursTitle       = kurs.name
        datumText       = kurs.startDate.string("dd.MM.yyyy") + " - " + kurs.endDate.string("dd.MM.yyyy")
        gesamtdauerText = kurs.gesamtDauerMeditationen.hhmm
        lehrerText      = kurs.teacher
    }
}
class KursTableCellView:NibLoadingView{
    @IBOutlet private weak var kursTitleLabel: UILabel!
    @IBOutlet private weak var kursDatumLabel: UILabel!
    @IBOutlet private weak var kursStatistikLabel: UILabel!
    @IBOutlet private weak var lehrerName: UILabel!
    
    var viewModel:KursTableCellViewModel!{
        didSet{
            kursTitleLabel.text     = viewModel.kursTitle
            kursDatumLabel.text     = viewModel.datumText
            kursStatistikLabel.text = viewModel.gesamtdauerText
            lehrerName.text         = viewModel.lehrerText
            
            layer.borderColor   = standardRahmenFarbe.cgColor
            layer.borderWidth   = standardBorderWidth
            layer.cornerRadius  = standardCornerRadius
            clipsToBounds       = true
        }
    }
    
    
    deinit { print("deinit KursTableCellView") }
    override var intrinsicContentSize: CGSize{ return CGSize(width: UIViewNoIntrinsicMetric, height: 80) }
}
