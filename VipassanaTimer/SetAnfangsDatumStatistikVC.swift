//
//  SetAnfangsDatumStatistikVC.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 06.02.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import UIKit

class SetAnfangsDatumStatistikVC: UIViewController {
    @IBOutlet weak var anfangsDatumLabel: UILabel!{
        didSet{
            let appConfig = AppConfig.get()
            if let date = appConfig?.startDatumStatistik{
                anfangsDatumLabel.text  = (date as Date).string("dd.MM.yyyy")
            }else{
                if let startErsteMeditation = Meditation.getAll().first?.start{
                    anfangsDatumLabel.text  = (startErsteMeditation as Date).string("dd.MM.yyyy")
                }else{
                    anfangsDatumLabel.text  = Date().string("dd.MM.yyyy")
                }
            }
        }
    }
    @IBOutlet weak var datePicker: UIDatePicker!{
        didSet{
            let appConfig = AppConfig.get()
            if let date = appConfig?.startDatumStatistik{
                datePicker?.date         = date as Date
            }else{
                if let startErsteMeditation = Meditation.getAll().first?.start{
                    datePicker?.date         = startErsteMeditation as Date
                }else{
                    datePicker?.date         = Date()
                }
            }

        }
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        anfangsDatumLabel?.text         = sender.date.string("dd.MM.yyyy")
        let appConfig                   = AppConfig.get()
        appConfig?.startDatumStatistik  = sender.date as NSDate?
        zurueckSetzenButton.isHidden    = false
    }
    
    
    @IBOutlet weak var zurueckSetzenButton: UIButton!{
        didSet{
            let appConfig                   = AppConfig.get()
            zurueckSetzenButton.isHidden    = appConfig?.startDatumStatistik == nil ? true : false
        }
    }
    @IBAction func zuruecksetzenButtonPressed(_ sender: UIButton) {
        let appConfig                   = AppConfig.get()
        appConfig?.startDatumStatistik  = nil
        
        if let startErsteMeditation = Meditation.getAll().first?.start{
            anfangsDatumLabel.text  = (startErsteMeditation as Date).string("dd.MM.yyyy")
            datePicker.date         = startErsteMeditation as Date
        }else{
            anfangsDatumLabel.text  = Date().string("dd.MM.yyyy")
            datePicker.date         = Date()
        }
        zurueckSetzenButton.isHidden    = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        datePicker.setValue(DesignPatterns.mocha, forKey: "textColor")
    }
}
