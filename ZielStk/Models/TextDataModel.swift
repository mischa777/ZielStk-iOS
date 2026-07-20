// Created by Roman Voinitchi on 10/21/20
// Copyright © 2020 Roman Voinitchi. All rights reserved.


import Foundation
import CoreData

protocol TextDataModelProtocol {
    
    var difficulty: String { get }
    var title: String { get }
    var text: String { get }
   
    init(firebaseDic: [String : String])
    init(coreDataObject: NSManagedObject)
    
    func saveToCoreData()
}

final class TextDataModel: TextDataModelProtocol {
    
    static let TextsDataEntityKey = "TextsData"
    
    var difficulty: String
    var title: String
    var text: String
    
    init(firebaseDic: [String : String]) {
        difficulty = firebaseDic["Answer"]!
        title = firebaseDic["Description"]!
        text = firebaseDic["Task"]!
        
        print("Text firebase init \(difficulty) \(title) \(text)")
    }
    
    init(coreDataObject: NSManagedObject) {
        difficulty = coreDataObject.value(forKey: "difficulty") as! String
        title = coreDataObject.value(forKey: "title") as! String
        text = coreDataObject.value(forKey: "text") as! String
        
        print("Text coredata init \(difficulty) \(title) \(text)")
    }
    
    func saveToCoreData() {
        let entity = NSEntityDescription.entity(forEntityName: TextDataModel.TextsDataEntityKey, in: CoreDataManager.shared.context)
        let newUserObject = NSManagedObject(entity: entity!, insertInto: CoreDataManager.shared.context)
        
        newUserObject.setValue(difficulty, forKey: "difficulty")
        newUserObject.setValue(title, forKey: "title")
        newUserObject.setValue(text, forKey: "text")
        
        CoreDataManager.shared.saveContext()
    }

}
