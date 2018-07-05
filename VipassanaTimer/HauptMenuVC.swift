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

import ReactiveSwift



class HauptMenuViewModel{ }


class HauptMenuVC: UIViewController,UIPopoverPresentationControllerDelegate {
    var viewModel:HauptMenuViewModel! = HauptMenuViewModel()
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return UIInterfaceOrientationMask.portrait  }
    
    @IBAction func unwindToHauptmenu(segue: UIStoryboardSegue){ saveContext() }

    
    

    let aufklappButtonPressed = MutableProperty<SubmenuButtonTyp>(.freunde)
    @IBOutlet weak var buttonHeightConstraint:  NSLayoutConstraint!
    @IBOutlet weak var aufklappButton:          AufklappHauptMenuButton!
    @IBOutlet weak var meditationStartenButton: UIButton!
    @IBOutlet weak var kalenderButton:          UIButton!
    @IBOutlet weak var statistikButton:         UIButton!
    @IBOutlet weak var statistikView:           HauptMenuStatistikenView!
    
    //MARK: VC LifeCycle
    let badgeCount = MutableProperty<Int>(0)
    override func viewDidLoad() {
        print("-->")
        super.viewDidLoad()
        view.backgroundColor = DesignPatterns.mainBackground
        
        aufklappButton.viewModel    = AufklappHauptMenuButtonViewModel(hoehe: buttonHeightConstraint.constant,pressed:aufklappButtonPressed, badgeCount: badgeCount)
        aufklappButtonPressed.signal.observeValues      {[weak self] typ in self?.buttonPressed(typ) }
        
        statistikView.viewModel     = HauptMenuStatistikenViewModel(statistics:statistics, infoButtonAction: infoButtonAction)
        
        //Notification über Firebase (News)
        mainModel.newNotification.signal.observeValues  {[weak self] notification in self?.show(notification:notification)}
        
        infoButtonAction.signal.observe                 {[weak self] _ in self?.performSegue(withIdentifier: "statistikStartDatumInfoSegue", sender: nil)}
    }

    
    
    private func show(notification:(key:String,message:String?)){
        print("alert: \(notification)")
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
    
    let infoButtonAction    = MutableProperty<Void>(Void())
    let statistics          = MutableProperty<Statistics>(Statistics.get())
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Statistics.setCoreDataStatisticsAsync { [weak self] in self?.statistics.value      = Statistics.get()  }
       
        badgeCount.value        = Freund.getFreundesAnfragen().count
        
        
        HealthManager().updateHealthKit()
        StoreReviewHelper.checkAndAskForReview()
        aufklappButton.viewModel.isAufgeklappt.value = false
    }

   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination.contentViewController as? MeditationsTimerVC)?.viewModel = MeditationsTimerVCModel(model: MeditationsTimerModel())
    }
    
    
    
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
            let alert = UIAlertController(title: "Spitzname benötigt", message: "Um sich mit anderen Benutzern zu vernetzen, ist es notwendig zuvor einen Spitznamen zu vergeben", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel){ (action) in })
            present(alert, animated: true, completion: nil)
        }
        else{ performSegue(withIdentifier: "freunde", sender: nil) }
    }
}



