//
//  KalenderMeditationTimerSettingsVC.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 12.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit

//✅
class KalenderMeditationTimerSettingsVC: DesignViewControllerPortrait {
    var viewModel:TimerSettingsViewControllerModel!
    
    // VC LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        timerSettingsView.viewModel = viewModel.getViewModelForSettingsView()
        timerSettingsView.soundFileView.tapOnBluerViewGesture.addTarget(self, action: #selector(go2sound))
        // Do any additional setup after loading the view.
    }
    
    //IBOutles
    @IBOutlet weak var timerSettingsView: TimerSettingsView!
    
    // segues
     @objc func go2sound(){ performSegue(withIdentifier: "go2sound", sender: nil) }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { (segue.destination.contentViewController as? SoundFilesTableVC)?.viewModel = viewModel.getViewModelForSoundFilesTableVC() }
}
