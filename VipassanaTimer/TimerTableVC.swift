//
//  TimerTableVC.swift
//  Vipassana
//
//  Created by Matthias Pochmann on 03.05.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift

class TimerTableVCModel{
    let updateTable = MutableProperty<Void>(Void())
    var numberOfRows:Int  {return  model.timerDatas.value.count }
    
    
    func selectMeditationsTimer(indexPath:IndexPath){
        print("selectMeditationsTimer klangschalen: \(model.timerDatas.value[indexPath.row].soundSchalenAreOn)")
        model.gewaehlterTimerFuerMeditation.value   = model.timerDatas.value[indexPath.row]
    }
    func getViewModelForCell(indexPath:IndexPath) -> TimerAnzeigeViewModel{
        return TimerAnzeigeViewModel(model: TimerAnzeigeModel(timerData: model.timerDatas.value[indexPath.row]))
    }
    func deleteTimer(at row:Int){
        model.removeTimerData(at: row)
    }
    
    let model:MeineTimerModel
    init(model:MeineTimerModel){
        print("init TimerTableVCModel")
        self.model          = model
        updateTable         <~ model.timerDatas.signal.map{_ in Void()}
    }
    
 
    func getTimerSettingsViewControllerModel(row:Int?) -> TimerSettingsViewControllerModel{
        let timerData:TimerData = {
            guard let row = row else {return model.addTimerData()}
            return model.timerDatas.value[row]
        }()
        print("getTimerSettingsViewControllerModel klangschalen: \(timerData.soundSchalenAreOn)")
        return TimerSettingsViewControllerModel(timerData: timerData)
    }
    
    deinit { print("deinit TimerTableVCModel")  }
}

class TimerTableVC: UITableViewController {
    var viewModel:TimerTableVCModel!
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return UIInterfaceOrientationMask.portrait  }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight             = UITableViewAutomaticDimension
        tableView.estimatedRowHeight    = 44
        view.backgroundColor            = UIColor(patternImage: #imageLiteral(resourceName: "backGroundImage.png"))
        
        viewModel.updateTable.signal.observe{ [weak self] _ in self?.tableView.reloadData() }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int                                { return 1 }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int    { return viewModel.numberOfRows }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        (cell.contentView.subviews.first as? TimerAnzeigeView)?.viewModel = viewModel.getViewModelForCell(indexPath: indexPath)
        cell.selectionStyle = .none
        cell.contentView.subviews.first?.setNeedsLayout()
        cell.contentView.subviews.first?.layoutIfNeeded()
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectMeditationsTimer(indexPath: indexPath)
        navigationController?.popViewController(animated: true)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //TimerSettings
        guard let destination = segue.destination.contentViewController as? TimerSettingsVC else {return}
        // falls segue per klick auf accessoryButton --> row
        // sonst per addButton --> row = nil
        var row:Int?{
            guard let sender = sender as? UITableViewCell else {return nil}
            return tableView.indexPath(for: sender)?.row
        }
        destination.viewModel   = viewModel.getTimerSettingsViewControllerModel(row: row)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{ viewModel.deleteTimer(at: indexPath.row)  }
    }
}

extension UIViewController{
    var contentViewController:UIViewController {
        if let navCon = self as? UINavigationController{ return navCon.visibleViewController ?? navCon
        }else{ return self  }
    }
}
