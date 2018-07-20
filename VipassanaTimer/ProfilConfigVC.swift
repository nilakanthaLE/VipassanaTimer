//
//  ProfilConfigVC.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 05.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit

//✅
class ProfilConfigVC: DesignViewControllerPortrait{
    let model:ProfilConfigModel = ProfilConfigModel()
    
    //IBOutlet
    @IBOutlet weak var profilConfigView: ProfilConfigView!          { didSet{  profilConfigView.viewModel = ProfilConfigViewModel(model: model)  }  }

    //IBAction
    @IBAction func zurueckButtonPressed(_ sender: UIBarButtonItem)  { dismiss(animated: true, completion: nil) }
    
    //VC LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilConfigView.viewModel.flaggeButtonPressed.signal.observe       {[weak self] _ in self?.performSegue(withIdentifier: "flaggeWahl", sender: nil) }
        profilConfigView.viewModel.meditationsPlatzTapped.signal.observe    {[weak self] _ in self?.performSegue(withIdentifier: "sitzplatzConfig", sender: nil) }
    }
    
    //segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination.contentViewController as? FlaggeWahlVC)?.viewModel               = FlaggeWahlViewModel(flag: model.flagge)
        (segue.destination.contentViewController as? MeditationsPlatzConfigVC)?.viewModel   = MeditationsPlatzConfigViewModel(meditationsPlatzTitle: model.meditationsPlatzTitle)
        (segue.destination.contentViewController as? ProfilPublicVorschauVC)?.viewModel     = PublicMeditationInfoViewModel(publicMeditation: PublicMeditation())
    }
}




