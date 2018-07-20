//
//  SoundFileViewModel.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 05.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import ReactiveSwift

//✅
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
