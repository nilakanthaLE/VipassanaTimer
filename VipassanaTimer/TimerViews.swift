//
//  TimerView.swift
//  Vipassana
//
//  Created by Matthias Pochmann on 30.04.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa
import UIKit





@IBDesignable class TimerSettingsView:NibLoadingView{
    var viewModel:TimerSettingsViewModel!{
        didSet{
            timerAnzeige.viewModel      = viewModel.settingsForTimerViewModel
            settingsForTimer.viewModel  = viewModel.settingsForTimerViewModel
            soundFileView.viewModel     = viewModel.soundFileViewModel
        }
    }
    @IBOutlet weak var timerAnzeige: TimerAnzeigeView!
    @IBOutlet weak var settingsForTimer: SettingsForTimerView!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var soundFileView: SoundFileView!
}


@IBDesignable class SettingsForTimerView:NibLoadingView{
    var viewModel:SettingsForTimerViewModel!{
        didSet{
            //get
            anapanaSlider.reactive.value        <~ viewModel.anapanaSliderValue.producer
            mettaSlider.reactive.value          <~ viewModel.mettaSliderValue.producer
            anapanaSlider.reactive.maximumValue <~ viewModel.anapanaSliderMax.producer
            mettaSlider.reactive.maximumValue   <~ viewModel.mettaSliderMax.producer
            mettaOhneEndeSwitch.reactive.isOn   <~ viewModel.mettaEndlosSwitchIsOn.producer
            timerTitleTextField.reactive.text   <~ viewModel.titleTextFieldText.producer
            klangSchalenSwitch.reactive.isOn    <~ viewModel.soundSchalenSwitchIson.producer
            
            viewModel.gesamtDauerDatePicker.producer.startWithValues{[weak self] dauer in
                DispatchQueue.main.async { self?.gesamtDauerDatePicker.countDownDuration = dauer }//Apple Bug?
            }
            //SoundFileData
            mettaSlider.reactive.isEnabled              <~ viewModel.hasSoundFile.producer.map{!$0}
            mettaOhneEndeSwitch.reactive.isEnabled      <~ viewModel.hasSoundFile.producer.map{!$0}
            gesamtDauerDatePicker.reactive.isEnabled    <~ viewModel.hasSoundFile.producer.map{!$0}
            klangSchalenStack.reactive.isHidden         <~ viewModel.hasSoundFile.producer.map{!$0}
            mettaOhneEndeStack.reactive.isHidden        <~ viewModel.hasSoundFile.producer
            
            
            //set
            anapanaSlider.reactive.values.observeValues                     {[weak self] newValue in self?.viewModel.setNewSliderValues(dauer: TimeInterval(round(newValue) * 60), meditationsTyp: .anapana)}
            mettaSlider.reactive.values.observeValues                       {[weak self] newValue in  self?.viewModel.setNewSliderValues(dauer: TimeInterval(round(newValue) * 60), meditationsTyp: .metta)}
            mettaOhneEndeSwitch.reactive.isOnValues.observeValues           {[weak self] newValue in  self?.viewModel.setMettaEndlos(isEndlos: newValue)}
            timerTitleTextField.reactive.continuousTextValues.observeValues {[weak self] newValue in  self?.viewModel.setTitle(title: newValue)}
            gesamtDauerDatePicker.reactive.controlEvents(.valueChanged).signal.observeValues{[weak self] picker in self?.viewModel.setGesamtDauerPickerValue(dauer: picker.countDownDuration)}
            klangSchalenSwitch.reactive.isOnValues.observeValues           {[weak self] newValue in  self?.viewModel.setSoundSchalenAreOn(areOn: newValue)}
            
            
            gesamtDauerDatePicker.setValue(standardSchriftFarbe, forKey: "textColor")
            
            layer.borderColor   = standardRahmenFarbe.cgColor
            layer.borderWidth   = standardBorderWidth
            layer.cornerRadius  = standardCornerRadius
            clipsToBounds       = true
        }
    }
    @IBOutlet weak var anapanaSlider: UISlider!
    @IBOutlet weak var mettaSlider: UISlider!
    @IBOutlet weak var mettaOhneEndeSwitch: UISwitch!
    @IBOutlet weak var timerTitleTextField: UITextField!
    @IBOutlet weak var gesamtDauerDatePicker: UIDatePicker!
    @IBOutlet weak var mettaOhneEndeStack: UIStackView!
    @IBOutlet weak var klangSchalenStack: UIStackView!
    @IBOutlet weak var klangSchalenSwitch: UISwitch!
    
    deinit {
        print("deinit SettingsForTimerView")
    }
}


