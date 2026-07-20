//
//  Rate.swift
//  ZielStk
//
//  Created by Alexandru on 05.09.2021.
//  Copyright © 2021 Roman Voinitchi. All rights reserved.
//

import UIKit
import StoreKit
import MessageUI

class Rate: NSObject {
    
    static var appreciated: Bool {
        get {
            UserDefaults.standard.bool(forKey: "rate.appreciated")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "rate.appreciated")
            UserDefaults.standard.synchronize()
        }
    }
    static var secondsPassed: Int {
        get {
            UserDefaults.standard.integer(forKey: "rate.secondsPassed")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "rate.secondsPassed")
            UserDefaults.standard.synchronize()
        }
    }
    static var skipCount: Int {
        get {
            UserDefaults.standard.integer(forKey: "rate.skipCount")
        }
        set {
            
            if newValue == 3 {
                appreciated = true
            }
            
            UserDefaults.standard.set(newValue, forKey: "rate.skipCount")
            UserDefaults.standard.synchronize()
        }
    }
    
    static let shared = Rate()
    private override init() {}
    
    private var viewModel = LogoutVM()
    private var workItem: DispatchWorkItem?
    
    func sync() {
        
        guard !Rate.appreciated else { return }
        
        var seconds = 5
        
        if Rate.secondsPassed < (RConfig.shared.config.rate.showAfterMin * 60) {
            seconds = RConfig.shared.config.rate.showAfterMin * 60 - Rate.secondsPassed
        }
        
        workItem?.cancel()
        workItem = DispatchWorkItem(block: { self.show() })
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds), execute: workItem!)
    }
    private func show() {
        
        let ac = UIAlertController(title: NSLocalizedString("Rate_Title", comment: ""), message: NSLocalizedString("Rate_Message", comment: ""), preferredStyle: .alert)
        let yes = UIAlertAction(title: NSLocalizedString("Rate_Yes", comment: ""), style: .default) { _ in
            
            Rate.appreciated = true
            SKStoreReviewController.requestReview()
        }
        let no = UIAlertAction(title: NSLocalizedString("Rate_No", comment: ""), style: .default) { _ in
            
            self.mail()
            Rate.secondsPassed = 0
            Rate.skipCount += 1
        }
        let later = UIAlertAction(title: NSLocalizedString("Rate_Later", comment: ""), style: .cancel) { _ in
            
            self.workItem?.cancel()
            self.workItem = DispatchWorkItem(block: {
                
                self.show()
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(RConfig.shared.config.rate.laterAddedMin * 60), execute: self.workItem!)
        }
        
        ac.addAction(yes)
        ac.addAction(no)
        ac.addAction(later)
        
        topController()?.present(ac, animated: true, completion: nil)
    }
    private func mail() {
        
        let subject = NSLocalizedString("Rate_Mail_Subject", comment: "")
        let body = NSLocalizedString("Rate_Mail_Body", comment: "")
        
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([viewModel.projectMail])
            mail.setSubject(subject)
            if let uMail = viewModel.userMail {
                if #available(iOS 11.0, *) {
                    mail.setPreferredSendingEmailAddress(uMail)
                }
            }
            mail.setMessageBody(body, isHTML: true)
            topController()?.present(mail, animated: true)
        } else {
            let coded = "mailto:\(viewModel.projectMail)?subject=\(subject)&body=\(body)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            guard let emailURL = URL(string: coded!) else { return }
            UIApplication.shared.open(emailURL, options: [:], completionHandler: nil)
        }
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension Rate: MFMailComposeViewControllerDelegate {
    
}
