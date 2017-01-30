//
//  MeditationStartenVC.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 06.01.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import UIKit

class MeditationStartenVC: UIViewController,TimerConfigViewDelegateControlTapped {
    var hasRunningTimer = false{
        didSet{
            //startet laufenden Timer
        }
    }
    var timerConfig:TimerConfig? = TimerConfig.getActive(){
        didSet{
            timerConfigView?.timerConfig    = timerConfig
        }
    }
    @IBOutlet weak var timerConfigView: TimerConfigView!{
        didSet{
            timerConfigView.timerConfig             = timerConfig
            timerConfigView.zeigeSteuerungsPanel    = true
            timerConfigView.controlTappedDelegate   = self
        }
    }
    func controlTapped() {
        performSegue(withIdentifier: "goToMeineTimer", sender: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
    }
}
