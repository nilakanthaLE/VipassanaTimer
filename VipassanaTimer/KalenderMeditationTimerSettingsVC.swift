//
//  KalenderMeditationTimerSettingsVC.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 12.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit

class KalenderMeditationTimerSettingsVC: UIViewController {
    var viewModel:TimerSettingsViewControllerModel!
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return UIInterfaceOrientationMask.portrait  }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timerSettingsView.viewModel = viewModel.getViewModelForSettingsView()
        timerSettingsView.soundFileView.tapOnBluerViewGesture.addTarget(self, action: #selector(go2sound))
        view.backgroundColor        = UIColor(patternImage: #imageLiteral(resourceName: "backGroundImage.png"))
        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var timerSettingsView: TimerSettingsView!
    
    
    
    @objc func go2sound(){ performSegue(withIdentifier: "go2sound", sender: nil) }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination.contentViewController as? SoundFilesTableVC)?.viewModel = viewModel.getViewModelForSoundFilesTableVC()
    }
}
