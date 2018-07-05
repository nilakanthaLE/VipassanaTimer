//
//  AudioPlayer.swift
//  Vipassana
//
//  Created by Matthias Pochmann on 05.05.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import AVFoundation
import ReactiveSwift
import Result




fileprivate var timer:Timer?
fileprivate var player: AVAudioPlayer?
class AudioPlayer{
    
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
        catch let error as NSError {
            print(error.description)
        }
    }
    init(){ print("init AudioPlayer")}
    deinit {
        timer?.invalidate()
        timer = nil
        player = nil
        print("deinit AudioPlayer")
    }
    
    
//var timer:Timer?
//    let currentTime = MutableProperty<TimeInterval>(0)
//    func playSound(url:URL?,currentTimeSet:MutableProperty<TimeInterval>) -> (duration:TimeInterval,currentTime:MutableProperty<TimeInterval>)?{
//        guard let url = url else {return nil}
//        
//        timer?.invalidate()
//        timer = nil
//        player?.stop()
//        
//        weak var _timer     = timer
//        weak var _player    = player
//        do{
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
//            try AVAudioSession.sharedInstance().setActive(true)
//            
//            _player = try AVAudioPlayer(contentsOf: url)
//            _player?.setVolume(0.3, fadeDuration: TimeInterval(0))
//            _player?.prepareToPlay()
//            _player?.play()
//            
//            _timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {[weak self] _ in
//                self?.currentTime.value = _player?.currentTime ?? 0
//            }
//            
//            currentTimeSet.signal.observeValues { _player?.currentTime = $0 }
//            return (duration:player?.duration ?? 0,currentTime:currentTime)
//        }
//        catch let error as NSError {
//            print(error.description)
//            return nil
//        }
//    }
//    func stopPlaying(){
//        print("stopPlaying")
//        timer?.invalidate()
//        timer = nil
//        player?.stop()
//    }
}




