//
//  GeradeMeditiertView.swift
//  Vipassana
//
//  Created by Matthias Pochmann on 08.05.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift

//✅
class GeradeMeditiertView: UICollectionViewController,UICollectionViewDelegateFlowLayout {
    let freiraumZwischenCellen:CGFloat  = 5.0
    let sectionenRaender:CGFloat        = 10
    
    //ViewModel
    var viewModel:GeradeMeditiertViewModel!{ didSet{ viewModel.aktuelleMeditationen.producer.start(){[weak self] _ in self?.reloadTable()}  } }

    //CollectionView DataSource & delegates
    var timer = [Timer]()
    override func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return viewModel.numberOfItems  }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell                            = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MeditationsPlatzCell
        cell.meditationsPlatzView.viewModel = viewModel.getViewModelForCell(indexPath: indexPath)
        if let _timer = cell.meditationsPlatzView.viewModel.timer {timer.append(_timer)}
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { viewModel.sitzPlatzTapped(at: indexPath) }
    
    //Size und Abstände
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize { return sizeForItem }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return freiraumZwischenCellen }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return freiraumZwischenCellen }
    
    //ViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.register(UINib(nibName: "MeditationsPlatzCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        collectionView?.dataSource = self
    }
    
    var _size = CGSize.zero
    override func viewWillLayoutSubviews() {
        if _size != collectionView!.contentSize { reloadTable() }
        _size = collectionView!.contentSize
    }
    
    //helper
    private var sizeForItem:CGSize{
        let anzahlProZeile:CGFloat      = viewModel.anzahlProZeile
        let zwischenRaumSumme:CGFloat   = (anzahlProZeile - 1) * freiraumZwischenCellen
        let raender:CGFloat             = sectionenRaender * 2
        let breite                      = (collectionView!.contentSize.width - zwischenRaumSumme - raender) / anzahlProZeile
        return CGSize(width: breite, height: breite)
    }
    private func reloadTable(){
        for _timer in timer {_timer.invalidate()}
        timer.removeAll()
        collectionView?.reloadData()
    }
    deinit { print("deinit GeradeMeditiertVC") }
}









