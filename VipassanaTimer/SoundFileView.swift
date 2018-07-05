//
//  SoundFileView.swift
//  Vipassana
//
//  Created by Matthias Pochmann on 07.05.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift


class SoundFileViewModel{
    let downloadProgress            = MutableProperty<Double>(0)
    let soundFileData               = MutableProperty<SoundFileData?>(nil)
    let soundFileDownloadVerdeck    = MutableProperty<Double>(0)
    let playSoundButtonAction       = MutableProperty<Void>(Void())
    var audioPlayer : AudioPlayer?
    
    init(soundFileData:MutableProperty<SoundFileData?> = MutableProperty<SoundFileData?>(nil),  downloadProgress: MutableProperty<(tag:Int,progress:Double)>? = nil, tag:Int = 0){
        self.soundFileData          <~ soundFileData.producer
        
        //initial
        spielZeitText.value = Double(0).hhmmss
        restZeitText.value  = "-" + (soundFileData.value?.duration ?? 0).hhmmss
        sliderValue.value   = 0
        
        //download
        if let downloadProgress = downloadProgress { soundFileDownloadVerdeck    <~ downloadProgress.signal.filter{$0.tag == tag}.map{$0.progress} }
        

        //Steuerung Play/Stop per Button
        playSoundButtonAction.signal.observe{[weak self] _ in
            let newSoundIsPlaying =  !(self?.soundIsPlaying.value ?? true)
            self?.soundIsPlaying.value                  = newSoundIsPlaying
            soundFileAudioPlayer.soundFileData.value    = newSoundIsPlaying ? self?.soundFileData.value : nil
        }
        
        //aktiver Player
        spielZeitText   <~ soundFileAudioPlayer.currentTimeSignal.signal.filter{[weak self] _ in self?.soundIsPlaying.value == true}.map{$0.hhmmss}
        restZeitText    <~ soundFileAudioPlayer.restZeit.signal.filter{[weak self] _ in self?.soundIsPlaying.value == true}.map{"-" + $0.hhmmss}
        sliderValue     <~ soundFileAudioPlayer.currentTimeSignal.signal.filter{[weak self] _ in self?.soundIsPlaying.value == true}.map{Float($0)}
        sliderMax       <~ soundFileAudioPlayer.dauer.producer.filter{[weak self] _ in self?.soundIsPlaying.value == true}.combinePrevious(0).filter{$0.0 != $0.1}.map{Float($0.1)}
        soundFileAudioPlayer.currentTimeSet <~ currentTimeSetter.signal.filter{[weak self] _ in self?.soundIsPlaying.value == true}
        
        //zurücksetzen
        soundIsPlaying  <~ soundFileAudioPlayer.soundFileData.signal.filter{$0 != soundFileData.value}.map{_ in false}
        spielZeitText   <~ soundIsPlaying.signal.filter{!$0}.map{_ in TimeInterval(0).hhmmss}
        restZeitText    <~ soundIsPlaying.signal.filter{!$0}.map{_ in  "-" + TimeInterval(soundFileData.value?.duration ?? 0).hhmmss}
        sliderValue     <~ soundIsPlaying.signal.filter{!$0}.map{_ in Float(0)}
        
        //von slider gesetzt
        spielZeitText   <~ currentTimeSetter.signal.map{TimeInterval($0).hhmmss}
        restZeitText    <~ currentTimeSetter.signal.map{[weak self] currentSet in "-" + (TimeInterval(self?.sliderMax.value ?? 0) - currentSet).hhmmss}
    }
    
    //Player
    let currentTimeAnzeige  = MutableProperty<TimeInterval>(0)
    let currentTimeSetter   = MutableProperty<TimeInterval>(0)
    let sliderMax           = MutableProperty<Float>(0)
    let sliderValue         = MutableProperty<Float>(0)
    let spielZeitText       = MutableProperty<String>(Double(0).hhmmss)
    let restZeitText        = MutableProperty<String>(Double(0).hhmmss)
    let soundIsPlaying      = MutableProperty<Bool>(false)
    deinit {
        soundFileAudioPlayer.soundFileData.value = nil
        print("deinit SoundFileViewModel")
    }
}



class SoundFileView:NibLoadingView{
    var viewModel:SoundFileViewModel!{
        didSet{
            soundFileWaehlenView.reactive.isHidden  <~ viewModel.soundFileData.producer.map{$0 != nil}
            mainStackView.reactive.isHidden         <~ viewModel.soundFileData.producer.map{$0 == nil}
            titleLabel.reactive.text                <~ viewModel.soundFileData.producer.map{$0?.title}
            durationLabel.reactive.text             <~ viewModel.soundFileData.producer.map{$0?.duration.hhmmss}
            mettaDurationLabel.reactive.text        <~ viewModel.soundFileData.producer.map{$0?.mettaDuration.hhmmss}
            soundFileDownloadView.reactive.isHidden <~ viewModel.soundFileData.producer.map{$0 == nil || $0?.isDownloaded == true}
            
            
            sliderForPlayer.reactive.value          <~ viewModel.sliderValue
            sliderForPlayer.reactive.maximumValue   <~ viewModel.sliderMax.producer
            viewModel.currentTimeSetter             <~ sliderForPlayer.reactive.values.map{TimeInterval($0)}
            spielZeitLabel.reactive.text            <~ viewModel.spielZeitText
            restZeitLabel.reactive.text             <~ viewModel.restZeitText
            viewModel.playSoundButtonAction <~ playButton.reactive.controlEvents(.touchUpInside).map{_ in Void()}
            
            sliderForPlayer.reactive.values.map{TimeInterval($0)}.signal.observeValues{print($0)}
            
            
            viewModel.soundFileDownloadVerdeck.signal.observeValues{[weak self] progress in self?.setProgress(progress) }
            
            layer.borderColor   = standardRahmenFarbe.cgColor
            layer.borderWidth   = standardBorderWidth
            layer.cornerRadius  = standardCornerRadius
            clipsToBounds       = true
            
            
        }
    }
    func setProgress(_ progress:Double){
        guard !progress.isNaN else {return}
        print("setProgress: \(progress)")
        
        soundFildeDownloadViewLeadingConstraint.constant = view.frame.width * CGFloat(progress)
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var mettaDurationLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var sliderForPlayer: UISlider!
    @IBOutlet weak var spielZeitLabel: UILabel!
    @IBOutlet weak var restZeitLabel: UILabel!
    @IBOutlet weak var soundFileWaehlenView: UIView!
    @IBOutlet weak var soundFileDownloadView: UIView!
    @IBOutlet weak var soundFildeDownloadViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet var tapOnBluerViewGesture: UITapGestureRecognizer!
    
    override var intrinsicContentSize: CGSize       { return (CGSize(width: UIViewNoIntrinsicMetric, height: 129)) }
}
