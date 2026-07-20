//
//  AlertOpenner.swift
//  ZielStk
//
//  Created by Roman Voinitchi on 9/10/19.
//  Copyright © 2019 Roman Voinitchi. All rights reserved.
//

import UIKit

protocol AlertOpennerProtocol: UIViewController {
    func showAlert(title: String, message: String)
}

extension AlertOpennerProtocol {
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
