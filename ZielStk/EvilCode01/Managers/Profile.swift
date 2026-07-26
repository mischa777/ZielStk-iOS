//
//  Profile.swift
//  ZielStk
//
//  Created by Alexandru on 07.09.2021.
//  Copyright © 2021 Roman Voinitchi. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

let db = Firestore.firestore()
func setup_FirestoreDatabase() {
    let settings = db.settings
    settings.cacheSettings = MemoryCacheSettings()
    db.settings = settings
}

class Profile {
    
    static var copyrightTrigger: Int {
        get {
            UserDefaults.standard.integer(forKey: Auth.auth().currentUser!.uid+"_copyrightTrigger")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Auth.auth().currentUser!.uid+"_copyrightTrigger")
            UserDefaults.standard.synchronize()
            
            guard newValue >= 5 else { return }
            Profile.shared.block()
        }
    }
    
    static let shared = Profile()
    private init(){}
    private var listener: ListenerRegistration?
    private(set) var subsDeleted: Bool = false
    
    
    public func sync() {
        
        guard let user = Auth.auth().currentUser else { return }
        let ref = db.collection("Users").document(user.uid)
        
        listener?.remove()
        listener = ref.addSnapshotListener({ document, error in
            
            guard error == nil else { return }
            guard let document = document, let data = document.data() else { return }
            
            self.subsDeleted = data["SubsDeleted"] as? Bool ?? false
            print("[uid] => \(document.documentID)")
            print("[subsDeleted] => \(self.subsDeleted)")
        })
    }
    public func block() {
        
        guard let user = Auth.auth().currentUser else { return }
        let ref = db.collection("Users").document(user.uid)
        ref.updateData(["SubsDeleted": true])
    }
}

class FBUser {
    
    var uid: String
    
    init(uid: String, data: [String: Any]) {
        self.uid = uid
    }
    public func update(uid: String, data: [String: Any]) {
        
    }
}
