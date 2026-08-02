//
//  LogoutVC.swift
//  ZielStk
//
//  Created by Roman Voinitchi on 9/18/19.
//  Copyright © 2019 Roman Voinitchi. All rights reserved.
//

import UIKit
import MessageUI
import GoogleSignIn
import AuthenticationServices
import CryptoKit

class LogoutVC: UIViewController, AlertOpennerProtocol, PreloaderOpennerProtocol {

    @IBOutlet weak var mailLabel: UILabel!
    
    fileprivate var currentNonce: String?
    
    private var viewModel: LogoutVMProtocol! {
        didSet {
            self.viewModel.onLinkError = { [weak self] in
                self?.hidePreloader()
                let title = NSLocalizedString("ErrorTitle", comment: "")
                let message = NSLocalizedString("AccountLinkError", comment: "")
                self?.showAlert(title: title, message: message)
            }
            self.viewModel.onLinkSuccess = { [weak self] in
                self?.hidePreloader()
                let title = NSLocalizedString("AttentionTitle", comment: "")
                let message = NSLocalizedString("AccountLinkSuccess", comment: "")
                self?.showAlert(title: title, message: message)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = LogoutVM()
        mailLabel.text = viewModel.userMail
    }
    
    @IBAction func onMailLinkTap(_ sender: Any) {
        performSegue(withIdentifier: Constants.Segues.PasswordWindowSegue, sender: nil)
    }
    
    @IBAction func onGoogleLinkTap(_ sender: Any) {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            guard let self else { return }

            if error != nil {
                self.setGoogleSignInError()
                return
            }

            guard
                let user = result?.user,
                let idToken = user.idToken?.tokenString
            else {
                self.setGoogleSignInError()
                return
            }

            self.setGoogleDataToFirebase(
                idToken: idToken,
                accessToken: user.accessToken.tokenString
            )
        }
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
    
    @IBAction func onProblemTap(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([viewModel.projectMail])
            mail.setSubject(viewModel.mailSubject)
            if let uMail = viewModel.userMail {
                if #available(iOS 11.0, *) {
                    mail.setPreferredSendingEmailAddress(uMail)
                }
            }
            mail.setMessageBody(viewModel.mailBody, isHTML: true)
            present(mail, animated: true)
        } else {
            let coded = "mailto:\(viewModel.projectMail)?subject=\(viewModel.mailSubject)&body=\(viewModel.mailBody)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            if let emailURL = URL(string: coded!) {
                
                UIApplication.shared.open(emailURL, options: [:], completionHandler: nil)
                
            } else {
                showMailError()
            }
        }
    }
    
    @IBAction func onExitTap(_ sender: Any) {
        viewModel.logoutUser()
        if let navController = self.navigationController {
            navController.popToRootViewController(animated: true)
        } else if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.setAuthAsMain()
        }
    }
    
    private func setAppleSigninError() {
        hidePreloader()
        let title = NSLocalizedString("ErrorTitle", comment: "")
        let message = NSLocalizedString("AppleErrorMessage", comment: "")
        showAlert(title: title, message: message)
    }
    
}

extension LogoutVC: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if error != nil {
            showMailError()
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    private func showMailError() {
        let title = NSLocalizedString("ErrorTitle", comment: "")
        let message = NSLocalizedString("NoMailError", comment: "")
        showAlert(title: title, message: message)
    }
}

//MARK: protocols
extension LogoutVC: PasswordTextDelegate {
    func setEmailLinkWithPass(password: String) {
        showPreloader()
        viewModel.linkEmailWithPass(password: password)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let passwordVC = segue.destination as? PasswordWindowVC {
            passwordVC.passwordDelegate = self
        }
    }
    
    func setGoogleSignInError() {
        print("Try show google error")
        self.hidePreloader()
        let title = NSLocalizedString("ErrorTitle", comment: "")
        let message = NSLocalizedString("AccountLinkError", comment: "")
        self.showAlert(title: title, message: message)
    }
    
    func setGoogleDataToFirebase(idToken: String, accessToken: String) {
        print("Try signin with google")
        showPreloader()
        viewModel.loginWithGoogle(idToken: idToken, accessToken: accessToken)
    }
}

@available(iOS 13.0, *)
extension LogoutVC: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
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

protocol PasswordTextDelegate: UIViewController {
    func setEmailLinkWithPass(password: String)
}
