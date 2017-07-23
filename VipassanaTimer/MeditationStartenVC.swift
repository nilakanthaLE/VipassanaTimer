//
//  MeditationStartenVC.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 06.01.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import UIKit

extension UINavigationBar{
    func setDesignPattern(){
        barTintColor    = DesignPatterns.headerBackground
        tintColor       = DesignPatterns.mocha
        titleTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: DesignPatterns.mocha]
    }
}

class MeditationStartenVC: UIViewController,TimerConfigViewDelegateControlTapped {

    var timerConfig:TimerConfig? = TimerConfig.getActive()
        {didSet{ timerConfigView?.timerConfig    = timerConfig } }
    
    @IBOutlet weak var timerConfigView: TimerControl!{
        didSet{
            timerConfigView.timerConfig             = timerConfig
            timerConfigView.zeigeSteuerungsPanel    = true
            timerConfigView.controlTappedDelegate   = self
            timerConfigView.meditationGestartetOderBeendet     = {[unowned self](_ meditation:Meditation?) in self.meditierendeView.myActiveMeditation = meditation}
        }
    }
    func controlTapped()
        { performSegue(withIdentifier: "goToMeineTimer", sender: nil) }
    
    //MARK: lässt APP im Vordergrund
    override func viewDidLoad() {
        super.viewDidLoad()
        FirActiveMeditations.setObserver()
        UIApplication.shared.isIdleTimerDisabled = true
        view.backgroundColor    = DesignPatterns.mainBackground
        
        navigationController?.navigationBar.setDesignPattern()
        navigationController?.view.backgroundColor           = UIColor.black
    }
    deinit {
        timerConfigView.invalidateTimers()
        timerConfigView.controlTappedDelegate = nil
        
        UIApplication.shared.isIdleTimerDisabled = false
        FirActiveMeditations.removeObserver()
        FirActiveMeditations.deleteActiveMeditation()
        print("deinit MeditationStartenVC")
    }
    
    
    @IBOutlet weak var meditierendeView: MeditierendeView!{
        didSet{
            meditierendeView.showUserMeditationInfo = {[unowned self](_ activeMeditation:ActiveMeditationInFB) in
                self.performSegue(withIdentifier: "showUserInfo", sender: activeMeditation)}
            meditierendeView.backgroundColor = DesignPatterns.controlBackground
            
        }
    }
    
    //MARK: segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showUserInfo",
            let activeMeditation = sender as? ActiveMeditationInFB,
            let userMeditationInfoVC = segue.destination.contentViewController as? UserMeditationInfoVC  else {return}
        userMeditationInfoVC.activeMeditation   = activeMeditation
    }
    @IBAction func unwindToMeditationStarten(segue: UIStoryboardSegue){  }
}
