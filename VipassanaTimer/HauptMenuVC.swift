//
//  HauptMenuVC.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 10.01.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import UIKit

class HauptMenuVC: UIViewController,StatistikUeberblickDelegate {

    @IBAction func unwindToHauptmenu(segue: UIStoryboardSegue){
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if segue.source is MeditationStartenVC{
            BackgroundInfo.getInfo()?.meditation?.earlyEnd(date:Date())
            delegate?.invalidateForegroundTimers()
            BackgroundInfo.getInfo()?.delete()
        }
        delegate?.saveContext()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if BackgroundInfo.getInfo()?.meditationsEnde != nil && BackgroundInfo.getInfo()!.meditationsEnde!.isGreaterThanDate(dateToCompare: Date()){
            //segue to Metitation starten
            
        }
        for meditation in Meditation.getAll(){
            if meditation.gesamtDauer < 5 * 60{
                meditation.delete()
                print("deleted")
            }
        }
        
        //Anzahl KursTage nachtragen
        KursTemplate.get(name: "10-Tage Kurs")?.kursTage   = 10
        for kurs in Kurs.getAll(){
            //Anzahl KursTage nachtragen
            kurs.kursTemplate   = KursTemplate.get(name: "10-Tage Kurs")
            kurs.kursTage = kurs.kursTemplate?.kursTage ?? 0
            //Startdatum nachtragen
            let start = Meditation.sorted(meditationen: Array(kurs.meditations as! Set<Meditation>)).first?.start
            kurs.start = start
        }
        KursTemplate.createKursTemplates()
        
        if TimerConfig.getAll().count == 0{
            let new     = TimerConfig.new(dauerAnapana: 5*60, dauerVipassana: 50*60, dauerMetta: 5*60, mettaOpenEnd: false)
            new?.name   = "eine Stunde mit Anapana und Metta"
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        TimerConfig.deleteToDelete()
        statistikUeberblickView.daten   = StatistikUeberblickDaten()
        statistikUeberblick2View.daten  = StatistikUeberblickDaten()
    }
    
    @IBOutlet weak var statistikUeberblick2View: StatistikUeberblick2!{ didSet{statistikUeberblick2View.delegate = self} }
    @IBOutlet weak var statistikUeberblickView: StatistikUeberblick!{ didSet{statistikUeberblickView.delegate = self} }
    
    func infoButtonPressed(){
        performSegue(withIdentifier: "statistikStartDatumInfoSegue", sender: nil)
    }
    
    @IBOutlet weak var meditationStartenButton: UIButton!{didSet{meditationStartenButton.set(layerDesign: DesignPatterns.standardButton)}}
    @IBOutlet weak var kalenderButton: UIButton!{didSet{kalenderButton.set(layerDesign: DesignPatterns.standardButton)}}
    @IBOutlet weak var kurseButton: UIButton!{didSet{kurseButton.set(layerDesign: DesignPatterns.standardButton)}}
    @IBOutlet weak var statistikButton: UIButton!{didSet{statistikButton.set(layerDesign: DesignPatterns.standardButton)}}
    
    
    func viewTapped() {
        statistikUeberblickView.isHidden    = statistikUeberblickView.isHidden ? false : true
        statistikUeberblick2View.isHidden   = statistikUeberblick2View.isHidden ? false : true
    }
}
