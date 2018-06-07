//
//  MeditationsPlatzView.swift
//  Vipassana
//
//  Created by Matthias Pochmann on 08.05.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift



@IBDesignable class MeditationsPlatzView: NibLoadingView {
    var viewModel:MeditationsPlatzViewModel!{
        didSet{
            userNameLabel.reactive.text <~ viewModel.meditationsPlatzTitle.producer
            viewModel.meditationsPlatzTitle.signal.observe{[weak self] _ in self?.setFontSize()}
        }
    }
    
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var backGroundView: UIView!{
        didSet{
            backGroundView.layer.borderColor    = standardRahmenFarbe.cgColor
            backGroundView.layer.borderWidth    = standardBorderWidth
            backGroundView.layer.cornerRadius   = standardCornerRadius
            clipsToBounds = true
        }
    }
    
    var currentLabelSize:CGSize = CGSize.zero
    override func layoutSubviews() {
        print("MeditationsPlatzView layoutSubviews")
        if currentLabelSize != userNameLabel.frame.size{ setFontSize() }
        currentLabelSize = userNameLabel.frame.size
    }
    
    func setFontSize(){
        guard let text = userNameLabel.text, !text.isEmpty else {return}
        let fontSize        = userNameLabel.font.getFontSize(for: userNameLabel.text, in: userNameLabel.frame)
        userNameLabel.font  = UIFont(name: userNameLabel.font.fontName, size: fontSize )
    }
}

@IBDesignable class MeditationsPlatzCell: UICollectionViewCell {
    var viewModel:MeditationsPlatzCellViewModel!{  didSet{ meditationsPlatzView.viewModel = viewModel.meditationsPlatzViewModel } }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var meditationsPlatzView: MeditationsPlatzView!
    
}


extension UIFont{
    func getFontSize(for string:String?, in rect:CGRect) -> CGFloat{
        var ergebnis:CGFloat = 0
        let label       = UILabel()
        label.text      = string ?? "?"
        label.font      = UIFont(name: self.fontName, size: 10)
        label.sizeToFit()
        repeat {
            ergebnis    = label.font.pointSize + 0.5
            label.font  = UIFont(name: self.fontName, size: ergebnis )
            label.sizeToFit()
        } while (label.frame.height < rect.height)
        return ergebnis
    }
}
