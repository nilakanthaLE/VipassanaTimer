//
//  KursTableCell.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 11.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit

//✅
//KursCell
@IBDesignable class KursTableCell: UITableViewCell {
    var kurs:Kurs!{
        didSet{
            kursTableCellView.kurs  = kurs
            accessoryType           = .detailButton
            tintColor               = standardSchriftFarbe
            backgroundColor         = .clear
        }
    }
    @IBOutlet weak var kursTableCellView:KursTableCellView!
}

//✅
//KursCell ContentView
@IBDesignable class KursTableCellView:NibLoadingView{
    var kurs:Kurs!{
        didSet{
            kursTitleLabel.text     = kurs.name
            kursDatumLabel.text     = kurs.startDate.string("dd.MM.yyyy") + " - " + kurs.endDate.string("dd.MM.yyyy")
            kursStatistikLabel.text = kurs.gesamtDauerMeditationen.hhmm
            lehrerName.text         = kurs.teacher
            
            self.setStandardDesign()
        }
    }
    //Outlets
    @IBOutlet private weak var kursTitleLabel: UILabel!
    @IBOutlet private weak var kursDatumLabel: UILabel!
    @IBOutlet private weak var kursStatistikLabel: UILabel!
    @IBOutlet private weak var lehrerName: UILabel!
    
    deinit { print("deinit KursTableCellView") }
    override var intrinsicContentSize: CGSize{ return CGSize(width: UIViewNoIntrinsicMetric, height: 80) }
}

