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
        {didSet{gesamt.text = daten.gesamt.hhmmString}}
    @IBOutlet weak var gesamtAktuellTag: UILabel!
        {didSet{gesamtAktuellTag.text = daten.gesamtAktuellTag.hhmmString}}
    @IBOutlet weak var gesamtAktuellWoche: UILabel!
        {didSet{gesamtAktuellWoche.text = daten.gesamtAktuellWoche.hhmmString}}
    @IBOutlet weak var gesamtAktuellMonat: UILabel!
        {didSet{gesamtAktuellMonat.text = daten.gesamtAktuellMonat.hhmmString}}

    @IBOutlet weak var gesamtVorherigTag: UILabel!
        {didSet{gesamtVorherigTag.text = daten.gesamtVorherigTag.hhmmString}}
    @IBOutlet weak var gesamtVorherigWoche: UILabel!
        {didSet{gesamtVorherigWoche.text = daten.gesamtVorherigWoche.hhmmString}}
    @IBOutlet weak var gesamtVorherigMonat: UILabel!
        {didSet{gesamtVorherigMonat.text = daten.gesamtVorherigMonat.hhmmString}}
    
    @IBOutlet weak var gesamtAenderungTag: UILabel!{
        didSet{
            let tagAenderung = daten.gesamtAenderungTag
            gesamtAenderungTag.text             = tagAenderung.text
            gesamtAenderungTag.textColor        = tagAenderung.farbe
        }
    }
    @IBOutlet weak var gesamtAenderungWoche: UILabel!{
        didSet{
            let wocheAenderung = daten.gesamtAenderungWoche
            gesamtAenderungWoche.text           = wocheAenderung.text
            gesamtAenderungWoche.textColor      = wocheAenderung.farbe
        }
    }
    @IBOutlet weak var gesamtAenderungMonat: UILabel!{
        didSet{
            let monatAenderung = daten.gesamtAenderungMonat
            gesamtAenderungMonat.text           = monatAenderung.text
            gesamtAenderungMonat.textColor      = monatAenderung.farbe
        }
    }
    
    @IBOutlet weak var durchschnittTag: UILabel!
        {didSet{durchschnittTag.text = daten.durchschnittTag.hhmmString}}
    @IBOutlet weak var durchSchnittWoche: UILabel!
        {didSet{durchSchnittWoche.text = daten.durchSchnittWoche.hhmmString}}
    @IBOutlet weak var durchSchnittMonat: UILabel!
        {didSet{durchSchnittMonat.text = daten.durchSchnittMonat.hhmmString}}
    
    @IBOutlet weak var durchschnittVorherigTag: UILabel!
        {didSet{durchschnittVorherigTag.text = daten.gesamtVorherigTag.hhmmString}}
    @IBOutlet weak var durchschnittVorherigWoche: UILabel!
        {didSet{durchschnittVorherigWoche.text = daten.gesamtVorherigWoche.hhmmString}}
    @IBOutlet weak var durchschnittVorherigMonat: UILabel!
        {didSet{durchschnittVorherigMonat.text = daten.gesamtVorherigMonat.hhmmString}}
    
    @IBOutlet weak var durchschnittAenderungTag: UILabel!{
        didSet{
            let tagAenderung = daten.durchschnittAenderungTag
            durchschnittAenderungTag.text             = tagAenderung.text
            durchschnittAenderungTag.textColor        = tagAenderung.farbe
        }
    }
    @IBOutlet weak var durchschnittAenderungWoche: UILabel!{
        didSet{
            let wocheAenderung = daten.durchschnittAenderungWoche
            durchschnittAenderungWoche.text           = wocheAenderung.text
            durchschnittAenderungWoche.textColor      = wocheAenderung.farbe
        }
    }
    @IBOutlet weak var durchschnittAenderungMonat: UILabel!{
        didSet{
            let monatAenderung = daten.durchschnittAenderungMonat
            durchschnittAenderungMonat.text           = monatAenderung.text
            durchschnittAenderungMonat.textColor      = monatAenderung.farbe
        }
    }
    
    var delegate:StatistikUeberblickDelegate?
    var daten = StatistikUeberblickDaten(){
        didSet{
            gesamt.text = daten.gesamt.hhmmString
            gesamtAktuellTag.text = daten.gesamtAktuellTag.hhmmString
            gesamtAktuellWoche.text = daten.gesamtAktuellWoche.hhmmString
            gesamtAktuellMonat.text = daten.gesamtAktuellMonat.hhmmString
            gesamtVorherigTag.text = daten.gesamtVorherigTag.hhmmString
            gesamtVorherigWoche.text = daten.gesamtVorherigWoche.hhmmString
            gesamtVorherigMonat.text = daten.gesamtVorherigMonat.hhmmString
            
            
            let tagAenderung = daten.gesamtAenderungTag
            gesamtAenderungTag.text             = tagAenderung.text
            gesamtAenderungTag.textColor        = tagAenderung.farbe
            
            let wocheAenderung = daten.gesamtAenderungWoche
            gesamtAenderungWoche.text           = wocheAenderung.text
            gesamtAenderungWoche.textColor      = wocheAenderung.farbe
            
            let monatAenderung = daten.gesamtAenderungMonat
            gesamtAenderungMonat.text           = monatAenderung.text
            gesamtAenderungMonat.textColor      = monatAenderung.farbe
            
            durchschnittTag.text = daten.durchschnittTag.hhmmString
            durchSchnittWoche.text = daten.durchSchnittWoche.hhmmString
            durchSchnittMonat.text = daten.durchSchnittMonat.hhmmString
            durchschnittVorherigTag.text = daten.gesamtVorherigTag.hhmmString
            durchschnittVorherigWoche.text = daten.gesamtVorherigWoche.hhmmString
            durchschnittVorherigMonat.text = daten.gesamtVorherigMonat.hhmmString
            
            let tagAenderungDurchschnitt = daten.durchschnittAenderungTag
            durchschnittAenderungTag.text             = tagAenderungDurchschnitt.text
            durchschnittAenderungTag.textColor        = tagAenderungDurchschnitt.farbe
            
            let wocheAenderungDurchschnitt  = daten.durchschnittAenderungWoche
            durchschnittAenderungWoche.text           = wocheAenderungDurchschnitt.text
            durchschnittAenderungWoche.textColor      = wocheAenderungDurchschnitt.farbe
            
            let monatAenderungDurchschnitt = daten.durchschnittAenderungMonat
            durchschnittAenderungMonat.text           = monatAenderungDurchschnitt.text
            durchschnittAenderungMonat.textColor      = monatAenderungDurchschnitt.farbe
        }
    }
    @IBAction func iButtonPressed(_ sender: UIButton) {
        delegate?.infoButtonPressed()
    }
    @IBOutlet weak var statistikView: UIView!{
        didSet{
            statistikView.layer.cornerRadius    = 5.0
            statistikView.layer.borderColor     = DesignPatterns.mocha.cgColor
            statistikView.layer.borderWidth     = 0.5
        }
    }
    
}
protocol StatistikUeberblickDelegate {
    func infoButtonPressed()
}
