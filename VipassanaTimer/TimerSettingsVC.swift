//
//  TimerConfigVCViewController.swift
//  Vipassana
//
//  Created by Matthias Pochmann on 03.05.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit

//✅
class TimerSettingsVC: DesignViewControllerPortrait {
    var viewModel:TimerSettingsViewControllerModel!
    override func viewDidLoad() {
        super.viewDidLoad()
        timerSettingsView.viewModel = viewModel.getViewModelForSettingsView()
        timerSettingsView.soundFileView.tapOnBluerViewGesture.addTarget(self, action: #selector(go2sound))
    }
    @objc func go2sound(){ performSegue(withIdentifier: "go2sound", sender: nil) }

    //Outlets
    @IBOutlet weak var timerSettingsView: TimerSettingsView!
    
    //segues (-> SoundFiles)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination.contentViewController as? SoundFilesTableVC)?.viewModel = viewModel.getViewModelForSoundFilesTableVC()
    }
    
    deinit { print("deinit TimerSettingsVC") }
}
