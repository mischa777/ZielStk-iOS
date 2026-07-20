//
//  RConfig.swift
//  ZielStk
//
//  Created by Alexandru on 05.09.2021.
//  Copyright © 2021 Roman Voinitchi. All rights reserved.
//

import UIKit
import FirebaseRemoteConfig

class RConfig {
    
    static let shared = RConfig()
    private init() {}
    
    private lazy var remoteConfig: RemoteConfig = {
        
        let settings = RemoteConfigSettings()
        #if DEBUG
        settings.minimumFetchInterval = 0
        #else
        settings.minimumFetchInterval = 3600
        #endif
        
        let remoteConfig = RemoteConfig.remoteConfig()
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults([:])
        
        return remoteConfig
    }()
    private(set) var config = Config(rate: [:]) {
        didSet {
            print("[RemoteConfig] => true")
            Rate.shared.sync()
        }
    }
    public func sync(completion: ((Error?) -> Void)?) {
        
        remoteConfig.fetch { (status, error) in
            if status == .success {
                self.remoteConfig.activate() { (changed, error) in
                    let rate: [String: Any] = self.remoteConfig["Rate"].jsonValue as? [String: Any] ?? [:]
                    self.config = Config(rate: rate)
                }
            } else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
            completion?(error)
        }
    }
}

// MARK: - Model
extension RConfig {
    
    struct Config {
        
        let rate: Rate
        
        init(rate: [String: Any]) {
            self.rate = Rate(data: rate)
        }
        
        
        struct Rate {
            let showAfterMin: Int
            let laterAddedMin: Int
            init(data: [String: Any]) {
                self.showAfterMin = data["showAfterMin"] as? Int ?? 60
                self.laterAddedMin = data["laterAddedMin"] as? Int ?? 1
            }
        }
    }
}
