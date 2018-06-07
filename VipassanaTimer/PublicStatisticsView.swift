//
//  PublicStatistics.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 03.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class PublicStatisticsView:NibLoadingView{
    var publicStatistics:PublicStatistics?{
        didSet{
            gesamtDauerLabel.text           = publicStatistics?.gesamtDauer ?? "0"
            durchSchnittProTagLabel.text    = publicStatistics?.durchSchnittProTag ?? "0"
            kursTageLabel.text              = publicStatistics?.kursTage ?? "0"
            
            layer.borderColor   = standardRahmenFarbe.cgColor
            layer.borderWidth   = standardBorderWidth
            layer.cornerRadius  = standardCornerRadius
            clipsToBounds       = true
            isHidden            = publicStatistics == nil
        }
    }
  
    
    @IBOutlet weak private var gesamtDauerLabel: UILabel!
    @IBOutlet weak private var durchSchnittProTagLabel: UILabel!
    @IBOutlet weak private var kursTageLabel: UILabel!
}

