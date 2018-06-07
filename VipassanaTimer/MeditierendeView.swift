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
    var showUserMeditationInfo:((_ activeMeditation:ActiveMeditationInFB)->())?

    private var meditationen = [ActiveMeditationInFB](){ didSet{
        meditationen = meditationen.sorted(by: {($0.start ?? Date()).compare($1.start ?? Date()) == .orderedAscending })
        collectionView.reloadData() }
    }
    var myActiveMeditation:Meditation?{
        willSet{
            if let newValue = newValue  {
                meditationen.append(ActiveMeditationInFB(meditation:newValue))
            }else{
                guard posOfMyActiveMeditation != nil else {return}
                meditationen.remove(at: posOfMyActiveMeditation!)
            }
        }
    }
    private var posOfMyActiveMeditation:Int?{
        guard let myActiveMeditation = myActiveMeditation else {return nil}
        
        var i = 0
        let myActiveFBMeditation = ActiveMeditationInFB(meditation:myActiveMeditation)
        for meditation in meditationen{
            if meditation.userID == myActiveFBMeditation.userID{ return i }
            i += 1
        }
        return nil
    }
    
    //MARK: CollectionView, DataSourcce
    @IBOutlet private weak var collectionView: UICollectionView!{
        didSet{
            collectionView.register(MeditierenderCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
            Singleton.sharedInstance.listOfActiveMeditationHasChanged = listOfActiveMeditationHasChanged
            setLayout()
        }
    }
    private func listOfActiveMeditationHasChanged(){
//        var newlist = Singleton.sharedInstance.filteredAndSortedListOfActiveMeditation
//        if let myActiveMeditation = myActiveMeditation { newlist.append(ActiveMeditationInFB(meditation:myActiveMeditation)) }
//        meditationen = newlist
    }
    private func setLayout(){
        setControlDesignPatterns()
        collectionView.backgroundColor = UIColor.clear
        backgroundColor     = DesignPatterns.controlBackground
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

    deinit { print("deinit MeditierendeView") }
}

class MeditierenderCollectionViewCell:UICollectionViewCell{
    var activeMeditation:ActiveMeditationInFB?{
        didSet{
            guard let activeMeditation = activeMeditation else{return}
            backgroundView = MedititierenderCollectionViewCellView(activeMeditation)
        }
    }
}

class MedititierenderCollectionViewCellView:NibLoadingView{
    @IBOutlet weak var meditationsKissenView: UIView!
    @IBOutlet weak var nameLabel: UILabel!

    convenience init (_ activeMeditation:ActiveMeditationInFB){
        self.init(frame: CGRect.zero)
        nameLabel.text = String(activeMeditation.spitznameString.characters.prefix(4))
//        nameLabel.sizeToFit()
        nameLabel.baselineAdjustment = .alignCenters
    }

    
}


