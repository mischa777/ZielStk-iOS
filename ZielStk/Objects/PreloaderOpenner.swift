//
//  PreloaderOpenner.swift
//  ZielStk
//
//  Created by Roman Voinitchi on 9/9/19.
//  Copyright © 2019 Roman Voinitchi. All rights reserved.
//

import UIKit

protocol PreloaderOpennerProtocol: UIViewController {
    func showPreloader()
    func hidePreloader()
}

extension PreloaderOpennerProtocol {
    
    func showPreloader() {
        let activityView = UIView()
        activityView.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        activityView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        activityView.tag = 1113
        activityView.alpha = 0
        
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        activityIndicator.center = self.view.center
        activityIndicator.style = .whiteLarge
        activityIndicator.startAnimating()
        
        self.view.isUserInteractionEnabled = false
        activityView.addSubview(activityIndicator)
        self.view.addSubview(activityView)
        
        UIView.animate(withDuration: Constants.Timers.CommonAnimationSeconds, animations: {
            activityView.alpha = 1
        })
    }
    
    func hidePreloader() {
        self.view.isUserInteractionEnabled = true
        let activityView = self.view.viewWithTag(1113)
        if activityView != nil {
            UIView.animate(withDuration: Constants.Timers.CommonAnimationSeconds, animations: {
                activityView?.alpha = 0
            }, completion: { (tf) in
                activityView?.removeFromSuperview()
            })
        }
    }
    
}

