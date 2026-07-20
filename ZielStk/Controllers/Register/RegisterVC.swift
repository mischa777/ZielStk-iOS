//
//  RegisterVC.swift
//  ZielStk
//
//  Created by Roman Voinitchi on 9/9/19.
//  Copyright © 2019 Roman Voinitchi. All rights reserved.
//

import UIKit

class RegisterVC: UIViewController, AlertOpennerProtocol, PreloaderOpennerProtocol {

    @IBOutlet weak var firstPassField: UITextField!
    @IBOutlet weak var secondPassField: UITextField!
    @IBOutlet weak var mailTextField: UITextField!
    
    private var viewModel: RegisterVMProtocol! {
        didSet {
            self.viewModel.onSuccess = { [weak self] in
                self?.hidePreloader()
                self?.performSegue(withIdentifier: Constants.Segues.Studienkolleg, sender: nil)
            }
            self.viewModel.onError = { [weak self] (title, message) in
                self?.hidePreloader()
                self?.showAlert(title: title, message: message)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = RegisterVM()
        firstPassField.delegate = self
        secondPassField.delegate = self
        mailTextField.delegate = self
    }
    
    @IBAction func onRegisterTap(_ sender: Any) {
        showPreloader()
        viewModel.registerWithParameters(mailString: mailTextField.text, pass1String: firstPassField.text, pass2String: secondPassField.text)
    }
    
    @IBAction func onCancelTap(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onPrivacyTap(_ sender: Any) {
        if let url = URL(string: "https://apple.com") {
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
        }
    }
    
    @IBAction func onAgreementTap(_ sender: Any) {
        if let url = URL(string: "https://apple.com") {
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
        }
    }
    
}

extension RegisterVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == mailTextField {
            textField.resignFirstResponder()
            firstPassField.becomeFirstResponder()
            return false
        } else if textField == firstPassField {
            textField.resignFirstResponder()
            secondPassField.becomeFirstResponder()
            return false
        } else if textField == secondPassField {
            textField.resignFirstResponder()
            onRegisterTap(self)
            return false
        }
        return true
    }
    
}
