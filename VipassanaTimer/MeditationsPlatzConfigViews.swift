//
//  MeditationsPlatzConfigView.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 05.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift

class MeditationsPlatzConfigViewModel{
    let meditationsPlatzTitle = MutableProperty<String?>(nil)
    init(meditationsPlatzTitle:MutableProperty<String?>){
        self.meditationsPlatzTitle.value = meditationsPlatzTitle.value
        meditationsPlatzTitle   <~ self.meditationsPlatzTitle.signal
    }
    
    func getViewModelForMeditationsPlatzView() -> MeditationsPlatzViewModel{
        return MeditationsPlatzViewModel(meditationsPlatzTitle: meditationsPlatzTitle)
    }
    
    deinit { print("deinit MeditationsPlatzConfigViewModel") }
}



class MeditationsPlatzConfigVC:UIViewController{
    var viewModel:MeditationsPlatzConfigViewModel!
    @IBOutlet weak var meditationsPlatzConfigView: MeditationsPlatzConfigView!{
        didSet{ meditationsPlatzConfigView.viewModel = viewModel }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor            = UIColor(patternImage: #imageLiteral(resourceName: "backGroundImage.png"))
        navigationController?.navigationBar.setDesignPattern()
    }
    @IBAction func doneAction(_ sender: UIBarButtonItem) { dismiss(animated: true, completion: nil)  }
}

class MeditationsPlatzConfigView:NibLoadingView{
    var viewModel:MeditationsPlatzConfigViewModel!{
        didSet{
            platzMal3.viewModel = viewModel.getViewModelForMeditationsPlatzView()
            platzMal4.viewModel = viewModel.getViewModelForMeditationsPlatzView()
            platzMal5.viewModel = viewModel.getViewModelForMeditationsPlatzView()
            viewModel.meditationsPlatzTitle <~ textFeld.reactive.continuousTextValues.map{ ($0 == nil || $0?.isEmpty == true)  ? "?" : $0 }
        }
    }
    @IBOutlet weak var platzMal3: MeditationsPlatzView!
    @IBOutlet weak var platzMal4: MeditationsPlatzView!
    @IBOutlet weak var platzMal5: MeditationsPlatzView!
    
    @IBOutlet weak var textFeld: UITextField!
}
