//
//  AlertNotificationVC.swift
//  ZielStk
//
//  Created by German Polyansky on 13.05.2021.
//  Copyright © 2021 Roman Voinitchi. All rights reserved.
//

import UIKit

class AlertNotificationVC: UIViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var alertImageContainerView: UIView!
    @IBOutlet weak var alertIconImageView: UIImageView!
    
    @IBOutlet weak var notificationTitleLabel: UILabel!
    @IBOutlet weak var notificationTextView: UITextView!
    @IBOutlet weak var notificationTextViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var notificationImageView: UIImageView!
    @IBOutlet weak var notificationImageViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var okButton: RoundedButton!
    
    var notificationTitleText = ""
    var notificationDescriptionText = ""
    var notificationImageURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setup()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.notificationTextView.contentSize.height < self.view.bounds.height / 5 {
            self.notificationTextViewHeight.constant = self.notificationTextView.contentSize.height
        } else {
            self.notificationTextViewHeight.constant = self.view.bounds.height / 5
        }
        
        if !self.notificationImageURL.isEmpty {
            self.notificationImageViewHeight.constant = self.view.bounds.height / 5
        }
        
        self.view.layoutIfNeeded()
    }
    
    @IBAction func onTapOkButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AlertNotificationVC {
    func setup() {
        self.setupAppearance()
        self.setupContent()
    }
    
    func setupAppearance() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        self.containerView.layer.cornerRadius = 10
        self.containerView.layer.masksToBounds = true
        self.alertImageContainerView.layer.cornerRadius = alertImageContainerView.bounds.height/2
        self.alertImageContainerView.layer.masksToBounds = true
    }
    
    func setupContent() {
        self.notificationTitleLabel.text = self.notificationTitleText
        self.notificationTextView.text = self.notificationDescriptionText
        
        if let url = URL.init(string: self.notificationImageURL) {
            self.notificationImageView.sd_setImage(with: url, completed: nil)
        }
    }
}
