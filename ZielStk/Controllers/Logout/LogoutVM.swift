//
//  LogoutVM.swift
//  ZielStk
//
//  Created by Roman Voinitchi on 9/20/19.
//  Copyright © 2019 Roman Voinitchi. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

//MARK: -protocol
protocol LogoutVMProtocol {
    var onLinkError: (() -> ())? { get set }
    var onLinkSuccess: (() -> ())? { get set }
    
    var userMail: String? { get }
    var mailBody: String { get }
    var projectMail: String { get }
    var mailSubject: String { get }
    
    func logoutUser()
    func linkEmailWithPass(password: String)
    func loginWithGoogle(idToken: String, accessToken: String)
    func getRandomNonceString(length: Int) -> String
    func loginWithApple(idToken: String, rawNonce: String)
}

//MARK: -View model class
struct LogoutVM: LogoutVMProtocol {
    
    var onLinkError: (() -> ())?
    var onLinkSuccess: (() -> ())?
    
    var projectMail: String {
        get {
            return "zielstudienkolleg@gmail.com"
        }
    }
    
    var mailSubject: String {
        get {
            return "Report IOS problem"
        }
    }
    
    var userMail: String? {
        get {
            return Auth.auth().currentUser?.email
        }
    }
    
    var mailBody: String {
        get {
            let deviceModel = "Device: \(UIDevice.current.model)"
            let deviceIosVersion = "IOS version: \(UIDevice.current.systemVersion)"
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            
            var finalBody = "<p>\(deviceModel)</p><p>\(deviceIosVersion)</p>"
            
            if let appV = appVersion {
                finalBody += "<p>Build: \(appV)</p>"
            }
            if let uMail = Auth.auth().currentUser?.email {
                finalBody += "<p>Sender: \(uMail)</p>"
            }
            return finalBody
        }
    }
    
    func logoutUser() {
        do {
            GIDSignIn.sharedInstance.signOut()
            try Auth.auth().signOut()
        } catch let error {
            print("Error in signout \(error.localizedDescription)")
        }
    }
    
    func linkEmailWithPass(password: String) {
        if let email = Auth.auth().currentUser?.email {
            let emailCredential = EmailAuthProvider.credential(withEmail: email, password: password)
            Auth.auth().currentUser!.link(with: emailCredential, completion: { authResult, error in
                if error != nil {
                    self.onLinkError?()
                } else {
                    self.onLinkSuccess?()
                }
            })
        } else {
            onLinkError?()
        }
    }
    
    func loginWithGoogle(idToken: String, accessToken: String) {
        if let user = Auth.auth().currentUser {
            let googleCredentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            user.link(with: googleCredentials, completion: { authResult, error in
                if error != nil {
                    self.onLinkError?()
                } else {
                    self.onLinkSuccess?()
                }
            })
        } else {
            onLinkError?()
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
        if let user = Auth.auth().currentUser {
            let credential = OAuthProvider.appleCredential(
                withIDToken: idToken,
                rawNonce: rawNonce,
                fullName: nil
            )
            user.link(with: credential, completion: { authResult, error in
                if error != nil {
                    self.onLinkError?()
                } else {
                    self.onLinkSuccess?()
                }
            })
        } else {
            onLinkError?()
        }
    }
    
}
