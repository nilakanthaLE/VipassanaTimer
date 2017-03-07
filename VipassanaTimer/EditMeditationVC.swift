    
    //
//  EditMeditationVC.swift
//  Pods
//
//  Created by Matthias Pochmann on 16.01.17.
//
//

import UIKit
import MyCalendar

class EditMeditationVC: UIViewController,TimerConfigViewDelegateControlTapped {

    @IBOutlet weak var eintragenButton: UIButton!{
        didSet{
            eintragenButton.set(layerDesign: DesignPatterns.standardButton)
        }
    }
    @IBAction func loeschenButtonPressed(_ sender: UIButton) {
        meditation?.delete()
        performSegue(withIdentifier: "reloadKalender", sender: nil)
    }
    @IBOutlet weak var loeschenButton: UIButton!{
        didSet{
            loeschenButton.isHidden = meditation == nil
            loeschenButton.set(layerDesign: DesignPatterns.standardButton)
        }
    }
    var meditation:Meditation? {
        didSet{
            guard let meditation        = meditation else{return}
            TimerConfig.deleteToDelete()
            timerConfig                 = TimerConfig.get(with: meditation)
            startZeitPicker?.date       = meditation.start as! Date
            loeschenButton?.isHidden    = false
        }
    }
    var timerConfig:TimerConfig? = TimerConfig.getActive(){
        didSet{
            timerConfigView?.timerConfig    = timerConfig
        }
    }
    @IBOutlet weak var timerConfigView: TimerConfigView!{
        didSet{
            timerConfigView.timerConfig                         = timerConfig
            timerConfigView.zeigeSteuerungsPanel                = false
            timerConfigView.tapGestureRecognizer.isEnabled      = true
            timerConfigView.controlTappedDelegate               = self
        }
    }
    @IBAction func meditationEintragenPressed(_ sender: UIButton) {
        let start = startZeitPicker.date

        guard let timerConfig = timerConfig  else {return}
        if meditation == nil{
            if let meditation = Meditation.new(start: start, mettaOpenEnd: timerConfig.mettaOpenEnd,name: timerConfig.name){
                meditation.dauerAnapana     = timerConfig.dauerAnapana
                meditation.dauerVipassana   = timerConfig.dauerVipassana
                meditation.dauerMetta       = timerConfig.dauerMetta
                let dauerGesamt = timerConfig.dauerAnapana + timerConfig.dauerVipassana + timerConfig.dauerMetta
                meditation.ende             = start.addingTimeInterval(TimeInterval(dauerGesamt)) as NSDate?
                self.meditation             = meditation
            }
        }else{
            meditation!.start               = start as NSDate?
            meditation!.dauerAnapana        = timerConfig.dauerAnapana
            meditation!.dauerVipassana      = timerConfig.dauerVipassana
            meditation!.dauerMetta          = timerConfig.dauerMetta
            let dauerGesamt                 = timerConfig.dauerAnapana + timerConfig.dauerVipassana + timerConfig.dauerMetta
            meditation!.ende                = start.addingTimeInterval(TimeInterval(dauerGesamt)) as NSDate?
        }
        HealthManager().saveMeditationIfNeeded(meditation: meditation!)
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        performSegue(withIdentifier: "reloadKalender", sender: nil)
    }

    @IBOutlet weak var startZeitPicker: UIDatePicker!
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let meditation        = meditation else{return}
        startZeitPicker.setDate(meditation.start as! Date, animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startZeitPicker.setValue(DesignPatterns.mocha, forKey: "textColor")
    }
    
    func controlTapped() {
        performSegue(withIdentifier: "goToMeineTimer", sender: nil)
    }
    
    

}
