//
//  ShadowedView.swift
//  ZielStk
//
//  Created by Roman Voinitchi on 9/17/19.
//  Copyright © 2019 Roman Voinitchi. All rights reserved.
//

import UIKit

class ShadowedView: UIView {
    
    @IBInspectable
    var shadowRadius: CGFloat = 1.0
    @IBInspectable
    var cornerRadius: CGFloat = 10.0
    @IBInspectable
    var shadowOffset: CGSize = CGSize(width: CGFloat(0.0), height: CGFloat(2.0))
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setShadow()
    }
    
    private func setShadow() {
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = 0.5
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false
    }

}
