//Created on 11/15/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import UIKit

class PasswordWindowVC: UIViewController, AlertOpennerProtocol {
    
    @IBOutlet weak var passTextField: UITextField!
    
    unowned var passwordDelegate: PasswordTextDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passTextField.becomeFirstResponder()
    }
    
    @IBAction func onCancelTap(_ sender: Any) {
        passTextField.resignFirstResponder()
        if let nc = navigationController {
            nc.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func onOkTap(_ sender: Any) {
        let passText = (passTextField.text ?? "")
        if passText.count < Constants.Values.MinPassCount {
            let title = NSLocalizedString("ErrorTitle", comment: "")
            let message = NSLocalizedString("ShortPassError", comment: "")
            showAlert(title: title, message: message)
        } else {
            passwordDelegate.setEmailLinkWithPass(password: passText)
            onCancelTap(self)
        }
    }
    
}
