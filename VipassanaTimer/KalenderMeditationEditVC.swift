    
    //
//  EditMeditationVC.swift
//  Pods
//
//  Created by Matthias Pochmann on 16.01.17.
//
//

import UIKit
//import MyCalendar
import ReactiveSwift
    
    
    
class EditMeditationVCViewModel{
    
    let loeschenButtonIsHidden:Bool
    
    let startZeit       = MutableProperty<Date>(Date())
    let eintragenAction = MutableProperty<Void>(Void())
    let loeschenAction  = MutableProperty<Void>(Void())
    var meditation:Meditation?
    let timerData:TimerData
    let timerAnzeigeModel:TimerAnzeigeModel
    init(meditation:Meditation?,date:Date = Date()){
        timerData               = TimerData(meditation: meditation) ?? TimerData()
        timerAnzeigeModel       = TimerAnzeigeModel(timerData: timerData)
        self.meditation         = meditation
        loeschenButtonIsHidden  = meditation == nil
        startZeit.value         = meditation?.start ?? date
        
        eintragenAction.signal.observe{[weak self] _ in self?.meditationEintragenAction()}
        loeschenAction.signal.observe{[weak self] _ in self?.loeschenActionFunc()}
    }
    
    func meditationEintragenAction() {
        meditation = meditation?.update(with: timerData) ?? Meditation.new(timerData: timerData, start: startZeit.value)
        HealthManager().saveMeditationIfNeeded(meditation: meditation!)
        FirMeditations.update(meditation: meditation!)
        saveContext()
    }
    func loeschenActionFunc() {
        FirMeditations.deleteMeditation(meditation:meditation)
        meditation?.delete(inFirebaseToo: true)
    }
    
    
    func getViewModelForTimerAnzeigeView() -> TimerAnzeigeViewModel{ return TimerAnzeigeViewModel(model: timerAnzeigeModel)  }
    func getViewModelForKalenderMeditationTimerSettingsVC() -> TimerSettingsViewControllerModel{ return TimerSettingsViewControllerModel(timerData: timerData)  }
    
    func updateTimerData(){ timerAnzeigeModel.timerData.value = timerData }
    
    deinit {  print("deinit EditMeditationVCViewModel") }
}

    
class EditMeditationVC: UIViewController {
    var viewModel:EditMeditationVCViewModel!
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return UIInterfaceOrientationMask.portrait  }
    
    @IBOutlet weak var eintragenButton: UIButton!
    @IBOutlet weak var loeschenButton: UIButton!
    @IBOutlet weak var timerAnzeigeView: TimerAnzeigeView!
    @IBOutlet weak var startZeitPicker: UIDatePicker!{didSet{
            startZeitPicker.layer.borderColor      = standardRahmenFarbe.cgColor
            startZeitPicker.layer.borderWidth      = standardBorderWidth
            startZeitPicker.layer.cornerRadius     = standardCornerRadius
            startZeitPicker.clipsToBounds           = true
            startZeitPicker.backgroundColor         = standardBackgroundFarbe
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination.contentViewController as? KalenderMeditationTimerSettingsVC)?.viewModel = viewModel.getViewModelForKalenderMeditationTimerSettingsVC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.updateTimerData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor            = UIColor(patternImage: #imageLiteral(resourceName: "backGroundImage.png"))
        navigationController?.navigationBar.setDesignPattern()
        startZeitPicker.setValue(DesignPatterns.mocha, forKey: "textColor")
        
        loeschenButton.set(layerDesign: DesignPatterns.standardButton)
        eintragenButton.set(layerDesign: DesignPatterns.standardButton)
        
        timerAnzeigeView.viewModel  = viewModel.getViewModelForTimerAnzeigeView()
        
        loeschenButton.isHidden     = viewModel.loeschenButtonIsHidden
        startZeitPicker.date        = viewModel.startZeit.value
        
        viewModel.startZeit         <~ startZeitPicker.reactive.dates
        viewModel.eintragenAction   <~ eintragenButton.reactive.controlEvents(UIControlEvents.touchUpInside).map{_ in Void()}
        viewModel.loeschenAction    <~ loeschenButton.reactive.controlEvents(UIControlEvents.touchUpInside).map{_ in Void()}
        
        viewModel.loeschenAction.signal.observe{[weak self] _ in    self?.performSegue(withIdentifier: "reloadKalender", sender: nil)}
        viewModel.eintragenAction.signal.observe{[weak self] _ in   self?.performSegue(withIdentifier: "reloadKalender", sender: nil)}
    }
}
