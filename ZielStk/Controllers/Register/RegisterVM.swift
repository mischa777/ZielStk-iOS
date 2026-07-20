//
//  RegisterVM.swift
//  ZielStk
//
//  Created by Roman Voinitchi on 9/10/19.
//  Copyright © 2019 Roman Voinitchi. All rights reserved.
//

import Foundation
import FirebaseAuth

protocol RegisterVMProtocol {
    var onError: ((String, String) -> ())? { get set }
    var onSuccess: (() -> ())? { get set }
    
    func registerWithParameters(mailString: String?, pass1String: String?, pass2String: String?)
}

final class RegisterVM: RegisterVMProtocol {
    
    var onError: ((String, String) -> ())?
    var onSuccess: (() -> ())?
    
    func registerWithParameters(mailString: String?, pass1String: String?, pass2String: String?) {
        
        guard enteredDataIsCorrect(mailString: mailString, pass1String: pass1String, pass2String: pass2String) else { return }
        
        Auth.auth().createUser(withEmail: mailString!, password: pass1String!, completion: {(user, error) in
            if error != nil {
                let title = NSLocalizedString("ErrorTitle", comment: "")
                let message = NSLocalizedString("RegisterServerError", comment: "")
                self.onError?(title, message)
            } else {
                self.onSuccess?()
            }
        })
    }
    
    private func enteredDataIsCorrect (mailString: String?, pass1String: String?, pass2String: String?) -> Bool {
        if (mailString ?? "").isEmpty || (pass1String ?? "").isEmpty || (pass2String ?? "").isEmpty {
            let title = NSLocalizedString("ErrorTitle", comment: "")
            let message = NSLocalizedString("EmptyFieldError", comment: "")
            onError?(title, message)
            return false
        } else if !CommonMethodsManager.shared.isValidEmail(emailText: mailString!) {
            let title = NSLocalizedString("ErrorTitle", comment: "")
            let message = NSLocalizedString("WrongEmailError", comment: "")
            onError?(title, message)
            return false
        } else if pass1String!.count < Constants.Values.MinPassCount {
            let title = NSLocalizedString("ErrorTitle", comment: "")
            let message = NSLocalizedString("ShortPassError", comment: "")
            onError?(title, message)
            return false
        } else if !pass1String!.elementsEqual(pass2String!) {
            let title = NSLocalizedString("ErrorTitle", comment: "")
            let message = NSLocalizedString("PasswordsDisequalError", comment: "")
            onError?(title, message)
            return false
        }
        return true
    }
    
}
