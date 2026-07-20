//
//  GLOBAL.swift
//  ZielStk
//
//  Created by Alexandru on 05.09.2021.
//  Copyright © 2021 Roman Voinitchi. All rights reserved.
//

import UIKit

func topController() -> UIViewController? {
    
    if var topController = UIApplication.shared.windows.first(where: {$0.isKeyWindow})?.rootViewController {
        
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }

        return topController
    }
    
    return nil
}

// MARK: - HAPTIC
enum HAPTIC_MODE {
    case success, warning, error, light, medium, hard, tap
}
func HAPTIC_FEEDBACK(type: HAPTIC_MODE) {
    let notification = UINotificationFeedbackGenerator()
    let feedback = UIImpactFeedbackGenerator()
    
    switch type{
    case .success: notification.notificationOccurred(.success)
    case .warning: notification.notificationOccurred(.warning)
    case .error: notification.notificationOccurred(.error)
    case .light: feedback.impactOccurred()
    case .medium: feedback.impactOccurred()
    case .hard: feedback.impactOccurred()
    default: UISelectionFeedbackGenerator().selectionChanged()
    }
}

// MARK: - Extensions
extension UIViewController {
    public func showAlertMess(title: String? = nil, message: String? = nil, buttonTitle: String = "OK", completion: (() -> Void)? = nil) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelBtn = UIAlertAction(title: buttonTitle, style: .cancel) { (_) in
            completion?()
        }
        ac.addAction(cancelBtn)
        present(ac, animated: true, completion: nil)
    }
}
