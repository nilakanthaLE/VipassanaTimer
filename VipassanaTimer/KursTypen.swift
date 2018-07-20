//
//  KursProtos.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 18.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//
import Foundation

//10-Tage
class tenDayKurs:PublicKursProto{
    override init(){
        super.init()
        days = [ AnkunftsTag(tag: 0),
                 AnapanaTag(tag: 1),
                 AnapanaTag(tag: 2),
                 AnapanaTag(tag: 3),
                 VipassanaEinfuehrungsTag(tag:4),
                 VipassanaTag(tag:5),
                 VipassanaTag(tag:6),
                 VipassanaTag(tag:7),
                 VipassanaTag(tag:8),
                 VipassanaTag(tag:9),
                 MettaEinfuehrungsTag(tag:10),
                 AbfahrtsTag(tag:11)
        ]
        kursNameD   = "10 Tage Kurs"
        kursNameEng = "10 Day Course"
        kursTitle   = "10day"
    }
    
}
//Satipatthana
class satipatthanaKurs:PublicKursProto{
    override init(){
        super.init()
        days = [ AnkunftsTag(tag: 0),
                 AnapanaTag(tag: 1),
                 AnapanaTag(tag: 2),
                 AnapanaTag(tag: 3),
                 VipassanaEinfuehrungsTag(tag:4),
                 VipassanaTag(tag:5),
                 VipassanaTag(tag:6),
                 VipassanaTag(tag:7),
                 MettaEinfuehrungsTag(tag:8),
                 AbfahrtsTag(tag: 9)
        ]
        kursNameD   = "Satipatthana Kurs"
        kursNameEng = "Satipatthana Course"
        kursTitle   = "Satipatthana"
    }
}
