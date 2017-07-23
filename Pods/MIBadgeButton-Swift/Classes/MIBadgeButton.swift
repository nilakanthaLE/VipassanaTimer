//
//  MIBadgeButton.swift
//  MIBadgeButton
//
//  Created by Yosemite on 8/27/14.
//  Copyright (c) 2014 Youxel Technology. All rights reserved.
//

import UIKit

open class MIBadgeButton: UIButton {
    
    fileprivate var badgeLabel: UILabel
    
    open var badgeString: String? {
        didSet {
            setupBadgeViewWithString(badgeText: badgeString)
        }
    }
    
    @objc
    open var badgeEdgeInsets: UIEdgeInsets = .zero {
        didSet {
            setupBadgeViewWithString(badgeText: badgeString)
        }
    }
    
    open var badgeBackgroundColor = UIColor.red {
        didSet {
            badgeLabel.backgroundColor = badgeBackgroundColor
        }
    }
    
    open var badgeTextColor = UIColor.white {
        didSet {
            badgeLabel.textColor = badgeTextColor
        }
    }

    override public init(frame: CGRect) {
        badgeLabel = UILabel()
        super.init(frame: frame)
        // Initialization code
        setupBadgeViewWithString(badgeText: "")
    }
    var widthConstraint:NSLayoutConstraint?
    required public init?(coder aDecoder: NSCoder) {
        badgeLabel = UILabel()
        
        
        super.init(coder: aDecoder)
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: badgeLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 2))
        addConstraint(NSLayoutConstraint(item: badgeLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -2))
        addConstraint(NSLayoutConstraint(item: badgeLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute  , multiplier: 1.0, constant: 14))
        setupBadgeViewWithString(badgeText: "")
        widthConstraint = NSLayoutConstraint(item: badgeLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute  , multiplier: 1.0, constant: 14)
        addConstraint(widthConstraint!)
        setupBadgeViewWithString(badgeText: "")
    }
    
    open func initWithFrame(frame: CGRect, withBadgeString badgeString: String, withBadgeInsets badgeInsets: UIEdgeInsets) -> AnyObject {
        
        badgeLabel = UILabel()
        badgeEdgeInsets = badgeInsets
        setupBadgeViewWithString(badgeText: badgeString)
        return self
    }
    
    fileprivate func setupBadgeViewWithString(badgeText: String?) {
        badgeLabel.clipsToBounds = true
        badgeLabel.text = badgeText
        badgeLabel.font = UIFont.systemFont(ofSize: 12)
        badgeLabel.textAlignment = .center
        badgeLabel.sizeToFit()
        let badgeSize = badgeLabel.frame.size
        
        widthConstraint?.constant = badgeSize.width + 2 > 14 ? badgeSize.width + 2 : 14
        
        let height = max(20, Double(badgeSize.height) + 5.0)
        let width = max(height, Double(badgeSize.width) + 10.0)
        
        var vertical: Double?, horizontal: Double?
        let badgeInset = self.badgeEdgeInsets
        vertical = Double(badgeInset.top) - Double(badgeInset.bottom)
        horizontal = Double(badgeInset.left) - Double(badgeInset.right)
        
        let x = (Double(bounds.size.width) - 10 + horizontal!)
        let y = -(Double(badgeSize.height) / 2) - 10 + vertical!
        badgeLabel.frame = CGRect(x: x, y: y, width: width, height: height)
        
        setupBadgeStyle()
        addSubview(badgeLabel)
        
        if let text = badgeText {
            badgeLabel.isHidden = text != "" ? false : true
        } else {
            badgeLabel.isHidden = true
        }
        
        badgeLabel.sizeToFit()
    }
    
    fileprivate func setupBadgeStyle() {
        badgeLabel.textAlignment = .center
        badgeLabel.backgroundColor = badgeBackgroundColor
        badgeLabel.textColor = badgeTextColor
        badgeLabel.layer.cornerRadius = 14 / 2
    }
    
}
