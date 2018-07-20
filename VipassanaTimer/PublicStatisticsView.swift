//
//  PublicStatistics.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 03.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//
import UIKit

//✅
@IBDesignable class PublicStatisticsView:NibLoadingView{
    var publicStatistics:PublicStatistics?{
        didSet{
            //in
            gesamtDauerLabel.text           = publicStatistics?.gesamtDauer ?? "0"
            durchSchnittProTagLabel.text    = publicStatistics?.durchSchnittProTag ?? "0"
            kursTageLabel.text              = publicStatistics?.kursTage ?? "0"
            isHidden                        = publicStatistics == nil
            
            //design
            self.setStandardDesign()
        }
    }
    
    //IBOutlets
    @IBOutlet weak private var gesamtDauerLabel: UILabel!
    @IBOutlet weak private var durchSchnittProTagLabel: UILabel!
    @IBOutlet weak private var kursTageLabel: UILabel!
}

