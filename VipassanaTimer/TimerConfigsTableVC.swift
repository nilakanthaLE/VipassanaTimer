//
//  TimerConfigsTableVC.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 05.01.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import UIKit

class TimerConfigsTableVC: UITableViewController {

    private var timerConfigs = TimerConfig.getAll() { didSet{tableView.reloadData() } }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timerConfigs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TimerConfigTableViewCell
        cell.timerConfigView.timerConfig            = timerConfigs[indexPath.row]
        cell.timerConfigView.rangeSlider.isEnabled  = false
        cell.backgroundColor                        = UIColor.clear
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timerConfigs = TimerConfig.getAll()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DesignPatterns.mainBackground
    }
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: "editTimer", sender: timerConfigs[indexPath.row])
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let mediStart = navigationController?.viewControllers[0] as? MeditationStartenVC{
            timerConfigs[indexPath.row].setActive()
            mediStart.timerConfig                   = timerConfigs[indexPath.row]
        }
        else if let mediAnpassen = navigationController?.viewControllers[(navigationController?.viewControllers.count ?? 0) - 2] as? EditMeditationVC{
            mediAnpassen.timerConfig                = timerConfigs[indexPath.row]
        }
        _ = navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editTimer"{
            (segue.destination.contentViewController as? ConfigureTimerVC)?.timerConfig     = sender as? TimerConfig
        }
        else{
            (segue.destination.contentViewController as? ConfigureTimerVC)?.timerConfig     = TimerConfig.new(dauerAnapana: 5 * 60, dauerVipassana: 50 * 60, dauerMetta: 5 * 60, mettaOpenEnd: false)
        }
    }

    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete{
            timerConfigs[indexPath.row].delete()
            timerConfigs = TimerConfig.getAll()
        }
    }
}
