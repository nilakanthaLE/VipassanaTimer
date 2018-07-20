//
//  MeineFreundesAnfragenTableVCModel.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 12.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//
import ReactiveSwift

//✅
//ViewModel für die Liste meiner Freundesanfragen
// offene und zurückgewiesene Anfragen
class MeineFreundesAnfragenTableVCModel{
    //Model
    private var meineAnfragen   = Freund.getMeineAnfragen()
    
    let updateTableView         = MutableProperty<Void>( Void() )
    
    //init
    init(){  freundEreignis.signal.observeValues { [weak self] _ in self?.updateTableViewAction() } }
    
    //TableViewData und Actions
    func numberOfRows(in section:Int) -> Int{ return meineAnfragen[section].count }
    func header(for section:Int) -> String?{
        return [NSLocalizedString("meineAnfragen", comment: "meineAnfragen"),
                NSLocalizedString("zurueckGewieseneAnfragen", comment: "zurueckGewieseneAnfragen")][section]
    }
    func deleteAction(indexPath:IndexPath)                  { FirUserConnections.deleteUserConnection(withUserID: meineAnfragen[indexPath.section][indexPath.row].freundID)  }
    func getCellTitle(for indexPath:IndexPath) -> String?   { return meineAnfragen[indexPath.section][indexPath.row].freundNick }
    
    //helper
    private func updateTableViewAction(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.meineAnfragen             = Freund.getMeineAnfragen()
            self?.updateTableView.value     = Void()
        }
        
    }
}
