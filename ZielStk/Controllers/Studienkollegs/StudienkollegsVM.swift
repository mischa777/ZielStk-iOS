//Created on 10/7/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import Foundation
import FirebaseAuth

protocol StudienkollegsVMProtocol {
    var onUserStksLoaded: (() -> ())? { get set }
//    var onVerificationSent: (() -> ())? { get set }
    var userStks: [StkModelProtocol] { get }
    
    func loadUserStks()
//    func checkVerification()
}

final class StudienkollegsVM: StudienkollegsVMProtocol {
    
    var onUserStksLoaded: (() -> ())?
//    var onVerificationSent: (() -> ())?
    
    var userStks: [StkModelProtocol] {
        get {
            return usersStksService.userStks
        }
    }
    private var usersStksService: UserStksServiceProtocol
    
    init() {
        usersStksService = UserStksService()
    }
    
    func loadUserStks() {
        usersStksService.onStksLoaded = onUserStksLoaded
        usersStksService.loadUserSelections()
    }
    
//    func checkVerification() {
//        if let user = Auth.auth().currentUser {
//            if !user.isEmailVerified {
//                user.sendEmailVerification(completion: nil)
//                onVerificationSent?()
//            }
//        }
//    }
    
}
