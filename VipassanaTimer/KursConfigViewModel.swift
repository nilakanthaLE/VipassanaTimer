//
//  KursConfigViewModel.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 13.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import ReactiveSwift

//✅
// ViewModel für die Erstellung neuer Kurse
// Kursprotos werden aus Firbase geladen
class KursConfigViewModel{
    let startDateText               = MutableProperty<String?>(nil)
    let endDateText                 = MutableProperty<String?>(nil)
    let pickerTitles                = MutableProperty<[String?]>([String?]())
    let selectedRow                 = MutableProperty<Int>(0)
    let selectedDate                = MutableProperty<Date>(Date())
    let erstellenButtonAction       = MutableProperty<Void>(Void())
    let stacksAreHidden             = MutableProperty<Bool>(true)
    let teacher                     = MutableProperty<String?>(nil)
    
    //init
    private let kursProtos          = MutableProperty<[PublicKursProto?]>([PublicKursProto?]())
    init(){
        //holt Kursprotos aus Firebase
        FirebaseKursProto.getList(publicKursProtos: kursProtos)
        
        pickerTitles            <~ kursProtos.signal.map{ $0.map {$0?.kursNameD ?? "-----"} }
        startDateText           <~ selectedDate.producer.map{$0.string("dd.MM.yyyy")}
        stacksAreHidden         <~ selectedRow.map{$0 == 0}
        endDateText             <~ selectedDate.signal.map{[weak self] _ in (self?.endDate ?? Date()).string("dd.MM.yyyy") }
        endDateText             <~ selectedRow.signal.map{[weak self] _ in (self?.endDate ?? Date()).string("dd.MM.yyyy") }
        
        erstellenButtonAction.signal.observe{[weak self] _ in
            guard let kursProto =  self?.kursProtos.value[self?.selectedRow.value ?? 0] else {return}
            let kursData = KursData(publicKursProto: kursProto, startTag: self!.selectedDate.value, teacher: self?.teacher.value )
            _ = Kurs.new(kursData: kursData)
        }
    }
    
    //helper
    private var endDate:Date{
        guard let kursProto =  kursProtos.value[selectedRow.value] else {return selectedDate.value}
        return selectedDate.value.addDays(kursProto.days.count - 1)
    }
}
