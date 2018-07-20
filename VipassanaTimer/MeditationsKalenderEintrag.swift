//
//  MeditationsKalenderEintrag.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 19.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
//✅
//View eines Kalendereintrags
// zeigt einen Balken mit Anteilen von Anapana, Vipassana, Metta
class MeditationsKalenderEintrag: NibLoadingView{
    var meditation:Meditation!{
        didSet{
            let multiplierAnapana       = CGFloat(meditation!.dauerAnapana ) / CGFloat(meditation.gesamtDauer)
            let multiplierVipassana     = CGFloat(meditation!.dauerVipassana) / CGFloat(meditation.gesamtDauer)
            
            anapanaView.superview?.removeConstraints([anteilAnapanaConstraint,anteilVipassanaConstraint])
            anteilAnapanaConstraint     = NSLayoutConstraint(item: anapanaView, attribute: .width, relatedBy: .equal, toItem: anapanaView.superview, attribute: .width, multiplier: multiplierAnapana, constant: 0)
            anteilVipassanaConstraint   = NSLayoutConstraint(item: vipassanaView, attribute: .width, relatedBy: .equal, toItem: vipassanaView.superview, attribute: .width, multiplier: multiplierVipassana, constant: 0)
            anapanaView.superview?.addConstraints([anteilAnapanaConstraint,anteilVipassanaConstraint])
        }
    }
    @IBOutlet weak var anteilVipassanaConstraint: NSLayoutConstraint!
    @IBOutlet weak var anteilAnapanaConstraint: NSLayoutConstraint!
    @IBOutlet weak var anapanaView: UIView!
    @IBOutlet weak var vipassanaView: UIView!
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) { meditationsKalenderEintragPressed.value = meditation  }
}
