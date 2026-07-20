//Created on 9/26/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import Foundation
import FirebaseFirestore
import CoreData

protocol TranslationsVMProtocol {
    var onError: ((String, String) -> ())? { get set }
    var onTranslationsReady: (() -> ())? { get set }
    
    var tranlations: [TranslationModelProtocol] { get }
    var searchedString: String? { get set }
    
    func loadTranslations(needFirebaseLoad: Bool)
    func clearData()
}

final class TranslationsVM: TranslationsVMProtocol {
    
    var onError: ((String, String) -> ())?
    var onTranslationsReady: (() -> ())?
    
    var tranlations: [TranslationModelProtocol] {
        get {
            return filteredTranslations
        }
    }
    var searchedString: String? {
        didSet {
            self.filterAllTranslations()
        }
    }
    
    private var allTranslations = [TranslationModelProtocol]()
    private var filteredTranslations = [TranslationModelProtocol]()
    
    func loadTranslations(needFirebaseLoad: Bool) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: TranslationModel.TranslationsEntityKey)
        request.returnsObjectsAsFaults = false
        do {
            let result = try CoreDataManager.shared.context.fetch(request)
            let objects = result as! [NSManagedObject]
            if objects.count > 0 {
                for data in objects {
                    let translation = TranslationModel(
                        word: data.value(forKey: TranslationModel.TranlationsWordKey) as! String,
                        params: data.value(forKey: TranslationModel.TranlationsParametersKey) as! String,
                        trans: data.value(forKey: TranslationModel.TranlationsTranslationKey) as! String)
                    allTranslations.append(translation)
                }
                filterAllTranslations()
            } else {
                if needFirebaseLoad {
                    loadFirebaseTranslations()
                } else {
                    setTranslationLoadError()
                }
            }
        } catch {
            if needFirebaseLoad {
                loadFirebaseTranslations()
            } else {
                setTranslationLoadError()
            }
        }
    }
    
    private func filterAllTranslations() {
        filteredTranslations.removeAll()
        if (searchedString ?? "").isEmpty {
            filteredTranslations = allTranslations.map { $0 }
        } else {
            filteredTranslations = allTranslations.filter {
                $0.word.lowercased().contains(searchedString!.lowercased())
            }
        }
        filteredTranslations.sort { $0.word < $1.word }
        onTranslationsReady?()
    }
    
    func clearData() {
        allTranslations.removeAll()
        filteredTranslations.removeAll()
    }
    
    private func setTranslationLoadError() {
        let title = NSLocalizedString("ErrorTitle", comment: "")
        let message = NSLocalizedString("NoTranslationsError", comment: "")
        onError?(title, message)
    }
    
    //MARK: - Firebase part
    private func loadFirebaseTranslations() {
        let db = Firestore.firestore()
        let translationsRef = db.collection(Constants.FirebaseTables.Translations)
        translationsRef.getDocuments(completion: { [weak self] (querySnapshot, error) in
            if error != nil {
                self?.setTranslationLoadError()
            } else {
                if querySnapshot!.isEmpty {
                    self?.setTranslationLoadError()
                } else {
                    for document in querySnapshot!.documents {
                        self?.parseFirebaseTranslations(translationsDictionaries: document.data())
                    }
                }
            }
        })
    }
    
    private func parseFirebaseTranslations(translationsDictionaries: [String : Any]) {
        for (key, value) in translationsDictionaries {
            let description = value as! [String : String]
            let translation = TranslationModel(word: key, params: description[TranslationModel.FirebaseParametersKey] ?? "", trans: description[TranslationModel.FirebaseTranslationKey] ?? "")
            translation.saveToCoreData()
        }
        loadTranslations(needFirebaseLoad: false)
    }
    
}
