//
//  RoundedButton.swift
//  ZielStk
//
//  Created by Roman Voinitchi on 9/9/19.
//  Copyright © 2019 Roman Voinitchi. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {
    
    @IBInspectable
    var borderColor: UIColor? {
        didSet {
            self.setCornersAndShadow()
        }
    }
    @IBInspectable
    var shadowRadius: CGFloat = 1.0
    @IBInspectable
    var cornerRadius: CGFloat = 10.0
    @IBInspectable
    var shadowOffset: CGSize = CGSize(width: CGFloat(0.0), height: CGFloat(2.0))

    override func layoutSubviews() {
        super.layoutSubviews()
        setCornersAndShadow()
    }
    
    private func setCornersAndShadow() {
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = 0.5
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false
        
        if let bColor = borderColor {
            layer.borderColor = bColor.cgColor
            layer.borderWidth = 1
        } else {
            layer.borderWidth = 0
            layer.borderColor = nil
        }
    }

}
