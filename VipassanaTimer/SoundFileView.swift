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
    
    init(soundFileData:MutableProperty<SoundFileData?> = MutableProperty<SoundFileData?>(nil),
         downloadProgress: MutableProperty<(tag:Int,progress:Double)>? = nil,
         tag:Int = 0){
        
        if let downloadProgress = downloadProgress {
            soundFileDownloadVerdeck    <~ downloadProgress.signal.filter{$0.tag == tag}.map{$0.progress}
        }
        self.soundFileData          <~ soundFileData.producer
        
        soundFileDownloadVerdeck.signal.observeValues{print($0)}
        
        playSoundButtonAction.signal.observe{[weak self] _ in
            self?.soundIsPlaying.value = !(self?.soundIsPlaying.value ?? true)
            self?.playSound()
        }
        
        soundIsPlaying.signal.observeValues{[weak self] isPlaying in
            print(("isPlaying \(isPlaying)"))
            switch isPlaying{
                case true:
                    self?.playSound()
                case false:
                    self?.audioPlayer?.stopPlaying()
                    self?.audioPlayer = nil
            }
        }
        
        //initial
        spielZeitText.value = Double(0).hhmmss
        restZeitText.value  = "-" + (soundFileData.value?.duration ?? 0).hhmmss
        
        spielZeitText   <~ currentTimeSetter.map{$0.hhmmss}
        restZeitText    <~ currentTimeSetter.map{[weak self] current in "-" + (TimeInterval(self?.sliderMax.value ?? 0) - current).hhmmss}
    }
    
    //Player
    let currentTimeAnzeige  = MutableProperty<TimeInterval>(0)
    let currentTimeSetter   = MutableProperty<TimeInterval>(0)
    let sliderMax           = MutableProperty<Float>(0)
    let sliderValue         = MutableProperty<Float>(0)
    let spielZeitText       = MutableProperty<String>(Double(0).hhmmss)
    let restZeitText        = MutableProperty<String>(Double(0).hhmmss)
    let soundIsPlaying      = MutableProperty<Bool>(false)
    private func playSound(){
        if audioPlayer == nil { audioPlayer = AudioPlayer() }
        let playerValues    = audioPlayer?.playSound(url: soundFileData.value?.loacalSoundfileURL, currentTimeSet: currentTimeSetter)
        sliderMax.value     = Float(playerValues?.duration ?? 0)
        playerValues?.currentTime.signal.observeValues{[weak self] currentTime in
            self?.sliderValue.value = Float(currentTime)
            print("currentTime: \(currentTime)")
            
            self?.spielZeitText.value   = Double(currentTime).hhmmss
            self?.restZeitText.value    = "-" + Double((playerValues?.duration ?? 0) - currentTime).hhmmss
        }
    }
    
    deinit { print("<<<<____>>>> deinit SoundFileViewModel") }
}



class SoundFileView:NibLoadingView{
    var viewModel:SoundFileViewModel!{
        didSet{
            soundFileWaehlenView.reactive.isHidden  <~ viewModel.soundFileData.producer.map{$0 != nil}
            mainStackView.reactive.isHidden         <~ viewModel.soundFileData.producer.map{$0 == nil}
            titleLabel.reactive.text                <~ viewModel.soundFileData.producer.map{$0?.title}
            durationLabel.reactive.text             <~ viewModel.soundFileData.producer.map{$0?.duration.hhmmss}
            mettaDurationLabel.reactive.text        <~ viewModel.soundFileData.producer.map{$0?.mettaDuration.hhmmss}
            soundFileDownloadView.reactive.isHidden <~ viewModel.soundFileData.producer.map{$0?.isDownloaded == true}
            
            
            sliderForPlayer.reactive.value          <~ viewModel.sliderValue
            sliderForPlayer.reactive.maximumValue   <~ viewModel.sliderMax
            viewModel.currentTimeSetter             <~ sliderForPlayer.reactive.values.map{TimeInterval($0)}
            spielZeitLabel.reactive.text            <~ viewModel.spielZeitText
            restZeitLabel.reactive.text             <~ viewModel.restZeitText
 
            viewModel.soundFileDownloadVerdeck.signal.observeValues{[weak self] progress in self?.setProgress(progress) }
            
            layer.borderColor   = standardRahmenFarbe.cgColor
            layer.borderWidth   = standardBorderWidth
            layer.cornerRadius  = standardCornerRadius
            clipsToBounds       = true
            
            viewModel.playSoundButtonAction <~ playButton.reactive.controlEvents(.touchUpInside).map{_ in Void()}
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
