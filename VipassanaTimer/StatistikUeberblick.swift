//
//  StatistikUeberblick.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 03.02.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import UIKit

class StatistikUeberblick: NibLoadingView {
    @IBOutlet weak var gesamt: UILabel!
        {didSet{gesamt.text = daten?.gesamtDauer.hhmmString}}
    @IBOutlet weak var gesamtAktuellTag: UILabel!
        {didSet{gesamtAktuellTag.text = daten?.gesamtAktuellTag.hhmmString}}
    @IBOutlet weak var gesamtAktuellWoche: UILabel!
        {didSet{gesamtAktuellWoche.text = daten?.gesamtAktuellWoche.hhmmString}}
    @IBOutlet weak var gesamtAktuellMonat: UILabel!
        {didSet{gesamtAktuellMonat.text = daten?.gesamtAktuellMonat.hhmmString}}

    @IBOutlet weak var gesamtVorherigTag: UILabel!
        {didSet{gesamtVorherigTag.text = daten?.gesamtVorherigTag.hhmmString}}
    @IBOutlet weak var gesamtVorherigWoche: UILabel!
        {didSet{gesamtVorherigWoche.text = daten?.gesamtVorherigWoche.hhmmString}}
    @IBOutlet weak var gesamtVorherigMonat: UILabel!
        {didSet{gesamtVorherigMonat.text = daten?.gesamtVorherigMonat.hhmmString}}
    
    @IBOutlet weak var gesamtAenderungTag: UILabel!{
        didSet{
            let tagAenderung = StatistikUeberblickDaten.gesamtAenderungTag
            gesamtAenderungTag.text             = tagAenderung.text
            gesamtAenderungTag.textColor        = tagAenderung.farbe
        }
    }
    @IBOutlet weak var gesamtAenderungWoche: UILabel!{
        didSet{
            let wocheAenderung = StatistikUeberblickDaten.gesamtAenderungWoche
            gesamtAenderungWoche.text           = wocheAenderung.text
            gesamtAenderungWoche.textColor      = wocheAenderung.farbe
        }
    }
    @IBOutlet weak var gesamtAenderungMonat: UILabel!{
        didSet{
            let monatAenderung = StatistikUeberblickDaten.gesamtAenderungMonat
            gesamtAenderungMonat.text           = monatAenderung.text
            gesamtAenderungMonat.textColor      = monatAenderung.farbe
        }
    }
    
    @IBOutlet weak var durchschnittTag: UILabel!
        {didSet{durchschnittTag.text = daten?.durchschnittTag.hhmmString}}
    @IBOutlet weak var durchSchnittWoche: UILabel!
        {didSet{durchSchnittWoche.text = daten?.durchschnittWoche.hhmmString}}
    @IBOutlet weak var durchSchnittMonat: UILabel!
        {didSet{durchSchnittMonat.text = daten?.durchschnittMonat.hhmmString}}
    
    @IBOutlet weak var durchschnittVorherigTag: UILabel!
        {didSet{durchschnittVorherigTag.text = daten?.gesamtVorherigTag.hhmmString}}
    @IBOutlet weak var durchschnittVorherigWoche: UILabel!
        {didSet{durchschnittVorherigWoche.text = daten?.gesamtVorherigWoche.hhmmString}}
    @IBOutlet weak var durchschnittVorherigMonat: UILabel!
        {didSet{durchschnittVorherigMonat.text = daten?.gesamtVorherigMonat.hhmmString}}
    
    @IBOutlet weak var durchschnittAenderungTag: UILabel!{
        didSet{
            let tagAenderung = StatistikUeberblickDaten.durchschnittAenderungTag
            durchschnittAenderungTag.text             = tagAenderung.text
            durchschnittAenderungTag.textColor        = tagAenderung.farbe
        }
    }
    @IBOutlet weak var durchschnittAenderungWoche: UILabel!{
        didSet{
            let wocheAenderung = StatistikUeberblickDaten.durchschnittAenderungWoche
            durchschnittAenderungWoche.text           = wocheAenderung.text
            durchschnittAenderungWoche.textColor      = wocheAenderung.farbe
        }
    }
    @IBOutlet weak var durchschnittAenderungMonat: UILabel!{
        didSet{
            let monatAenderung = StatistikUeberblickDaten.durchschnittAenderungMonat
            durchschnittAenderungMonat.text           = monatAenderung.text
            durchschnittAenderungMonat.textColor      = monatAenderung.farbe
        }
    }
    
