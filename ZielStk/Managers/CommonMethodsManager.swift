//
//  CommonMethodsManager.swift
//  ZielStk
//
//  Created by Roman Voinitchi on 9/11/19.
//  Copyright © 2019 Roman Voinitchi. All rights reserved.
//

import Foundation

protocol CommonMethodsManagerProtocol {
    static var shared: CommonMethodsManagerProtocol { get }
    
    func isValidEmail(emailText: String) -> Bool
}

class CommonMethodsManager: CommonMethodsManagerProtocol {
    static var shared: CommonMethodsManagerProtocol = CommonMethodsManager()
    
    func isValidEmail(emailText: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: emailText, options: [], range: NSRange(location: 0, length: emailText.count)) != nil
    }
}
