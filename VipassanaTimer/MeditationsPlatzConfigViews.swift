//
//  MeditationsPlatzConfigView.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 05.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//
import UIKit
import ReactiveSwift

//✅
class MeditationsPlatzConfigVC:DesignTableViewControllerPortrait{
    var viewModel:MeditationsPlatzConfigViewModel!
    
    //IBOutlet
    @IBOutlet weak var meditationsPlatzConfigView: MeditationsPlatzConfigView!
    
    //IBAction
    @IBAction func doneAction(_ sender: UIBarButtonItem) { dismiss(animated: true, completion: nil)  }
    
    // VC LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        meditationsPlatzConfigView.viewModel = viewModel
    }
}

//✅
class MeditationsPlatzConfigViewModel{
    let meditationsPlatzTitle = MutableProperty<String?>(nil)
    init(meditationsPlatzTitle:MutableProperty<String?>){
        self.meditationsPlatzTitle.value = meditationsPlatzTitle.value
        meditationsPlatzTitle   <~ self.meditationsPlatzTitle.signal
    }
    
    //ViewModels
    func getViewModelForMeditationsPlatzView() -> MeditationsPlatzViewModel{ return MeditationsPlatzViewModel(meditationsPlatzTitle: meditationsPlatzTitle) }
    
    deinit { print("deinit MeditationsPlatzConfigViewModel") }
}
//✅
@IBDesignable class MeditationsPlatzConfigView:NibLoadingView{
    var viewModel:MeditationsPlatzConfigViewModel!{
        didSet{
            platzMal3.viewModel = viewModel.getViewModelForMeditationsPlatzView()
            platzMal4.viewModel = viewModel.getViewModelForMeditationsPlatzView()
            platzMal5.viewModel = viewModel.getViewModelForMeditationsPlatzView()
            viewModel.meditationsPlatzTitle <~ textFeld.reactive.continuousTextValues.map{ ($0 == nil || $0?.isEmpty == true)  ? "?" : $0 }
        }
    }
    //IBOutlet
    @IBOutlet weak var platzMal3: MeditationsPlatzView!
    @IBOutlet weak var platzMal4: MeditationsPlatzView!
    @IBOutlet weak var platzMal5: MeditationsPlatzView!
    @IBOutlet weak var textFeld: UITextField!
}
