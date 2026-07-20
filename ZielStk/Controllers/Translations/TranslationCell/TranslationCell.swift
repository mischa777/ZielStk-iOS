//
//  TranslationCell.swift
//  ZielStk
//
//  Created by Roman Voinitchi on 9/19/19.
//  Copyright © 2019 Roman Voinitchi. All rights reserved.
//

import UIKit

protocol TranslationCellProtocol: UITableViewCell {
    func setCellData(translationModel: TranslationModelProtocol, editTranslationDelegate: EditTranslationDelegateProtocol)
}

class TranslationCell: UITableViewCell,TranslationCellProtocol {

    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var variantsLabel: UILabel!
    @IBOutlet weak var translationLabel: UILabel!
    @IBOutlet weak var translationView: UIView!
    
    private unowned var editDelegate: EditTranslationDelegateProtocol!
    private var translationModel: TranslationModelProtocol!
    
    func setCellData(translationModel: TranslationModelProtocol, editTranslationDelegate: EditTranslationDelegateProtocol) {
        self.translationModel = translationModel
        self.editDelegate = editTranslationDelegate
        
        wordLabel.text = translationModel.word
        variantsLabel.text = translationModel.parameters
        translationView.isHidden = translationModel.translation.isEmpty
        translationLabel.text = translationModel.translation
    }
    
    @IBAction func onAddTranslationTap(_ sender: Any) {
        editDelegate.editTranslation(tranlsationProtocol: translationModel)
    }
    
}
