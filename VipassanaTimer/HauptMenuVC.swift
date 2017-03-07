//
//  HauptMenuVC.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 10.01.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import UIKit
import HealthKit

class HauptMenuVC: UIViewController,StatistikUeberblickDelegate {
    let healthManager = HealthManager()
    @IBAction func unwindToHauptmenu(segue: UIStoryboardSegue){
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if segue.source is MeditationStartenVC{
            BackgroundInfo.getInfo()?.meditation?.earlyEnd(date:Date())
            delegate?.invalidateForegroundTimers()
            BackgroundInfo.getInfo()?.delete()
        }
        delegate?.saveContext()
    }
    
    @IBOutlet weak var statistikUeberblick2View: StatistikUeberblick2!{ didSet{statistikUeberblick2View.delegate = self} }
    @IBOutlet weak var statistikUeberblickView: StatistikUeberblick!{ didSet{statistikUeberblickView.delegate = self} }
    @IBOutlet weak var meditationStartenButton: UIButton!{didSet{meditationStartenButton.set(layerDesign: DesignPatterns.standardButton)}}
    @IBOutlet weak var kalenderButton: UIButton!{didSet{kalenderButton.set(layerDesign: DesignPatterns.standardButton)}}
    @IBOutlet weak var kurseButton: UIButton!{didSet{kurseButton.set(layerDesign: DesignPatterns.standardButton)}}
    @IBOutlet weak var statistikButton: UIButton!{didSet{statistikButton.set(layerDesign: DesignPatterns.standardButton)}}
    
    func infoButtonPressed(){ performSegue(withIdentifier: "statistikStartDatumInfoSegue", sender: nil) }
    func viewTapped() {
        statistikUeberblickView.isHidden    = statistikUeberblickView.isHidden ? false : true
        statistikUeberblick2View.isHidden   = statistikUeberblick2View.isHidden ? false : true
    }
    
    //MARK: VC LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                if error != nil { print("\(error)") } } }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        TimerConfig.deleteToDelete()
        statistikUeberblickView.daten   = StatistikUeberblickDaten()
        statistikUeberblick2View.daten  = StatistikUeberblickDaten()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        healthManager.updateHealthKit()
    }
}