@IBDesignable class TimerAsTimerView:NibLoadingView{
    var viewModel:TimerAsTimerViewModel!{
        didSet{
            print("TimerAsTimerView --> viewModel didSet")
            timerAnzeige.viewModel = viewModel
            
            beendenButton.reactive.isHidden <~ viewModel.beendenButtonIsHidden.producer
            startenButton.reactive.title    <~ viewModel.startButtonTitle.producer
            viewModel.beendenButtonPressed  <~ beendenButton.reactive.controlEvents(.touchUpInside).signal.map{_ in ()}
            viewModel.startButtonPressed    <~ startenButton.reactive.controlEvents(.touchUpInside).signal.map{_ in ()}
            
            viewModel.anapanaBeendet.signal.observeValues   {_ in print("anapanaBeendet")}
            viewModel.vipassanaBeendet.signal.observeValues {_ in print("vipassanaBeendet")}
            viewModel.meditationBeendet.signal.observeValues{_ in print("meditationBeendet")}
           
            
            
            timerAnzeige.view.backgroundColor   = .clear
            timerAnzeige.layer.borderWidth      = 0
            
            
            layer.borderColor   = standardRahmenFarbe.cgColor
            layer.borderWidth   = standardBorderWidth
            layer.cornerRadius  = standardCornerRadius
            clipsToBounds       = true
        }
    }
    @IBOutlet private weak var timerAnzeige: TimerAnzeigeView!
    @IBOutlet private weak var beendenButton: UIButton!
    @IBOutlet private weak var startenButton: UIButton!
    
    var timerAnzeigeTapped:(()->Void)?
    @IBAction func timerAnzeigeTapped(_ sender: Any) {
        timerAnzeigeTapped?()
    }
    override var intrinsicContentSize: CGSize{ return CGSize(width: UIViewNoIntrinsicMetric, height: 100) }
    
    deinit {  print("deinit TimerAsTimerView") }
}

@IBDesignable class TimerInPublicMeditationInfoView:NibLoadingView{
    var viewModel:TimerInPublicMeditationInfoViewModel!{
        didSet{
            print("TimerAsTimerView --> viewModel didSet")
            timerAnzeigeView.viewModel = viewModel
            clipsToBounds       = true
        }
    }
    
    @IBOutlet weak var timerAnzeigeView: TimerAnzeigeView!
    override var intrinsicContentSize: CGSize{ return CGSize(width: UIViewNoIntrinsicMetric, height: 80) }
    deinit { print("deinit TimerInPublicMeditationInfoView") }
}



@IBDesignable class TimerAnzeigeView:NibLoadingView{
    var viewModel:TimerAnzeigeViewModel!{
        didSet{
            anapanaWidth.reactive.constant      <~ viewModel.anapanaWidth.signal
            mettaWidth.reactive.constant        <~ viewModel.mettaWidth.signal
            verdeckAnteil.reactive.constant     <~ viewModel.ablaufWidth.signal
            zeitAnzeigeLabel.reactive.text      <~ viewModel.zeitAnzeige.producer
            anapanaDauerLabel.reactive.text     <~ viewModel.anapanaDauerTitle.producer
            vipassanaDauerLabel.reactive.text   <~ viewModel.vipassanaDauerTitle.producer
            mettaDauerLabel.reactive.text       <~ viewModel.mettaDauerTitle.producer
            timerTitleLabel.reactive.text       <~ viewModel.timerTitle.producer
            hasSoundFileLabel.reactive.isHidden <~ viewModel.hasSoundFileLabelIsHidden.producer
            
            
            
            
            layer.borderColor   = standardRahmenFarbe.cgColor
            layer.borderWidth   = standardBorderWidth
            layer.cornerRadius  = standardCornerRadius
            clipsToBounds       = true
        }
    }
    
    @IBOutlet weak private var anapanaView: UIView!
    @IBOutlet weak private var mettaView: UIView!
    @IBOutlet weak private var verdeckView: UIView!
    @IBOutlet weak private var vipassanaView: UIView!
    @IBOutlet weak private var anapanaDauerLabel: UILabel!
    @IBOutlet weak private var vipassanaDauerLabel: UILabel!
    @IBOutlet weak private var mettaDauerLabel: UILabel!
    @IBOutlet weak private var timerTitleLabel: UILabel!
    @IBOutlet weak private var hasSoundFileLabel: UILabel!
    
    @IBOutlet weak private var zeitAnzeigeLabel: UILabel!
    @IBOutlet private weak var anapanaWidth: NSLayoutConstraint!
    @IBOutlet private weak var mettaWidth: NSLayoutConstraint!
    @IBOutlet private weak var verdeckAnteil: NSLayoutConstraint!
    @IBOutlet private weak var roundetView: BothSideRoundedView!
    
    override func layoutSubviews() { viewModel?.viewWidth.value      = roundetView.frame.width  }
    override var intrinsicContentSize: CGSize{ return CGSize(width: UIViewNoIntrinsicMetric, height: 80) }
    
    deinit { print("deinit TimerAnzeigeView") }
}





@IBDesignable class BothSideRoundedView:UIView{

    override func layoutSubviews() {
        layer.cornerRadius  = frame.height / 2
        clipsToBounds = true
    }
}










