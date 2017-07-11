//
//  MeditationStartenVC.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 06.01.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import UIKit

class MeditationStartenVC: UIViewController,TimerConfigViewDelegateControlTapped {

    var timerConfig:TimerConfig? = TimerConfig.getActive()
        {didSet{ timerConfigView?.timerConfig    = timerConfig } }
    
    @IBOutlet weak var timerConfigView: TimerControl!{
        didSet{
            timerConfigView.timerConfig             = timerConfig
            timerConfigView.zeigeSteuerungsPanel    = true
            timerConfigView.controlTappedDelegate   = self
            timerConfigView.meditationGestartetOderBeendet     = {[unowned self](_ meditation:Meditation?) in
                self.meditierendeView.myActiveMeditation = meditation}
        }
    }
    func controlTapped()
        { performSegue(withIdentifier: "goToMeineTimer", sender: nil) }
    
    //MARK: lässt APP im Vordergrund
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        Singleton.sharedInstance.cloudKitActiveMeditationsUpdater?.isON = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    
    deinit {
        timerConfigView.invalidateTimers()
        timerConfigView.controlTappedDelegate = nil
        Singleton.sharedInstance.cloudKitActiveMeditationsUpdater?.isON = false
        print("deinit MeditationStartenVC")
    }
    
    
    @IBOutlet weak var meditierendeView: MeditierendeView!{
        didSet{
            meditierendeView.showUserMeditationInfo = {[unowned self](_ activeMeditation:CKActiveMeditation) in
                self.performSegue(withIdentifier: "showUserInfo", sender: activeMeditation)}
        }
    }
    
    //MARK: segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showUserInfo",
            let activeMeditation = sender as? CKActiveMeditation,
            let userMeditationInfoVC = segue.destination.contentViewController as? UserMeditationInfoVC  else {return}
        userMeditationInfoVC.activeMeditation   = activeMeditation
    }
    @IBAction func unwindToMeditationStarten(segue: UIStoryboardSegue){  }
}
