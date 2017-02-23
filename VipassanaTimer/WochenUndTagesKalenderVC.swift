//
//  WochenUndTagesKalenderVC.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 12.01.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import UIKit




class WochenUndTagesKalenderVC: UIViewController,UIScrollViewDelegate {

    //zusätzliche Anpassungen
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        
        if parent != nil && self.navigationItem.titleView == nil {
            initNavigationItemTitleView()
        }
    }
    private let titleView = UILabel()
    private func initNavigationItemTitleView() {
        titleView.text  = title
        titleView.font  = UIFont(name: "HelveticaNeue-Medium", size: 17)
        titleView.sizeToFit()
        navigationItem.titleView            = titleView
        let recognizer                      = UITapGestureRecognizer(target: self, action: #selector(titleWasTapped))
        titleView.isUserInteractionEnabled  = true
        titleView.addGestureRecognizer(recognizer)
        titleView.textAlignment             = .center
    }
    override var title: String?{ didSet{ titleView.text = title } }
    
    private enum TitleTyp{
        case wocheDauer
        case wocheAnzahl
        case tagDauer
        case tagAnzahl
        func isTag()->Bool{return (self == .tagAnzahl || self == .tagDauer)}
        func isWoche()->Bool{return self == .tagAnzahl || self == .tagDauer}
    }
    private var titleTyp:TitleTyp?{
        didSet{
            guard let titleTyp = titleTyp else{return}
            switch titleTyp {
                case .tagAnzahl     : title = statistic.tagAnzahlLabelText
                case .tagDauer      : title = statistic.tagDauerLabelText
                case .wocheAnzahl   : title = statistic.wocheAnzahlLabelText
                case .wocheDauer    : title = statistic.wocheDauerLabelText
            }
        }
    }
    @objc private func titleWasTapped() {
        guard let _titleTyp = titleTyp else{return}
        switch _titleTyp {
            case .tagAnzahl : titleTyp = .tagDauer
            case .tagDauer  : titleTyp = .tagAnzahl
            case .wocheDauer : titleTyp = .wocheAnzahl
            case .wocheAnzahl : titleTyp = .wocheDauer
        }
    }
    
    @IBAction func addMeditationButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "editMeditation", sender: nil)
    }
    @objc private func meditationsKalenderEintragPressed(notification:Notification){
        if let meditation = notification.userInfo!["meditation"] as? Meditation{
            performSegue(withIdentifier: "editMeditation", sender: meditation)
        }
    }
    
    
    private var eintraegeInKalender         = Meditation.get7Days(firstDay: Date().addDays(-3)){
        didSet{
            kalenderView?.eintraegeInKalender       = eintraegeInKalender
        }
    }
    
    
    //MARK: Statistik (falscher VC)
    var statistic = Statistik(meditationen: Meditation.getDays(start: Date(), ende: Date()), start: Date(), ende: Date()){
        didSet{
            if angezeigteWoche == nil{ titleTyp = .tagDauer }
            else{  titleTyp = .wocheDauer }
        }
    }
    
    private var angezeigteWoche:Date?{
        didSet{
            guard let angezeigteWoche   = angezeigteWoche else{return}
            let meditations             = Meditation.getDays(start: angezeigteWoche.mondayOfWeek, ende: angezeigteWoche.sundayOfWeek)
            statistic                   = Statistik(meditationen: meditations, start: angezeigteWoche.mondayOfWeek, ende: angezeigteWoche.sundayOfWeek)
        }
    }
    private var angezeigterTag:Date?{
        didSet{
            guard let angezeigterTag    = angezeigterTag else {return}
            
            
            let meditations             = Meditation.getDays(start: angezeigterTag, ende: angezeigterTag)
            statistic                   = Statistik(meditationen: meditations, start: angezeigterTag, ende: angezeigterTag)
        }
    }
    
    @IBAction func monatsButtonPressed(_ sender: UIButton) {
        
    }
    
    //MARK: unwindSegue (ungenutzt?)
    @IBAction func reloadKalender(segue:UIStoryboardSegue){reInit()}
    
    //MARK: outlets und contentViews
    @IBOutlet weak private var tageScrollView: UIScrollView!
    @IBOutlet weak private var kalenderScrollView: UIScrollView!
    @IBOutlet weak private var stundenScrollView: UIScrollView!
    private var stundenView:StundenView?
    private var kalenderView:KalenderView?
    private var tageView:TageView?
    @IBOutlet weak var monatsButton: UIButton!
    
    
    private var anzahlSichtbareTageInView:Int{ return isLandscape ? 4 : 1 }
    
    
    
    
    //MARK: init
    private var isAboutToReInit     = false
    private func reInit(){
        isAboutToReInit = true
        initTageScrollView()
        initStundenScrollView()
        initKalenderScrollView()
        eintraegeInKalender                     = Meditation.get7Days(firstDay: Date().addDays(-3))
        setToCurrentTime()
        ersterSichtbarerTag                     = sichtbareTage.first
        isAboutToReInit = false
    }
    private func initTageScrollView(){
        tageView?.removeFromSuperview()
        tageView                                = TageView(frame: tageScrollView.frame, anzahlSichtbareTageInView: anzahlSichtbareTageInView)
        tageView?.ersterTag                     = Date().addDays(-3)
        tageScrollView.contentSize              = tageView!.frame.size
        tageScrollView.contentOffset.x          = anzahlSichtbareTageInView == 1 ? tageView!.frame.size.width/7  * 3 : tageView!.frame.size.width/7*2
        tageScrollView.addSubview(tageView!)
    }
    private func initStundenScrollView(){
        stundenView?.removeFromSuperview()
        stundenView                             = StundenView.init(frame: stundenScrollView.frame)
        stundenScrollView.contentSize           = stundenView!.frame.size
        stundenScrollView.contentOffset         = CGPoint.zero
        stundenScrollView.addSubview(stundenView!)
    }
    private func initKalenderScrollView(){
        kalenderView?.removeFromSuperview()
        kalenderView                            = KalenderView(frame: kalenderScrollView.frame, anzahlSichtbareTageInView: anzahlSichtbareTageInView)
        kalenderView?.ersterTag                 = Date().addDays(-3)
        kalenderScrollView.contentSize          = kalenderView!.frame.size
        kalenderScrollView.contentOffset.x      = anzahlSichtbareTageInView == 1 ? kalenderView!.frame.size.width/7  * 3 : kalenderView!.frame.size.width/7*2   //erster sichtbarer Tag ist 2. Tag des KalenderViews
        kalenderScrollView.addSubview(kalenderView!)
        kalenderScrollView.decelerationRate     = UIScrollViewDecelerationRateFast
    }
    private func setToCurrentTime(){
        let time                                = Date().timeIntervalSince(Date().firstSecondOfDay!)
        let anteilTag                           = CGFloat(time) / CGFloat(24*60*60)
        let y                                   = kalenderScrollView.contentSize.height * anteilTag - kalenderScrollView.frame.size.height / 2
        kalenderScrollView.contentOffset.y      = y > 0 ? y :0
    }
    
    //MARK: Viewcontroller Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        lastOrientationIsLandscape = isLandscape
        reInit()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(meditationsKalenderEintragPressed(notification:)), name: Notification.Name.MyNames.meditationsKalenderEintragPressed, object: nil)
    }
    
    //MARK: reinit bei Wechsel zwischen Portrait und Landscape
    private var lastOrientationIsLandscape = false
    private var isLandscape:Bool{ return view.frame.size.width > view.frame.size.height }
    @objc private func rotated() {
        if lastOrientationIsLandscape != isLandscape{  reInit() }
        lastOrientationIsLandscape = isLandscape
    }
    
    //MARK: Verhalten beim Scrollen (horizontal)
    private func detectNewDayInView(){
        let breiteTag                           = kalenderScrollView.frame.size.width/CGFloat(anzahlSichtbareTageInView) - 5
        var daysToAdd = 0
        if kalenderScrollView.contentOffset.x <= 0{
            kalenderScrollView.contentOffset.x          = 2*breiteTag
            daysToAdd                                   = -2
        }
        else if kalenderScrollView.contentOffset.x >= CGFloat(7 - anzahlSichtbareTageInView) * breiteTag{
            kalenderScrollView.contentOffset.x          -= 2*breiteTag
            daysToAdd                                   = 2
        }
        if daysToAdd != 0{
            kalenderView?.ersterTag                 = kalenderView?.ersterTag?.addDays(daysToAdd)
            tageView?.ersterTag                     = tageView?.ersterTag?.addDays(daysToAdd)
            if let ersterTag = kalenderView?.ersterTag{
                eintraegeInKalender = Meditation.get7Days(firstDay: ersterTag)
            }
        }
    }
    private func dayPaging(){
        var newOffset = kalenderScrollView.contentOffset
        let tagLinks            = Int((kalenderScrollView.contentOffset.x / kalenderScrollView.contentSize.width) * 7)
        let mitteDesLinkenTages = kalenderScrollView.contentSize.width / 7 * (CGFloat(tagLinks) + 0.5)
        
        if kalenderScrollView.contentOffset.x - mitteDesLinkenTages < 0{
            //nach links
            newOffset.x =  kalenderScrollView.contentSize.width / 7 * (CGFloat(tagLinks))
        }else{
            //nach rechts
            newOffset.x =  kalenderScrollView.contentSize.width / 7 * CGFloat(tagLinks + 1)
        }
        kalenderScrollView.setContentOffset(newOffset, animated: true)
    }
    
    
    //MARK: ScrollView detect and lock direction
    private var lockedDirection:moveTo?
    private var direction:moveTo?
    private func lockDirection(){
        guard let lockedDirection = lockedDirection, let lastContentOffset = lastContentOffset else {return}
        if lockedDirection.isHorizontal{
            kalenderScrollView.contentOffset.y  = lastContentOffset.y
        }else if lockedDirection.isVertical{
            kalenderScrollView.contentOffset.x  = lastContentOffset.x
        }
    }
    private func detectDirection(){
        //bestimmt die Scrollrichtung
        guard let lastContentOffset = lastContentOffset else {return}
        let scrollWeite     = CGPoint(x: lastContentOffset.x - kalenderScrollView.contentOffset.x,
                                      y: lastContentOffset.y - kalenderScrollView.contentOffset.y)
        if abs(scrollWeite.x) > abs(scrollWeite.y) {
            if scrollWeite.x > 0{ direction  = moveTo.right }else{ direction  = moveTo.left }
        }else{
            if scrollWeite.y > 0{ direction  = moveTo.top }else{ direction  = moveTo.bottom }
        }
        if lockedDirection == nil{
            lockedDirection = direction
        }
    }
    
    //MARK: ScrollView Delegates
    private var userIsScrolling = false
    private var lastContentOffset: CGPoint?
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        detectDirection()
        if !isAboutToReInit{
            lockDirection()
            if direction?.isHorizontal ?? false{
                detectNewDayInView()
            }
        }
        //scrollt StundenScrollview und TageScrollview mit
        stundenScrollView?.contentOffset.y      = kalenderScrollView.contentOffset.y
        tageScrollView.contentOffset.x          = kalenderScrollView.contentOffset.x
        lastContentOffset                       = scrollView.contentOffset
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastContentOffset                       = scrollView.contentOffset
        userIsScrolling                         = true
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScrolling()
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.x == 0 && velocity.y == 0{
            scrollViewDidEndScrolling()
        }
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        //animation wird (bisher) nur bei daypaging gestartet
        scrollViewDidEndScrolling()
    }
    private func scrollViewDidEndScrolling(){
        if direction?.isHorizontal ?? false{
            dayPaging()
            ersterSichtbarerTag = sichtbareTage.first
        }
        lockedDirection     = nil
        direction           = nil
        userIsScrolling     = false
    }
    
    //MARK: erster sichtbarer Tag
    private var sichtbareTage:[Date]{
        var tage                            = [Date]()
        let nummerErsterSichtbarerTag       = Int((kalenderScrollView.contentOffset.x / kalenderScrollView.contentSize.width) * 7)
        for i in 0 ..< anzahlSichtbareTageInView{
            if let neu = kalenderView?.ersterTag?.addDays(nummerErsterSichtbarerTag + i) {
                tage.append(neu)
            }
        }
        return tage
    }
    private var ersterSichtbarerTag:Date?{didSet{setAngezeigterTagOderWoche()}}
    private func setAngezeigterTagOderWoche(){
        if sichtbareTage.count == 1{
            angezeigteWoche     = nil
            angezeigterTag      = sichtbareTage.first
        }else{
            angezeigterTag      = nil
            angezeigteWoche     = Date.weekOfMostDays(in: sichtbareTage)
        }
    }
    
    
    //MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination.contentViewController as? EditMeditationVC, let meditation = sender as? Meditation {
            destination.meditation = meditation
        }
    }
}
//ContentView des kalenderScrollView
private class KalenderView:UIView{
    var eintraegeInKalender = [[EintragInKalender]](){
        willSet{
            var i = 0
            for _eintraegeInKalender in newValue{
                tageViews[i].eintraegeInKalender = _eintraegeInKalender
                i += 1
            }
        }
    }
    //erster Tag = erster tag in View != erster sichtbarer Tag
    var ersterTag:Date?{
        willSet{
            guard let newValue = newValue else{return}
            setWochenGrenze(newErsterTag: newValue)
        }
    }
    private let anzahlTage:CGFloat  = 7
    private let wochenGrenzeBreite:CGFloat = 1.0
    private var tageViews   = [TagView]()
    private var wochenGrenze:UIView
    init(frame:CGRect,anzahlSichtbareTageInView:Int){
        var breiteTag   = frame.size.width / CGFloat(anzahlSichtbareTageInView)
        let hoeheTag    = frame.size.height * 3
        var frame       = CGRect(x: 0, y: 0, width: anzahlTage*breiteTag+wochenGrenzeBreite, height: hoeheTag)
        wochenGrenze    = UIView.init(frame: CGRect(x: 0, y: 0, width: wochenGrenzeBreite, height: hoeheTag))
        super.init(frame: frame)
        breiteTag       = (frame.size.width-wochenGrenzeBreite) / anzahlTage
        for i in 0 ..< Int(anzahlTage){
            frame           = CGRect(x: CGFloat(i) * breiteTag, y: 0, width: breiteTag, height: hoeheTag)
            let tag         = TagView(frame: frame)
            if i%2 == 0
            {
                tag.backgroundColor = UIColor(white: 0.1, alpha: 0.1)
            }
            tageViews.append(tag)
            addSubview(tag)
        }
        wochenGrenze.backgroundColor = DesignPatterns.gelb
        addSubview(wochenGrenze)
    }
    private func setWochenGrenze(newErsterTag:Date){
        var sonntag:Int {
            let sunday = newErsterTag.sundayOfWeek
            for i in 0 ..< tageViews.count{
                let iDay = newErsterTag.addDays(i)
                if iDay.istGleicherTag(wie: sunday){
                    return i
                }
            }
            return 0
        }
        for i in 0 ..< tageViews.count{
            let tagView = tageViews[i]
            if i == 0{
                tagView.frame.origin.x = 0
            }
            else if i != sonntag+1{
                tagView.frame.origin.x = tageViews[i-1].frame.maxX
            }else{
                tagView.frame.origin.x = tageViews[i-1].frame.maxX + wochenGrenzeBreite
            }
        }
        wochenGrenze.frame.origin.x = tageViews[sonntag].frame.maxX
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
//MARK: View eines einzelnen Tages
private class TagView:UIView{
    var eintraegeInKalender = [EintragInKalender](){
        didSet{
            for eintrag in kalenderEintraegeViews{
                eintrag.removeFromSuperview()
            }
            kalenderEintraegeViews.removeAll()
            for eintragInKalender in eintraegeInKalender{
                let eintrag = KalenderEintrag.init(eintragInKalender: eintragInKalender, tagView: self)
                kalenderEintraegeViews.append(eintrag)
            }
        }
    }
    private var kalenderEintraegeViews = [KalenderEintrag]()
    override init(frame:CGRect){
        super.init(frame: frame)
        layer.borderColor       = UIColor.lightGray.cgColor
        layer.borderWidth       = 0.25
        for i in 0...24{
            let hoeheStunde = (frame.size.height)/24
            let stundeView  = UIView(frame: CGRect(x: 0, y: CGFloat(i) * hoeheStunde, width: frame.size.width, height: hoeheStunde))
            stundeView.layer.borderColor       = UIColor.lightGray.cgColor
            stundeView.layer.borderWidth       = 0.25
            addSubview(stundeView)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
private class KalenderEintrag:UIView{
    init(eintragInKalender:EintragInKalender,tagView:TagView){
        let y       = CGFloat(eintragInKalender.eintragStart.secondOfDay) / CGFloat(24*60*60) * tagView.frame.size.height
        let height  = CGFloat(CGFloat(eintragInKalender.eintragEnde.timeIntervalSince(eintragInKalender.eintragStart)) / CGFloat(24*60*60)) * tagView.frame.size.height
        super.init(frame:CGRect(x: 0, y: y, width: tagView.frame.size.width, height: height))
        let view    = eintragInKalender.eintragView
        view.frame          = frame
        view.frame.origin.y = 0
        addSubview(view)
        tagView.addSubview(self)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class TageView:UIView{
    var ersterTag:Date?{
        willSet{
            guard let newValue = newValue else{return}
            setWochenGrenze(newErsterTag: newValue)
            var i = 0
            for tagLabel in tageLabels{
                tagLabel.text           = newValue.addDays(i).string("EEE dd.MM")
                i += 1
            }
        }
    }
    var tageLabels = [UILabel]()
    private let wochenGrenzeBreite:CGFloat = 1.0
    private var wochenGrenze:UIView
    init(frame:CGRect,anzahlSichtbareTageInView:Int){
        let breiteTag               = frame.size.width / CGFloat(anzahlSichtbareTageInView)
        wochenGrenze                = UIView.init(frame: CGRect(x: 0, y: 0, width: wochenGrenzeBreite, height: frame.size.height))
        super.init(frame: CGRect(x: 0, y: 0, width: breiteTag * 7 + wochenGrenzeBreite, height: frame.size.height))
        createTageLabels()
        wochenGrenze.backgroundColor    = DesignPatterns.gelb
        addSubview(wochenGrenze)
    }
    private func createTageLabels(){
        let breiteTag = (frame.size.width - wochenGrenzeBreite)  / CGFloat(7)
        for i in 0 ..< 7 {
            let label = UILabel(frame: CGRect(x: CGFloat(i) * breiteTag, y: 0, width: breiteTag, height: frame.size.height))
            addSubview(label)
            if i%2 == 0 { label.backgroundColor = UIColor(white: 0.1, alpha: 0.1) }
            tageLabels.append(label)
            label.set(design: DesignPatterns.tageView)
        }
    }
    private func setWochenGrenze(newErsterTag:Date){
        var sonntag:Int {
            let sunday = newErsterTag.sundayOfWeek
            for i in 0 ..< tageLabels.count{
                let iDay = newErsterTag.addDays(i)
                if iDay.istGleicherTag(wie: sunday){
                    return i
                }
            }
            return 0
        }
        for i in 0 ..< tageLabels.count{
            let tagView = tageLabels[i]
            if i == 0{ tagView.frame.origin.x = 0 }
            else if i != sonntag+1{ tagView.frame.origin.x = tageLabels[i-1].frame.maxX
            }else{ tagView.frame.origin.x = tageLabels[i-1].frame.maxX + wochenGrenzeBreite }
        }
        wochenGrenze.frame.origin.x = tageLabels[sonntag].frame.maxX
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
//ContentView des StundenScrollView
private class StundenView:UIView{
    override init(frame:CGRect){
        let hoeheView               = frame.size.height * 3
        super.init(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: hoeheView))
        createStundenLabels()
    }
    
    private func createStundenLabels(){
        for i in 0...24{
            let hoeheStunde = (frame.size.height)/24
            let stundeViewFrame     = CGRect(x: 0, y: CGFloat(i) * hoeheStunde, width: frame.size.width, height: hoeheStunde)
            let stundeView          = UIView(frame: stundeViewFrame)
            stundeView.layer.borderColor        = UIColor.lightGray.cgColor
            stundeView.layer.borderWidth        = 0.26
            let stundeLabel                     = UILabel(frame: stundeViewFrame)
            let stunde                          = i+1==24 ? 0 : i+1
            stundeLabel.text                    = "\(stunde<10 ? "0\(stunde)":"\(stunde)"):00"
            stundeLabel.set(design: DesignPatterns.stundenLabel)
            //rückt label nach rechts unten
            stundeLabel.sizeToFit()
            stundeLabel.frame.origin.y          = stundeViewFrame.size.height - stundeLabel.frame.size.height
            stundeLabel.frame.origin.x          = stundeViewFrame.size.width - stundeLabel.frame.size.width-2
            stundeView.addSubview(stundeLabel)
            addSubview(stundeView)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@objc
protocol EintragInKalender {
    var eintragStart:Date{get}
    var eintragEnde:Date{get}
    var eintragView:UIView{get}
}

private enum moveTo:String{
    case left   = "left"
    case right  = "right"
    case top    = "top"
    case bottom = "bottom"
    var isHorizontal:Bool{
        switch self {
            case .left,.right: return true
            case .top,.bottom: return false
        }
    }
    var isVertical:Bool{
        switch self {
            case .left,.right: return false
            case .top,.bottom: return true
        }
    }
}
