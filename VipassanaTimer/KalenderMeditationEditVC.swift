    
    //
//  EditMeditationVC.swift
//  Pods
//
//  Created by Matthias Pochmann on 16.01.17.
//
//

import UIKit
import ReactiveSwift
    
//✅
class EditMeditationVC: DesignViewControllerPortrait {
    var viewModel:EditMeditationVCViewModel!
    
    //IBOutlets
    @IBOutlet weak var eintragenButton: UIButton!
    @IBOutlet weak var loeschenButton: UIButton!
    @IBOutlet weak var timerAnzeigeView: TimerAnzeigeView!
    @IBOutlet weak var startZeitPicker: UIDatePicker!
    
    // VC LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //design
        startZeitPicker.setValue(standardSchriftFarbe, forKey: "textColor")
        startZeitPicker.setStandardDesign()
        startZeitPicker.backgroundColor = standardBackgroundFarbe
        
        //in
        timerAnzeigeView.viewModel  = viewModel.getViewModelForTimerAnzeigeView()
        loeschenButton.isHidden     = viewModel.loeschenButtonIsHidden
        startZeitPicker.date        = viewModel.startZeit.value
        
        //out
        viewModel.startZeit         <~ startZeitPicker.reactive.dates
        viewModel.eintragenAction   <~ eintragenButton.reactive.controlEvents(UIControlEvents.touchUpInside).map{_ in Void()}
        viewModel.loeschenAction    <~ loeschenButton.reactive.controlEvents(UIControlEvents.touchUpInside).map{_ in Void()}
        
        viewModel.loeschenAction.signal.observe{[weak self] _ in    self?.performSegue(withIdentifier: "reloadKalender", sender: nil)}
        viewModel.eintragenAction.signal.observe{[weak self] _ in   self?.performSegue(withIdentifier: "reloadKalender", sender: nil)}
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.updateTimerData()
    }
    
    //segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination.contentViewController as? KalenderMeditationTimerSettingsVC)?.viewModel = viewModel.getViewModelForKalenderMeditationTimerSettingsVC()
    }
}
