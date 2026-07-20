//
//  EditTranslationVC.swift
//  ZielStk
//
//  Created by Roman Voinitchi on 9/19/19.
//  Copyright © 2019 Roman Voinitchi. All rights reserved.
//

import UIKit

class EditTranslationVC: UIViewController {
    
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var translationField: UITextField!
    
    unowned var translationToChangeDelegate: TranslationToChangeDelegate!
    private var startValue: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        wordLabel.text = translationToChangeDelegate.currentTranslationModel.word
        if !translationToChangeDelegate.currentTranslationModel.translation.isEmpty {
            translationField.text = translationToChangeDelegate.currentTranslationModel.translation
        }
        startValue = translationField.text
        translationField.becomeFirstResponder()
    }
    
    @IBAction func onSaveTap(_ sender: Any) {
        if startValue != translationField.text {
            let newValue = translationField.text == nil ? "" : translationField.text!
            translationToChangeDelegate.saveTranlationWith(newTranlsation: newValue)
        }
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onBackTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
