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




class HauptMenuViewModel{
    func getViewModelForStatistikUeberblickI()->StatistikUeberblickViewModel{
        return StatistikUeberblickViewModel(model: StatistikModel())
    }
}


class HauptMenuVC: UIViewController,StatistikUeberblickDelegate,UIPopoverPresentationControllerDelegate {
    var viewModel:HauptMenuViewModel! = HauptMenuViewModel(){
        didSet{
            
        }
    }
    
    
    @IBAction func unwindToHauptmenu(segue: UIStoryboardSegue){ saveContext() }
    
    @IBOutlet weak var statistikUeberblick2View: StatistikUeberblick2!{
        didSet{
            statistikUeberblick2View.delegate = self
            
        }
    }
    @IBOutlet weak var statistikUeberblickView: StatistikUeberblick!
        {
        didSet{
            statistikUeberblickView.delegate = self
            statistikUeberblickView.viewModel = viewModel.getViewModelForStatistikUeberblickI()
        }
    }
    @IBOutlet weak var meditationStartenButton: UIButton!       {didSet{meditationStartenButton.set(layerDesign: DesignPatterns.standardButton)}}
    @IBOutlet weak var kalenderButton:          UIButton!       {didSet{kalenderButton.set(layerDesign: DesignPatterns.standardButton)}}
    @IBOutlet weak var subMenuBadgeButton:      MIBadgeButton!  {didSet{subMenuBadgeButton.set(layerDesign: DesignPatterns.standardButton)}}
    @IBOutlet weak var statistikButton:         UIButton!       {didSet{statistikButton.set(layerDesign: DesignPatterns.standardButton)}}
    
    //MARK: Delegates
    func infoButtonPressed(){ performSegue(withIdentifier: "statistikStartDatumInfoSegue", sender: nil) }
    func viewTapped() {
        statistikUeberblickView.isHidden    = statistikUeberblickView.isHidden ? false : true
        statistikUeberblick2View.isHidden   = statistikUeberblick2View.isHidden ? false : true
    }
    
    
    //MARK: VC LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DesignPatterns.mainBackground
    }
    
    
    
    
    @IBOutlet weak var backgroundViewFuerStatistik: UIView!     { didSet{ backgroundViewFuerStatistik.setControlDesignPatterns() } }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        TimerConfig.deleteToDelete()
        StatistikUeberblickDaten.setCoreDataStatisticsAsync {
            //update
            [weak self] in
            self?.statistikUeberblick2View?.daten   = Statistics.get()
        }
        
        let freundesAnfragen = Freund.getFreundesAnfragen()
        subMenuBadgeButton.badgeString      = freundesAnfragen.count > 0 ? "\(freundesAnfragen.count)" : nil
        subMenuBadgeButton.badgeEdgeInsets  = UIEdgeInsetsMake(15, 0, 0, 0)
        
        HealthManager().updateHealthKit()
    }

    //popover Hamburger Menue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "popoverSegue" {
            
            
            guard let popoverViewController = segue.destination as? SubMenuTableVC,
                let popoverPresentationController = segue.destination.popoverPresentationController,
                let sourceView = sender as? UIView else{return}
            
            popoverPresentationController.sourceRect = sourceView.bounds
            popoverViewController.popoverPresentationController!.delegate = self
            popoverViewController.cellSelected = {[weak self] (_ indexPath:IndexPath) in
                self?.cellSelected(indexPath) }
            popoverPresentationController.backgroundColor = UIColor.clear
        }
        
        (segue.destination.contentViewController as? MeditationsTimerVC)?.viewModel = MeditationsTimerVCModel(model: MeditationsTimerModel())
        //MeditationsTimerViewControllerModel(model: TimerAsTimerModel())
        
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle { return .none }
        
    private func cellSelected(_ indexPath:IndexPath){
        dismiss(animated: true, completion: nil)
        switch indexPath.row {
        case 0: performSegue(withIdentifier: "meinProfil", sender: nil)
        case 1:
            guard testForNickNameFuerSegueToFreunde() else {return}
            performSegue(withIdentifier: "freunde", sender: nil)
        case 2: performSegue(withIdentifier: "go2Kurse", sender: nil)
        default: break
        }
    }
    
    private func testForNickNameFuerSegueToFreunde() -> Bool{
        if Meditierender.get()?.nickName?.isEmpty ?? true{
            let alert = UIAlertController(title: "Spitzname benötigt", message: "Um sich mit anderen Benutzern zu vernetzen, ist es notwendig zuvor einen Spitznamen zu vergeben", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel){ (action) in })
            present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
}



class SubMenuTableVC:UITableViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cellSelected?(indexPath)
    }
    var cellSelected:((_ indexPath:IndexPath)->())?
    
    @IBOutlet weak var cell1: UITableViewCell!{ didSet{ setCellLabel(cell1) } }
    @IBOutlet weak var cell2: UITableViewCell!{ didSet{ setCellLabel(cell2) } }
    @IBOutlet weak var cell3: UITableViewCell!{ didSet{ setCellLabel(cell3) } }
    
    
    private func setCellLabel(_ cell:UITableViewCell){
        cell.backgroundColor = UIColor.clear //DesignPatterns.backgroundcolor
        cell.textLabel?.backgroundColor = UIColor.clear
        cell.textLabel?.layer.backgroundColor =  DesignPatterns.gelb.cgColor
        cell.textLabel?.set(layerDesign: DesignPatterns.standardButton)
        cell.textLabel?.textAlignment = NSTextAlignment.center
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        

        
        
        view.backgroundColor = UIColor.clear
    
        return view
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 6
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 6
    }
}



extension UIView{
    func setBackgroundImage(image:UIImage){
        let imageView = UIImageView(image: image)
        addConstraint(NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: imageView, attribute: .leading, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: imageView, attribute: .trailing, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: imageView, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: imageView, attribute: .bottom, multiplier: 1, constant: 0))
        addSubview(  imageView )
    }
    func setControlDesignPatterns(){
        backgroundColor         = DesignPatterns.controlBackground
        layer.cornerRadius      = 5.0
        layer.borderColor       = DesignPatterns.mocha.cgColor
        layer.borderWidth       = 0.5
        layer.shadowOffset      = CGSize(width: 2, height: 2)
        layer.shadowColor       = UIColor.white.cgColor
        clipsToBounds           = true
    }
}
