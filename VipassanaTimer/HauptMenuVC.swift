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
            if meditation.gesamtDauer < 30 * 60{
                meditation.delete()
                print("deleted")
            }
        }
        KursTemplate.createKursTemplates()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        TimerConfig.deleteToDelete()
        statistikUeberblickView.daten = StatistikUeberblickDaten()
    }
    @IBOutlet weak var statistikUeberblickView: StatistikUeberblick!{ didSet{statistikUeberblickView.delegate = self} }
    
    func infoButtonPressed(){
        performSegue(withIdentifier: "statistikStartDatumInfoSegue", sender: nil)
    }
    
    @IBOutlet weak var meditationStartenButton: UIButton!{didSet{meditationStartenButton.set(layerDesign: DesignPatterns.standardButton)}}
    @IBOutlet weak var kalenderButton: UIButton!{didSet{kalenderButton.set(layerDesign: DesignPatterns.standardButton)}}
    @IBOutlet weak var kurseButton: UIButton!{didSet{kurseButton.set(layerDesign: DesignPatterns.standardButton)}}
    @IBOutlet weak var statistikButton: UIButton!{didSet{statistikButton.set(layerDesign: DesignPatterns.standardButton)}}
}
