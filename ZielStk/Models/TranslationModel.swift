//Created on 9/26/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import Foundation
import CoreData

protocol TranslationModelProtocol {
    var word: String { get }
    var parameters: String { get }
    var translation: String { get set }
    
    init (word: String, params: String, trans: String)
    func saveToCoreData()
}

final class TranslationModel: TranslationModelProtocol {
    
    static let FirebaseParametersKey = "Params"
    static let FirebaseTranslationKey = "Trans"
    static let TranslationsEntityKey = "Translations"
    static let TranlationsWordKey = "word"
    static let TranlationsParametersKey = "parameters"
    static let TranlationsTranslationKey = "translation"
    
    var word: String
    var parameters: String
    var translation: String
    
    init(word: String, params: String, trans: String) {
        self.word = word
        parameters = params
        translation = trans
    }
    
    func saveToCoreData() {
        let entity = NSEntityDescription.entity(forEntityName: TranslationModel.TranslationsEntityKey, in: CoreDataManager.shared.context)
        let newTranslation = NSManagedObject(entity: entity!, insertInto: CoreDataManager.shared.context)
        newTranslation.setValue(word, forKey: TranslationModel.TranlationsWordKey)
        newTranslation.setValue(parameters, forKey: TranslationModel.TranlationsParametersKey)
        newTranslation.setValue(translation, forKey: TranslationModel.TranlationsTranslationKey)
        CoreDataManager.shared.saveContext()
    }

}
