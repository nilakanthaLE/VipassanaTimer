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
import ReactiveSwift

//✅
class HauptMenuViewModel{
    private let badgeCount          = MutableProperty<Int>(0)
    private let statistics          = MutableProperty<Statistics>(Statistics.get())
    
    let infoButtonAction            = MutableProperty<Void>(Void())
    let aufklappButtonPressed       = MutableProperty<SubmenuButtonTyp>(.freunde)
    func updateBadgCount()  { badgeCount.value    = Freund.getFreundesAnfragen().count }
    func updateStatistics() { statistics.value    = Statistics.get() }
    
    //ViewModels
    func getViewModelForStatistik() -> HauptMenuStatistikenViewModel                                { return HauptMenuStatistikenViewModel(statistics: statistics, infoButtonAction: infoButtonAction) }
    func getViewModelForAufKlappButton(buttonHeight:CGFloat) -> AufklappHauptMenuButtonViewModel    { return AufklappHauptMenuButtonViewModel(hoehe: buttonHeight, pressed: aufklappButtonPressed, badgeCount: badgeCount) }
}

//✅
class HauptMenuVC: DesignViewControllerPortrait,UIPopoverPresentationControllerDelegate {
    let viewModel:HauptMenuViewModel! = HauptMenuViewModel()
    
    // VC LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //löscht alle Meditationen kürzer als 5 min
        Meditation.cleanShortMeditations()
        
        //viewModels
        aufklappButton.viewModel    = viewModel.getViewModelForAufKlappButton(buttonHeight: buttonHeightConstraint.constant)
        statistikView.viewModel     = viewModel.getViewModelForStatistik()
        
        //ButtonActions
        viewModel.aufklappButtonPressed.signal.observeValues    {[weak self] typ in self?.buttonPressed(typ) }
        viewModel.infoButtonAction.signal.observe {[weak self] _ in self?.performSegue(withIdentifier: "statistikStartDatumInfoSegue", sender: nil)}
        
        //Notification über Firebase (News)
        newNotification.signal.observeValues  {[weak self] notification in self?.show(notification:notification)}
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //update Badge und Statistics
        Statistics.setCoreDataStatisticsAsync { [weak self] in self?.viewModel.updateStatistics() }
        viewModel.updateBadgCount()
        
        //Aufklappbutton schließen
        aufklappButton.viewModel.isAufgeklappt.value = false
        
        //HealthManager update
        // um Bewertung bitten
        HealthManager().updateHealthKit()
        StoreReviewHelper.checkAndAskForReview()
    }

    // IBOutlets
    @IBOutlet weak var buttonHeightConstraint:  NSLayoutConstraint!
    @IBOutlet weak var aufklappButton:          AufklappHauptMenuButton!
    @IBOutlet weak var meditationStartenButton: UIButton!
    @IBOutlet weak var kalenderButton:          UIButton!
    @IBOutlet weak var statistikButton:         UIButton!
    @IBOutlet weak var statistikView:           HauptMenuStatistikenView!
    
    // Segues
    @IBAction func unwindToHauptmenu(segue: UIStoryboardSegue){ saveContext() }
    private func buttonPressed(_ typ:SubmenuButtonTyp){
        dismiss(animated: true, completion: nil)
        switch typ {
        case .kurse:        performSegue(withIdentifier: "go2Kurse", sender: nil)
        case .freunde:      segueToFreunde()
        case .profil:       performSegue(withIdentifier: "meinProfil", sender: nil)
        case .klappButton:  break
        case .dana:         performSegue(withIdentifier: "showDana", sender: nil)
        }
    }
    private func segueToFreunde(){
        if Meditierender.get()?.nickName?.isEmpty ?? true{
            let alert = UIAlertController(title: NSLocalizedString("nickNeededTitle",       comment: "nickNeededTitle"),
                                          message: NSLocalizedString("nickNeededMessage",   comment: "nickNeededMessage"),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel){ (action) in })
            present(alert, animated: true, completion: nil)
        }
        else{ performSegue(withIdentifier: "freunde", sender: nil) }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination.contentViewController as? MeditationsTimerVC)?.viewModel = MeditationsTimerVCModel()
        (segue.destination.contentViewController as? FreundeTableVC)?.viewModel     = FreundeTableVCModel()
        
    }
    
    //helper
    // zeigt Neuigkeiten, die über FirebaseEintrg kommen
    private func show(notification:(key:String,message:String?)){
        guard let message = notification.message else {return}
        let alert = UIAlertController(title: "News", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Nicht erneut zeigen", style: .default) { _ in
            AppConfig.get()?.firLastNotification = notification.key
            saveContext()
            self.dismiss(animated: true, completion: nil)
        })
        present(alert, animated: true, completion: nil)
    }
}



