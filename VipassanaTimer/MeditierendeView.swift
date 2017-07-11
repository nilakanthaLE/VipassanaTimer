//
//  MeditierendeView.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 15.03.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import Foundation
import UIKit
class MeditierendeView:NibLoadingView,UICollectionViewDataSource,UICollectionViewDelegate{
    var showUserMeditationInfo:((_ activeMeditation:CKActiveMeditation)->())?
   
    
    
    private var meditationen = [CKActiveMeditation](){ didSet{
        meditationen = meditationen.sorted(by: {$0.start.compare($1.start) == .orderedAscending })
        collectionView.reloadData() }
    }
    //MARK: List (get,addNewObject,RemoveObject)
    @objc private func addOrRemoveToList(notification:Notification){
        print("addOrRemoveToList")
        guard let activeMeditation = notification.userInfo?["meditation"] as? CKActiveMeditation else { return }
        
        if activeMeditation.isActive{
            print("addToList")
            meditationen.append(activeMeditation)
        }
        else {
            print("RemoveFromList")
            var index : Int?{
                var i = 0
                for meditation in meditationen{
                    if meditation.userID == activeMeditation.userID {return i}
                    i += 1
                }
                return nil
            }
            guard index != nil else {return}
            meditationen.remove(at: index!)
        }
    }
    private func remove(at pos:Int){
        var toAdd = 0
        if let myPos = posOfMyActiveMeditation,myPos <= pos{
            toAdd = 1
        }
        meditationen.remove(at: pos + toAdd)
    }
    
    var myActiveMeditation:Meditation?{
        willSet{
            if let newValue = newValue  {
                guard let activeMeditation = CKActiveMeditation(newValue) else{return}
                meditationen.append(activeMeditation)
            }else{
                guard posOfMyActiveMeditation != nil else {return}
                meditationen.remove(at: posOfMyActiveMeditation!)
            }
        }
    }
    private var posOfMyActiveMeditation:Int?{
        guard let myActiveMeditation = myActiveMeditation else {return nil}
        
        var i = 0
        let myActiveCKMeditation = CKActiveMeditation(myActiveMeditation)
        for meditation in meditationen{
            if meditation.userID == myActiveCKMeditation?.userID{ return i }
            i += 1
        }
        return nil
    }
    
    //MARK: CollectionView, DataSourcce
    @IBOutlet private weak var collectionView: UICollectionView!{
        didSet{
            collectionView.register(MeditierenderCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
            registerObserver()
//            Singleton.sharedInstance.observeActiveMeditations = true
            setLayout()
        }
    }
    private func setLayout(){
        layer.borderColor  = UIColor.white.cgColor
        layer.borderWidth  = 0.25
        layer.cornerRadius = 5
        clipsToBounds      = true
        collectionView.backgroundColor = collectionView.backgroundColor?.withAlphaComponent(0.5)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return meditationen.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        guard let meditierenderCollectionViewCell           = cell as? MeditierenderCollectionViewCell else {return cell}
        meditierenderCollectionViewCell.activeMeditation    = meditationen[indexPath.row]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showUserMeditationInfo?(meditationen[indexPath.row])
    }
    
    //MARK: init
    private func registerObserver(){
        //Liste der aktiven Meditationen
        NotificationCenter.default.addObserver(self, selector: #selector(addOrRemoveToList(notification:)), name:
            NSNotification.Name.MyNames.addOrRemoveActiveMeditationToList, object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
//        Singleton.sharedInstance.observeActiveMeditations = false
        print("deinit MeditierendeView")
    }
}

class MeditierenderCollectionViewCell:UICollectionViewCell{
    var activeMeditation:CKActiveMeditation?{
        didSet{
            guard let activeMeditation = activeMeditation else{return}
            backgroundView = MedititierenderCollectionViewCellView(activeMeditation)
        }
    }
}

class MedititierenderCollectionViewCellView:NibLoadingView{
    @IBOutlet weak var meditationsKissenView: UIView!
    @IBOutlet weak var nameLabel: UILabel!

    convenience init (_ activeMeditation:CKActiveMeditation){
        self.init(frame: CGRect.zero)
        nameLabel.text = String(activeMeditation.spitznameString.characters.prefix(3))
    }

    
}

