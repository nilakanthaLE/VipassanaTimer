//
//  AudioPlayer.swift
//  Vipassana
//
//  Created by Matthias Pochmann on 05.05.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import AVFoundation
import ReactiveSwift
import Result

//✅
// Klangschalen Player
class AudioPlayer{
    var player: AVAudioPlayer?
    func playKlangSchale(){
        //Preparation to play
        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            if let klangSchaleURL = Bundle.main.url(forResource: "tibetan-bell", withExtension: "wav")  { player = try AVAudioPlayer(contentsOf: klangSchaleURL) }
            guard let player = player else { return }
            player.setVolume(0.3, fadeDuration: TimeInterval(0))
            player.prepareToPlay()
            player.play()
        }
        catch let error as NSError { print(error.description) }
    }
    deinit  { player = nil }
}

//✅
//Sound File Player
let soundFileAudioPlayer = SoundFileAudioPlayer()
class SoundFileAudioPlayer{
    let soundFileData       = MutableProperty<SoundFileData?>(nil)  //wird on außen gesetzt
    let currentTimeSignal   = MutableProperty<TimeInterval>(0)      //sendet Werte
    let currentTimeSet      = MutableProperty<TimeInterval>(0)
    let dauer               = MutableProperty<TimeInterval>(0)
    let restZeit            = MutableProperty<TimeInterval>(0)
    let anteilAnGesamt      = MutableProperty<Double>(0)
    
    //init
    private let ticker = SignalProducer.timer(interval: DispatchTimeInterval.seconds(1), on: QueueScheduler.main)
    fileprivate init(){
        //SoundFile setzen -> Player starten oder stoppen
        soundFileData.signal.observeValues(){[weak self] soundFile in self?.startStopPlayer(soundFile: soundFile) }
        
        //Ticker
        ticker.start()
        dauer               <~ ticker.map{[weak self] _ in self?.player?.duration}.filterMap{$0}
        currentTimeSignal   <~ ticker.map{[weak self] _ in self?.player?.currentTime}.filterMap{$0}
        restZeit            <~ ticker.map{[weak self] _ in self?._restZeit}.filterMap{$0}
        anteilAnGesamt      <~ ticker.map{[weak self] _ in self?._anteilAnGesamt}.filterMap{$0}
        
        //current Time setzen
        currentTimeSet.signal.observeValues{ [weak self] timeSet in self?.player?.currentTime = timeSet }
    }
    
    //player
    private var player:AVAudioPlayer?
    private var pauseCurrentTime:TimeInterval = 0
    
    //Pause + wieder starten
    func pause(){
        pauseCurrentTime = player?.currentTime ?? 0
        player?.stop()
    }
    func startNachPause(){
        startStopPlayer(soundFile: soundFileData.value, at: pauseCurrentTime)
        pauseCurrentTime = 0
    }
    
    //den Player an einer bestimmten Stelle starten
    // falls kein SoundFileData übergeben wird, Player stoppen
    private func startStopPlayer(soundFile:SoundFileData?,at position:TimeInterval = 0){
        player?.stop()
        player = nil
        
        guard let soundFileURL = soundFile?.loacalSoundfileURL else { return }  //nur stop
        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: soundFileURL)
            player?.setVolume(1, fadeDuration: TimeInterval(0))
            player?.prepareToPlay()
            player?.currentTime = position
            player?.play()
        }
        catch let error as NSError {
            print(error.description)
            return
        }
    }
    
    //helper
    private var _anteilAnGesamt:Double{
        guard dauer.value != 0 else {return 0}
        return (player?.currentTime ?? 0) / dauer.value
    }
    private var _restZeit:TimeInterval{
        return dauer.value - (player?.currentTime ?? 0)
    }
}
