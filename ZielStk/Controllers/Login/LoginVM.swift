//
//  LoginVM.swift
//  ZielStk
//
//  Created by Roman Voinitchi on 9/11/19.
//  Copyright © 2019 Roman Voinitchi. All rights reserved.
//

import UIKit
import Foundation
import FirebaseAuth
import GoogleSignIn

protocol LoginVMProtocol {
    var onError: ((String, String) -> ())? { get set }
    var onRememberSuccess: ((String, String) -> ())? { get set }
    var onLoginSuccess: (() -> ())? { get set }
    
    func rememberPassword(mailString: String?)
    func loginWith(mailString: String?, passwordString: String?)
    func loginWithGoogle(idToken: String, accessToken: String)
    func setSignOut()
    func getRandomNonceString(length: Int) -> String
    func loginWithApple(idToken: String, rawNonce: String)
}

final class LoginVM: LoginVMProtocol {
    
    var onRememberSuccess: ((String, String) -> ())?
    var onLoginSuccess: (() -> ())?
    var onError: ((String, String) -> ())?
    
    func loginWith(mailString: String?, passwordString: String?) {
        guard loginDataIsCorrect(mailString: mailString, passwordString: passwordString) else { return }
        
        Auth.auth().signIn(withEmail: mailString!, password: passwordString!, completion: {(user, error) in
            if error != nil || user == nil {
                let title = NSLocalizedString("ErrorTitle", comment: "")
                let message = NSLocalizedString("NoUserError", comment: "")
                self.onError?(title, message)
            } else {
                self.onLoginSuccess?()
            }
        })
    }
    
    private func loginDataIsCorrect(mailString: String?, passwordString: String?) -> Bool {
        if (mailString ?? "").isEmpty || (passwordString ?? "").isEmpty {
            let title = NSLocalizedString("ErrorTitle", comment: "")
            let message = NSLocalizedString("EmptyFieldError", comment: "")
            onError?(title, message)
            return false
        } else if !CommonMethodsManager.shared.isValidEmail(emailText: mailString!) {
            let title = NSLocalizedString("ErrorTitle", comment: "")
            let message = NSLocalizedString("WrongEmailError", comment: "")
            onError?(title, message)
            return false
        } else if passwordString!.count < Constants.Values.MinPassCount {
            let title = NSLocalizedString("ErrorTitle", comment: "")
            let message = NSLocalizedString("ShortPassError", comment: "")
            onError?(title, message)
            return false
        }
        return true
    }
    
    func rememberPassword(mailString: String?) {
        guard rememberedEmailIsCorrect(mailString: mailString) else { return }
        
        Auth.auth().sendPasswordReset(withEmail: mailString!, completion: { (error) in
            if error != nil {
                let title = NSLocalizedString("ErrorTitle", comment: "")
                let message = NSLocalizedString("RememberPasswordError", comment: "")
                self.onError?(title, message)
            } else {
                let title = NSLocalizedString("AttentionTitle", comment: "")
                let message = NSLocalizedString("PasswordSent", comment: "")
                self.onRememberSuccess?(title, message)
            }
        })
    }
    
    private func rememberedEmailIsCorrect(mailString: String?) -> Bool {
        if (mailString ?? "").isEmpty {
            let title = NSLocalizedString("ErrorTitle", comment: "")
            let message = NSLocalizedString("EmptyEmailError", comment: "")
            onError?(title, message)
            return false
        } else if !CommonMethodsManager.shared.isValidEmail(emailText: mailString!) {
            let title = NSLocalizedString("ErrorTitle", comment: "")
            let message = NSLocalizedString("WrongEmailError", comment: "")
            onError?(title, message)
            return false
        }
        return true
    }
    
    //MARK: - Social part
    func loginWithGoogle(idToken: String, accessToken: String) {
        let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        Auth.auth().signIn(with: credentials, completion: {(authResult, error) in
            if error != nil {
                self.setSignOut()
                let title = NSLocalizedString("ErrorTitle", comment: "")
                let message = NSLocalizedString("GoogleErrorMessage", comment: "")
                self.onError?(title, message)
            } else {
                self.onLoginSuccess?()
            }
        })
    }
    
    func setSignOut() {
        do {
            GIDSignIn.sharedInstance.signOut()
            try Auth.auth().signOut()
        } catch let error {
            print("Error in signout \(error.localizedDescription)")
        }
    }
    
    //MARK: Apple
    func getRandomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            randoms.forEach { random in
                if length == 0 {
                    return
                }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    func loginWithApple(idToken: String, rawNonce: String) {
        let credential = OAuthProvider.appleCredential(
            withIDToken: idToken,
            rawNonce: rawNonce,
            fullName: nil
        )
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if error != nil {
                print(error!)
                self.setSignOut()
                let title = NSLocalizedString("ErrorTitle", comment: "")
                let message = NSLocalizedString("AppleErrorMessage", comment: "")
                self.onError?(title, message)
            } else {
                self.onLoginSuccess?()
            }
        }
    }
    
}
