//
//  HauptMenuVC.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 10.01.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import UIKit
import HealthKit
import CloudKit
import MIBadgeButton_Swift

class HauptMenuVC: UIViewController,StatistikUeberblickDelegate,UIPopoverPresentationControllerDelegate {
    let healthManager = HealthManager()
    @IBAction func unwindToHauptmenu(segue: UIStoryboardSegue){
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    @IBOutlet weak var statistikUeberblick2View: StatistikUeberblick2!{ didSet{statistikUeberblick2View.delegate = self} }
    @IBOutlet weak var statistikUeberblickView: StatistikUeberblick!{ didSet{statistikUeberblickView.delegate = self} }
    @IBOutlet weak var meditationStartenButton: UIButton!{didSet{meditationStartenButton.set(layerDesign: DesignPatterns.standardButton)}}
    @IBOutlet weak var kalenderButton: UIButton!{didSet{kalenderButton.set(layerDesign: DesignPatterns.standardButton)}}
    
    @IBOutlet weak var subMenuBadgeButton: MIBadgeButton! {didSet{subMenuBadgeButton.set(layerDesign: DesignPatterns.standardButton)}}
        
        
    @IBOutlet weak var statistikButton: UIButton!{didSet{statistikButton.set(layerDesign: DesignPatterns.standardButton)}}
    
    //MARK: Delegates
    func infoButtonPressed(){ performSegue(withIdentifier: "statistikStartDatumInfoSegue", sender: nil) }
    func viewTapped() {
        statistikUeberblickView.isHidden    = statistikUeberblickView.isHidden ? false : true
        statistikUeberblick2View.isHidden   = statistikUeberblick2View.isHidden ? false : true
    }
    
    let coreDataObserver = CoreDataObserver()
    
    //MARK: VC LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = Singleton.sharedInstance
        
        //erstellt eventuell Meditierenden neu
        //holt Userdaten (ID+Nick) aus CloudKit
        _ = Meditierender.get()
        Singleton.sharedInstance.myCloudKit?.updateNow()
        
        //löscht alle Meditationen kürzer als 5 min
        for meditation in Meditation.getAll(){
            if meditation.gesamtDauer < 5 * 60{
                meditation.delete()
                print("deleted")
            }
        }
        KursTemplate.createKursTemplates()
        
        //erstellt ersten TimerConfig (wenn kein Timer existiert)
        if TimerConfig.getAll().count == 0{
            let new     = TimerConfig.new(dauerAnapana: 5*60, dauerVipassana: 50*60, dauerMetta: 5*60, mettaOpenEnd: false)
            new?.name   = NSLocalizedString("FirstMeditation", comment: "FirstMeditation")
        }
        
        //authoriziert HealthKit
        healthManager.authorizeHealthKit{ (authorized,  error) -> Void in
            if authorized {  print("HealthKit authorization received.") }
            else { print("HealthKit authorization denied!")
                if error != nil { print("\(String(describing: error))") } } }
        

        
        
    }
    
    
    
    
    @IBOutlet weak var backgroundViewFuerStatistik: UIView!{
        didSet{
            backgroundViewFuerStatistik.layer.cornerRadius    = 5.0
            backgroundViewFuerStatistik.layer.borderColor     = DesignPatterns.mocha.cgColor
            backgroundViewFuerStatistik.layer.borderWidth     = 0.5
            backgroundViewFuerStatistik.layer.shadowOffset    = CGSize(width: 2, height: 2)
            backgroundViewFuerStatistik.layer.shadowColor       = UIColor.white.cgColor
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        TimerConfig.deleteToDelete()
        statistikUeberblickView.daten   = StatistikUeberblickDaten()
        statistikUeberblick2View.daten  = StatistikUeberblickDaten()
        
        let freundesAnfragen = Freund.getFreundesAnfragen()
        subMenuBadgeButton.badgeString  = freundesAnfragen.count > 0 ? "\(freundesAnfragen.count)" : nil
        subMenuBadgeButton.badgeEdgeInsets = UIEdgeInsetsMake(15, 0, 0, 0)
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        healthManager.updateHealthKit()
    }
    
    
    //popover Hamburger Menue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "popoverSegue" {
            
            
            guard let popoverViewController = segue.destination as? SubMenuTableVC,
                let popoverPresentationController = segue.destination.popoverPresentationController,
                let sourceView = sender as? UIView else{return}
            
            popoverPresentationController.sourceRect = sourceView.bounds
            popoverViewController.popoverPresentationController!.delegate = self
            popoverViewController.cellSelected = {[unowned self] (_ indexPath:IndexPath) in
                self.cellSelected(indexPath) }
        }
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
        
    private func cellSelected(_ indexPath:IndexPath){
        dismiss(animated: true, completion: nil)
        switch indexPath.row {
        case 0:
            performSegue(withIdentifier: "meinProfil", sender: nil)
        case 1:
            guard testForNickNameFuerSegueToFreunde() else {return}
            performSegue(withIdentifier: "freunde", sender: nil)
        case 2:
            performSegue(withIdentifier: "go2Kurse", sender: nil)
        default:
            break
        }
    }
    
    private func testForNickNameFuerSegueToFreunde() -> Bool{
        if Meditierender.get()?.nickName?.isEmpty ?? true{
            let alert = UIAlertController(title: "Spitzname benötigt", message: "Um sich mit anderen Benutzern zu vernetzen, ist es notwendig zuvor einen Spitznamen zu vergeben", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel){ (action) in })
            present(alert, animated: true, completion: nil)
            return false
        }else{
            return true
        }
    }
}

class SubMenuTableVC:UITableViewController{
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cellSelected?(indexPath)
    }
    var cellSelected:((_ indexPath:IndexPath)->())?
    
    @IBOutlet weak var cell1: UITableViewCell!{ didSet{ setCellLabel(cell1) } }
    @IBOutlet weak var cell2: UITableViewCell!{ didSet{ setCellLabel(cell2) } }
    @IBOutlet weak var cell3: UITableViewCell!{ didSet{ setCellLabel(cell3) } }
    
    
    private func setCellLabel(_ cell:UITableViewCell){
        cell.backgroundColor = DesignPatterns.backgroundcolor
        cell.textLabel?.backgroundColor = UIColor.clear
        cell.textLabel?.layer.backgroundColor =  DesignPatterns.gelb.cgColor
        cell.textLabel?.set(layerDesign: DesignPatterns.standardButton)
        cell.textLabel?.textAlignment = NSTextAlignment.center
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = DesignPatterns.backgroundcolor
        return view
    }
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = DesignPatterns.backgroundcolor
        return view
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 6
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 6
    }
}
