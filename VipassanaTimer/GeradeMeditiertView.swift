//
//  GeradeMeditiertView.swift
//  Vipassana
//
//  Created by Matthias Pochmann on 08.05.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift







@IBDesignable class GeradeMeditiertView: UICollectionViewController,UICollectionViewDelegateFlowLayout {
    let freiraumZwischenCellen:CGFloat  = 5.0
    let sectionenRaender:CGFloat        = 10
    
    
    
    var viewModel:GeradeMeditiertViewModel!{
        didSet{
            print("GeradeMeditiertView viewModel didSet")
            viewModel.aktuelleMeditationen.producer.start(){[weak self] _ in
                self?.collectionView?.reloadData()
            }
        }
    }
    
    let reuseIdentifier = "cell"
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell        = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MeditationsPlatzCell
        cell.viewModel  = viewModel.getViewModelForCell(indexPath: indexPath)
        
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.sitzPlatzTapped(at: indexPath)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("GeradeMeditiertView viewDidLoad")
        collectionView?.register(UINib(nibName: "MeditationsPlatzCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.dataSource = self
        collectionView?.reloadData()
        
        
    }
    
    var sizeForItem:CGSize{
        
        let anzahlProZeile:CGFloat      = viewModel.anzahlProZeile
        let zwischenRaumSumme:CGFloat   = (anzahlProZeile - 1) * freiraumZwischenCellen
        let raender:CGFloat             = sectionenRaender * 2
        let breite                      = (collectionView!.contentSize.width - zwischenRaumSumme - raender) / anzahlProZeile
        return CGSize(width: breite, height: breite)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sizeForItem
    }
    
    //Abstände
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return freiraumZwischenCellen
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return freiraumZwischenCellen
    }
}









