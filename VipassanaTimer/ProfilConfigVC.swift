//
//  ProfilConfigVC.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 05.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift

class ProfilConfigVCViewModel{
    
    let model:ProfilConfigModel
    init(model:ProfilConfigModel){
        print("init ProfilConfigVCViewModel")
        self.model  = model
    }
    func getViewModelForProfilConfigView()->ProfilConfigViewModel{
        return ProfilConfigViewModel(model: model)
    }
    func getViewModelForFlaggeWahlVC() -> FlaggeWahlVCViewModel{
        return FlaggeWahlVCViewModel(flagge: model.flagge)
    }
    func getViewModelForMeditationsPlatzConfigView() -> MeditationsPlatzConfigViewModel{
        return MeditationsPlatzConfigViewModel(meditationsPlatzTitle: model.meditationsPlatzTitle)
    }
    func getViewModelForProfilPublicVorschauVC() -> PublicMeditationInfoViewModel{
        return PublicMeditationInfoViewModel(model: PublicMeditationInfoModel(publicMeditation: PublicMeditation()))
    }
    deinit {
        print("deinit ProfilConfigVCViewModel")
    }
}

class ProfilConfigVC: UIViewController {
    var viewModel:ProfilConfigVCViewModel = ProfilConfigVCViewModel(model: ProfilConfigModel())
    @IBOutlet weak var profilConfigView: ProfilConfigView!{ didSet{  profilConfigView.viewModel = viewModel.getViewModelForProfilConfigView()  }  }
    
    override func viewDidLoad() {
        print("ProfilConfigVC viewDidLoad")
        super.viewDidLoad()
        view.backgroundColor            = UIColor(patternImage: #imageLiteral(resourceName: "backGroundImage.png"))
        navigationController?.navigationBar.setDesignPattern()
        
        profilConfigView.viewModel.flaggeButtonPressed.signal.observe{[weak self] _ in
            self?.performSegue(withIdentifier: "flaggeWahl", sender: nil)
        }
        profilConfigView.viewModel.meditationsPlatzTapped.signal.observe{[weak self] _ in
            self?.performSegue(withIdentifier: "sitzplatzConfig", sender: nil)
        }
    }
    
    @IBAction func zurueckButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination.contentViewController as? FlaggeWahlVC)?.viewModel               = viewModel.getViewModelForFlaggeWahlVC()
        (segue.destination.contentViewController as? MeditationsPlatzConfigVC)?.viewModel   = viewModel.getViewModelForMeditationsPlatzConfigView()
        (segue.destination.contentViewController as? ProfilPublicVorschauVC)?.viewModel     = viewModel.getViewModelForProfilPublicVorschauVC()
    }
}