    var delegate:StatistikUeberblickDelegate?
    var daten = Statistics.get(){
        didSet{
            guard let daten = daten else{return}
            gesamt.text                 = daten.gesamtDauer.hhmmString
            gesamtAktuellTag.text       = daten.gesamtAktuellTag.hhmmString
            gesamtAktuellWoche.text     = daten.gesamtAktuellWoche.hhmmString
            gesamtAktuellMonat.text     = daten.gesamtAktuellMonat.hhmmString
            gesamtVorherigTag.text      = daten.gesamtVorherigTag.hhmmString
            gesamtVorherigWoche.text    = daten.gesamtVorherigWoche.hhmmString
            gesamtVorherigMonat.text    = daten.gesamtVorherigMonat.hhmmString
            
            
            let tagAenderung = StatistikUeberblickDaten.gesamtAenderungTag
            gesamtAenderungTag.text             = tagAenderung.text
            gesamtAenderungTag.textColor        = tagAenderung.farbe
            
            let wocheAenderung = StatistikUeberblickDaten.gesamtAenderungWoche
            gesamtAenderungWoche.text           = wocheAenderung.text
            gesamtAenderungWoche.textColor      = wocheAenderung.farbe
            
            let monatAenderung = StatistikUeberblickDaten.gesamtAenderungMonat
            gesamtAenderungMonat.text           = monatAenderung.text
            gesamtAenderungMonat.textColor      = monatAenderung.farbe
            
            durchschnittTag.text            = daten.durchschnittTag.hhmmString
            durchSchnittWoche.text          = daten.durchschnittWoche.hhmmString
            durchSchnittMonat.text          = daten.durchschnittMonat.hhmmString
            durchschnittVorherigTag.text    = daten.gesamtVorherigTag.hhmmString
            durchschnittVorherigWoche.text  = daten.gesamtVorherigWoche.hhmmString
            durchschnittVorherigMonat.text  = daten.gesamtVorherigMonat.hhmmString
            
            let tagAenderungDurchschnitt = StatistikUeberblickDaten.durchschnittAenderungTag
            durchschnittAenderungTag.text             = tagAenderungDurchschnitt.text
            durchschnittAenderungTag.textColor        = tagAenderungDurchschnitt.farbe
            
            let wocheAenderungDurchschnitt  = StatistikUeberblickDaten.durchschnittAenderungWoche
            durchschnittAenderungWoche.text           = wocheAenderungDurchschnitt.text
            durchschnittAenderungWoche.textColor      = wocheAenderungDurchschnitt.farbe
            
            let monatAenderungDurchschnitt = StatistikUeberblickDaten.durchschnittAenderungMonat
            durchschnittAenderungMonat.text           = monatAenderungDurchschnitt.text
            durchschnittAenderungMonat.textColor      = monatAenderungDurchschnitt.farbe
        }
    }
    @IBAction func iButtonPressed(_ sender: UIButton) {
        delegate?.infoButtonPressed()
    }
    @IBOutlet weak var statistikView: UIView!{
        didSet{
            statistikView.setControlDesignPatterns()
        }
    }
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        delegate?.viewTapped()
    }
    
    
    
}
protocol StatistikUeberblickDelegate {
    func infoButtonPressed()
    func viewTapped()
}
class StatistikUeberblick2:NibLoadingView{
    var delegate:StatistikUeberblickDelegate?
    func update(){
        
    }
    
    @IBAction private func viewTapped(_ sender: UITapGestureRecognizer) {
        delegate?.viewTapped()
    }
    @IBOutlet private weak var statistikView: UIView! {
        didSet{
            statistikView.setControlDesignPatterns()
        }
    }
    
    
    @IBOutlet private weak var gesamtZeitOhneKurse: UILabel!
        {didSet{gesamtZeitOhneKurse.text = "\(daten?.gesamtDauerOhneKurse.hhmmString ?? "")"}}
    @IBOutlet private weak var einmalAmTagBisHeute: UILabel!
        {didSet{einmalAmTagBisHeute.text = "\(daten?.regelmaessigEinmalAmTag ?? 0)"}}
    @IBOutlet private weak var einmalAmTagMax: UILabel!
        {didSet{einmalAmTagMax.text = "\(daten?.regelmaessigEinmalAmTagMax ?? 0)"}}
    @IBOutlet private weak var zweimalAmTagBisHeute: UILabel!
        {didSet{zweimalAmTagBisHeute.text = "\(daten?.regelmaessigZweiMalAmTag ?? 0)"}}
    @IBOutlet private weak var zweiMalAmTagMax: UILabel!
        {didSet{zweiMalAmTagMax.text = "\(daten?.regelmaessigZweimalAmTagMax ?? 0)"}}
    @IBOutlet private weak var kursTage: UILabel!
        {didSet{kursTage.text = "\(daten?.kursTage ?? 0)"}}
    var daten = Statistics.get(){
        didSet{
            guard let daten = daten else{return}
            gesamtZeitOhneKurse.text    = "\(daten.gesamtDauerOhneKurse.hhmmString)"
            einmalAmTagBisHeute.text    = "\(daten.regelmaessigEinmalAmTag)"
            einmalAmTagMax.text         = "\(daten.regelmaessigEinmalAmTagMax)"
            zweimalAmTagBisHeute.text   = "\(daten.regelmaessigZweiMalAmTag)"
            zweiMalAmTagMax.text        = "\(daten.regelmaessigZweimalAmTagMax)"
            kursTage.text               = "\(daten.kursTage)"
        }
    }
    
}
