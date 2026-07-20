//
//  LoginVC.swift
//  ZielStk
//
//  Created by Roman Voinitchi on 9/9/19.
//  Copyright © 2019 Roman Voinitchi. All rights reserved.
//

import UIKit
import GoogleSignIn
import AuthenticationServices
import CryptoKit

class LoginVC: UIViewController, PreloaderOpennerProtocol, AlertOpennerProtocol {
    
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    
    fileprivate var currentNonce: String?
    
    private var viewModel: LoginVMProtocol! {
        didSet {
            self.viewModel.onLoginSuccess = { [weak self]  in
                self?.hidePreloader()
                self?.performSegue(withIdentifier: Constants.Segues.Studienkolleg, sender: nil)
            }
            self.viewModel.onRememberSuccess = { [weak self] (title, message) in
                self?.hidePreloader()
                self?.showAlert(title: title, message: message)
            }
            self.viewModel.onError = { [weak self] (title, message) in
                self?.hidePreloader()
                self?.showAlert(title: title, message: message)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = LoginVM()
        mailTextField.delegate = self
        passTextField.delegate = self
        viewModel.setSignOut()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func onLoginTap(_ sender: Any) {
        showPreloader()
        viewModel.loginWith(mailString: mailTextField.text, passwordString: passTextField.text)
    }
    
    @IBAction func onRegisterTap(_ sender: Any) {
        performSegue(withIdentifier: Constants.Segues.Register, sender: self)
    }
    
    @IBAction func onGoogleTap(_ sender: Any) {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            guard let self else { return }

            if error != nil {
                self.setGoogleSignInError()
                self.viewModel.setSignOut()
                return
            }

            guard
                let user = result?.user,
                let idToken = user.idToken?.tokenString
            else {
                self.setGoogleSignInError()
                self.viewModel.setSignOut()
                return
            }

            self.setGoogleDataToFirebase(
                idToken: idToken,
                accessToken: user.accessToken.tokenString
            )
        }
    }
    
    @IBAction func onFBTap(_ sender: Any) {
        showPreloader()
        viewModel.loginWithFB(parentController: self)
    }
    
    @IBAction func onAppleTap(_ sender: Any) {
        if #available(iOS 13, *) {
            showPreloader()
            setAppleSignIn()
        } else {
            let title = NSLocalizedString("ErrorTitle", comment: "")
            let message = NSLocalizedString("AppleAuthError", comment: "")
            showAlert(title: title, message: message)
        }
    }
    
    @IBAction func onRememberPassTap(_ sender: Any) {
        showPreloader()
        viewModel.rememberPassword(mailString: mailTextField.text)
    }
    
}
//MARK: - textfield delegate
extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == mailTextField {
            textField.resignFirstResponder()
            passTextField.becomeFirstResponder()
            return false
        } else if textField == passTextField {
            textField.resignFirstResponder()
            onLoginTap(self)
            return false
        }
        return true
    }
}
//MARK: - Social part
extension LoginVC {
    func setGoogleSignInError() {
        hidePreloader()
        let title = NSLocalizedString("ErrorTitle", comment: "")
        let message = NSLocalizedString("GoogleErrorMessage", comment: "")
        showAlert(title: title, message: message)
    }
    
    func setGoogleDataToFirebase(idToken: String, accessToken: String) {
        showPreloader()
        viewModel.loginWithGoogle(idToken: idToken, accessToken: accessToken)
    }
    
    private func setAppleSigninError() {
        hidePreloader()
        let title = NSLocalizedString("ErrorTitle", comment: "")
        let message = NSLocalizedString("AppleErrorMessage", comment: "")
        showAlert(title: title, message: message)
    }
    
}

@available(iOS 13.0, *)
extension LoginVC: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return ASPresentationAnchor(frame: self.view.frame)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        hidePreloader()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                print("Invalid state: A login callback was received, but no login request was sent.")
                setAppleSigninError()
                return
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                setAppleSigninError()
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                setAppleSigninError()
                return
            }
            viewModel.loginWithApple(idToken: idTokenString, rawNonce: nonce)
        } else {
            setAppleSigninError()
        }
    }
    
    private func setAppleSignIn() {
        let nonce = viewModel.getRandomNonceString(length: 32)
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}
