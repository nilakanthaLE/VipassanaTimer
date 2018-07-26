//
//  FreundeTableVCModel.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 12.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//
import ReactiveSwift

//✅
//ViewModel für die Tabelle der Freunde
// Anfragen und Freunde
class FreundeTableVCModel{
    //Model
    private var freundesAnfragen    = Freund.getFreundesAnfragen()
    private var freunde             = Freund.getFreunde()
    
    let updateTableView             = MutableProperty<Void>( Void() )
    
    //init
    init(){
        print("freundesAnfragen\(freundesAnfragen.count) freunde:\(freunde.count )")

        freundEreignis.signal.observeValues { [weak self] _ in self?.updateTableViewAction() } }
    
    //tableView Methods
    func numberOfRows(section:Int) -> Int       { return [freundesAnfragen,freunde][section].count }
    func getHeaderTitel(section:Int) -> String? { return [NSLocalizedString("Freundesanfragen", comment: "Freundesanfragen"), NSLocalizedString("meineFreunde", comment: "meineFreunde")][section] }
    func deleteAction(indexPath:IndexPath){
        FirUserConnections.setFreundschaftsstatus(withUserID: getFreund(indexPath: indexPath).freundID,
                                                  userStatus: FreundStatus.granted.rawValue,
                                                  meinStatus: FreundStatus.rejected.rawValue)
    }
    func deleteButtonTitle(indexPath:IndexPath) -> String?{
        if indexPath.section == 0   { return NSLocalizedString("freundesAnfrageAbweisen", comment: "freundesAnfrageAbweisen") }
        else                        { return NSLocalizedString("freundschaftBeenden", comment: "freundschaftBeenden") }
    }
    
    //helper
    private func getFreund(indexPath:IndexPath) -> Freund{ return [freundesAnfragen,freunde][indexPath.section][indexPath.row] }
    private func updateTableViewAction(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.freundesAnfragen          = Freund.getFreundesAnfragen()
            self?.freunde                   = Freund.getFreunde()
            self?.updateTableView.value     = Void() }
        
    }
    
    //ViewModels
    func getViewModelForCell(indexPath:IndexPath) -> FreundeTableViewCellModel{ return FreundeTableViewCellModel(freund: getFreund(indexPath: indexPath)) }
}
