//
//  SoundFileView.swift
//  Vipassana
//
//  Created by Matthias Pochmann on 07.05.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift

//✅
@IBDesignable class SoundFileView:NibLoadingView{
    var viewModel:SoundFileViewModel!{
        didSet{
            soundFileWaehlenView.reactive.isHidden  <~ viewModel.soundFileData.producer.map{$0 != nil}
            mainStackView.reactive.isHidden         <~ viewModel.soundFileData.producer.map{$0 == nil}
            titleLabel.reactive.text                <~ viewModel.soundFileData.producer.map{$0?.title}
            durationLabel.reactive.text             <~ viewModel.soundFileData.producer.map{$0?.duration.hhmmss}
            mettaDurationLabel.reactive.text        <~ viewModel.soundFileData.producer.map{$0?.mettaDuration.hhmmss}
            soundFileDownloadView.reactive.isHidden <~ viewModel.soundFileData.producer.map{$0 == nil || $0?.isDownloaded == true}
            
            //AudioPlayer
            sliderForPlayer.reactive.value          <~ viewModel.sliderValue
            sliderForPlayer.reactive.maximumValue   <~ viewModel.sliderMax.producer
            spielZeitLabel.reactive.text            <~ viewModel.spielZeitText
            restZeitLabel.reactive.text             <~ viewModel.restZeitText
            viewModel.currentTimeSetter             <~ sliderForPlayer.reactive.values.map{TimeInterval($0)}
            viewModel.playSoundButtonAction         <~ playButton.reactive.controlEvents(.touchUpInside).map{_ in Void()}
            
            //DownloadProgress
            viewModel.soundFileDownloadVerdeck.signal.observeValues{[weak self] progress in self?.setProgress(progress) }
            
            self.setStandardDesign()
        }
    }
    
    //IBOutlets
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
    
    //Intrinsic Content Size
    override var intrinsicContentSize: CGSize       { return (CGSize(width: UIViewNoIntrinsicMetric, height: 129)) }
    
    //helper
    private func setProgress(_ progress:Double){
        guard !progress.isNaN else {return}
        soundFildeDownloadViewLeadingConstraint.constant = view.frame.width * CGFloat(progress)
    }
    
    deinit { print("deinit SoundFileView") }
}
