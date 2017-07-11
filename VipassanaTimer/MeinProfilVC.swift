//
//  MeinProfilVC.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 09.03.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import UIKit

class MeinProfilVC: UIViewController {

    let meditierender = Meditierender.get()
    @IBOutlet weak var spitzNameTextField: UITextField!
        { didSet{
            spitzNameTextField.text = meditierender?.nickName
            if !(spitzNameTextField.text?.isEmpty ?? true){
                title = spitzNameTextField.text
            }
        }
    }
    
    @IBOutlet weak var statistikSichtbarkeitSwitch: UISwitch!{
         didSet{statistikSichtbarkeitSwitch.isOn = meditierender?.statistikSichtbarkeit == 1 }}
    @IBOutlet weak var sichtbarkeitGlobalSwitch: UISwitch!
        { didSet{sichtbarkeitGlobalSwitch.isOn = meditierender?.nickNameSichtbarkeit == 2 }}
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard !(meditierender?.nickName?.isEmpty ?? true) else {return}
        if meditierender?.nickNameSichtbarkeit != (sichtbarkeitGlobalSwitch.isOn ? 2 : 0){
            meditierender?.nickNameSichtbarkeit     = sichtbarkeitGlobalSwitch.isOn ? 2 : 0
        }
        if meditierender?.statistikSichtbarkeit != (statistikSichtbarkeitSwitch.isOn ? 1 : 0){
            meditierender?.statistikSichtbarkeit = statistikSichtbarkeitSwitch.isOn ? 1 : 0
            
            meditierender?.cloudNeedsUpdate = true
            Singleton.sharedInstance.myCloudKit?.updateNow()
        }
    }
    
    @IBOutlet weak var FreundeStatistikErlaubnisText: UILabel!{
        didSet{
            let messageText = NSMutableAttributedString(
                string: NSLocalizedString("FreundeStatistikErlaubt1", comment: "FreundeStatistikErlaubt1"),
                attributes: [
                    NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16),
                    NSAttributedStringKey.foregroundColor : DesignPatterns.mocha
                ]
            )
            let messageText2 = NSMutableAttributedString(
                
                string: NSLocalizedString("FreundeStatistikErlaubt2", comment: "FreundeStatistikErlaubt2"),
                attributes: [
                    NSAttributedStringKey.font : UIFont.systemFont(ofSize: 11),
                    NSAttributedStringKey.foregroundColor : DesignPatterns.mocha
                ]
            )
            messageText.append(messageText2)
            let messageText3 = NSMutableAttributedString(
                
                string: NSLocalizedString("FreundeStatistikErlaubt3", comment: "FreundeStatistikErlaubt3"),
                attributes: [
                    NSAttributedStringKey.font :  UIFont.systemFont(ofSize: 16),
                    NSAttributedStringKey.foregroundColor : DesignPatterns.mocha
                ]
            )
            messageText.append(messageText3)
            FreundeStatistikErlaubnisText.attributedText = messageText
        }
    }
    @IBOutlet weak var pruefenButton: UIButton!
    @IBAction func pruefenButtonPressed() {
        guard spitzNameTextField.text?.isEmpty == false else {return}
        MyCloudKit.fetchUser(spitzNameTextField.text!)
    }
    
    @IBAction func textFieldEditing(_ sender: UITextField) {
        nickNamePruefungsErgebnisLabel.isHidden = true
        pruefenButton.isHidden  = sender.text?.isEmpty ?? true
    }
    @IBOutlet weak var nickNamePruefungsErgebnisLabel: UILabel!
    
    @objc private func userSearchErgebnis(_ notification:Notification){
        nickNamePruefungsErgebnisLabel.isHidden = false
        let user = notification.userInfo?["ckMeditierender"] as? CKMeditierender
        if  filter(user) != nil{
            nickNamePruefungsErgebnisLabel.text = "'\(spitzNameTextField.text ?? "???")'" + NSLocalizedString("NicknameVergeben", comment: "NicknameVergeben")
        }else{
            meditierender?.nickName                 = spitzNameTextField.text
            meditierender?.cloudNeedsUpdate         = true
            Singleton.sharedInstance.myCloudKit?.updateNow()
            nickNamePruefungsErgebnisLabel.text = "'\(spitzNameTextField.text ?? "???")'" + NSLocalizedString("NicknameErlaubt", comment: "NicknameErlaubt")
            title = spitzNameTextField.text
        }
    }
    private func filter(_ gefundenerUser:CKMeditierender?) -> CKMeditierender?{
        if gefundenerUser == nil || Meditierender.get()?.userID == gefundenerUser?.userRef.recordID.recordName {
            return nil
        }
        return gefundenerUser
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nickNamePruefungsErgebnisLabel.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(userSearchErgebnis(_:)), name: NSNotification.Name.MyNames.gefundenerUser, object: nil)
    }
}
