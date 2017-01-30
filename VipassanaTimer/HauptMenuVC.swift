//
//  HauptMenuVC.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 10.01.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import UIKit

class HauptMenuVC: UIViewController {

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
    }
    
}
