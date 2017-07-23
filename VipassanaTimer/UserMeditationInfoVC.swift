//
//  UserMeditationInfoVC.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 20.03.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import UIKit

class UserMeditationInfoVC: UIViewController {
    var userIsFriend = false
    var activeMeditation:ActiveMeditationInFB?{
        didSet{
            guard let activeMeditation = activeMeditation else {return}
            meditationsDatumLabel?.text         = activeMeditation.start?.string("dd.MM.yyyy")
            meditationStartLabel?.text          = startString
            meditationsDauerLabel?.text         = dauerString
            meditationsEndeLabel?.text          = endeString
            meditierenderSpitznameLabel?.text   = activeMeditation.spitznameString
            
            userIsFriend = activeMeditation.freundesStatus == .granted
            
            if let statisticTag = activeMeditation.durchSchnittProTag,
                let statisticGesamtDauer = activeMeditation.gesamtDauerStatistik,
                let kursTage = activeMeditation.kursTage,
                userIsFriend{
                
                durchSchnitProTagDauerLabel?.isHidden       = false
                durchSchnittProTagTextLabel?.isHidden       = false
                gesamtDauerDataLabel?.isHidden              = false
                gesamtDauerTextLabel?.isHidden              = false
                kursTageDataLabel?.isHidden                 = false
                kursTageTextLabel?.isHidden                 = false
                durchSchnitProTagDauerLabel?.text           = statisticTag
                gesamtDauerDataLabel?.text                  = statisticGesamtDauer
                kursTageDataLabel?.text                     = kursTage
            }else {
                durchSchnitProTagDauerLabel?.isHidden       = true
                durchSchnittProTagTextLabel?.isHidden       = true
                gesamtDauerDataLabel?.isHidden              = true
                gesamtDauerTextLabel?.isHidden              = true
                kursTageDataLabel?.isHidden                 = true
                kursTageTextLabel?.isHidden                 = true
            }
            
            freundschaftsanfrageButton?.isHidden = activeMeditation.canAskForFriendShip == false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DesignPatterns.mainBackground
    }
    @IBOutlet weak var overlayView: UIView!{
        didSet{
            overlayView.setControlDesignPatterns()
        }
    }
    @IBOutlet weak var freundschaftsanfrageButton: UIButton!{
        didSet{
            let title = NSLocalizedString("freundschaftsanfrageButton", comment: "freundschaftsanfrageButton")
            freundschaftsanfrageButton.setTitle(title, for: .normal)
            freundschaftsanfrageButton?.isHidden = activeMeditation?.canAskForFriendShip != true
        }
    }
    @IBAction func freundschaftsanfrageButtonPressed(_ sender: UIButton) {
        freundschaftsanfrageButton.isHidden = activeMeditation?.askForFriendship() == true
    }
    
    @IBOutlet weak var meditationsDatumLabel: UILabel!
        {didSet{meditationsDatumLabel.text = activeMeditation?.start?.string("dd.MM.yyyy")}}
    @IBOutlet weak var meditationStartLabel: UILabel!
        {didSet{meditationStartLabel.text  = startString}}
    @IBOutlet weak var meditationsDauerLabel: UILabel!
        {didSet{meditationsDauerLabel.text = dauerString}}
    @IBOutlet weak var meditationsEndeLabel: UILabel!
        {didSet{meditationsEndeLabel.text  = endeString}}
    @IBOutlet weak var meditierenderSpitznameLabel: UILabel!
        {didSet{meditierenderSpitznameLabel.text  = activeMeditation?.spitznameString ?? "?"}}
    
    var dauerString:String{
        guard let dauer = activeMeditation?.gesamtDauer else {return ""}
        return dauer.hhmmString + mettaOpenEndString
    }
    var startString:String{
        guard let start = activeMeditation?.start else {return ""}
        return start.string("HH:mm")
    }
    var endeString:String{
        guard let ende = activeMeditation?.ende else {return ""}
        return ende.string("HH:mm") + mettaOpenEndString
    }
    var mettaOpenEndString:String{
        guard activeMeditation?.mettaOpenEnd == true else {return ""}
        return "+ Metta"
    }
    
    @IBOutlet weak var durchSchnittProTagTextLabel: UILabel! {
        didSet{
            if (activeMeditation?.durchSchnittProTag?.isEmpty ?? true) || !userIsFriend{
                durchSchnittProTagTextLabel?.isHidden    = true
            }else{
                durchSchnittProTagTextLabel?.isHidden    = false
            }
        }
    }
    @IBOutlet weak var durchSchnitProTagDauerLabel: UILabel!{
        didSet{
            if let statisticTag = activeMeditation?.durchSchnittProTag, userIsFriend{
                durchSchnitProTagDauerLabel?.isHidden    = false
                durchSchnitProTagDauerLabel?.text        = statisticTag
            }else{
                durchSchnitProTagDauerLabel?.isHidden    = true
            }
        }
    }
    
    @IBOutlet weak var gesamtDauerTextLabel: UILabel!{
        didSet{
            if (activeMeditation?.gesamtDauerStatistik?.isEmpty ?? true) || !userIsFriend{
                gesamtDauerTextLabel?.isHidden    = true
            }else{
                gesamtDauerTextLabel?.isHidden    = false
            }
        }
    }
    @IBOutlet weak var gesamtDauerDataLabel: UILabel!{
        didSet{
            if let statisticGesamtDauer = activeMeditation?.gesamtDauerStatistik,userIsFriend{
                gesamtDauerDataLabel?.isHidden    = false
                gesamtDauerDataLabel?.text        = statisticGesamtDauer
            }else{
                gesamtDauerDataLabel?.isHidden    = true
            }
        }
    }
    @IBOutlet weak var kursTageTextLabel: UILabel!{
        didSet{
            if (activeMeditation?.kursTage?.isEmpty ?? true) || !userIsFriend{
                kursTageTextLabel?.isHidden    = true
            }else{
                kursTageTextLabel?.isHidden    = false
            }
        }
    }
    
    @IBOutlet weak var kursTageDataLabel: UILabel!{
        didSet{
            if let kursTage = activeMeditation?.kursTage,userIsFriend{
                kursTageDataLabel?.isHidden    = false
                kursTageDataLabel?.text        = kursTage
            }else{
                kursTageDataLabel?.isHidden    = true
            }
        }
    }
}
