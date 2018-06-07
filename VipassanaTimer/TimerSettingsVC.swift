//
//  TimerConfigVCViewController.swift
//  Vipassana
//
//  Created by Matthias Pochmann on 03.05.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift

class TimerSettingsViewControllerModel{
    let timerData:TimerData
    let timerSettingsModel:TimerSettingsModel
    init(timerData:TimerData){
        timerSettingsModel = TimerSettingsModel(timerData: timerData)
        self.timerData = timerData  }
    func getViewModelForSettingsView() -> TimerSettingsViewModel        { return TimerSettingsViewModel(model: timerSettingsModel) }
    func getViewModelForSoundFilesTableVC() -> SoundFilesTableVCModel   { return SoundFilesTableVCModel(soundFileData:timerSettingsModel.soundFileData)  }
}

class TimerSettingsVC: UIViewController {
    var viewModel:TimerSettingsViewControllerModel!
    override func viewDidLoad() {
        super.viewDidLoad()
        timerSettingsView.viewModel = viewModel.getViewModelForSettingsView()
        timerSettingsView.soundFileView.tapOnBluerViewGesture.addTarget(self, action: #selector(go2sound))
        view.backgroundColor        = UIColor(patternImage: #imageLiteral(resourceName: "backGroundImage.png"))
    }

    @objc func go2sound(){
        performSegue(withIdentifier: "go2sound", sender: nil)
    }

    
    @IBOutlet weak var timerSettingsView: TimerSettingsView!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination.contentViewController as? SoundFilesTableVC)?.viewModel = viewModel.getViewModelForSoundFilesTableVC()
    }
}
