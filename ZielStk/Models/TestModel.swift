//Created on 10/15/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import Foundation
import CoreData

protocol TestModelProtocol {
    var testDescriptionObject: OneDescriptionObject { get }
    var testTasks: [OneTaskModel] { get }
    var arrayOfKeys: [String] { get }
    var testName: String { get }
    
    init(firebaseDic: [String : Any], testName: String)
    init?(coreDataObject: NSManagedObject)
    
    func saveToCoreData()
    
}

final class TestModel: TestModelProtocol {
    
    static let TestsEntityKey = "Tests"
    static let NameKey = "name"
    
    var testDescriptionObject: OneDescriptionObject {
        get {
            if let currentLang = Locale.current.languageCode {
                if currentLang == "ru" {
                    return description_bd.ru
                }
            }
            return description_bd.de
        }
    }
    
    var testName: String {
        get {
            if let currentLang = Locale.current.languageCode {
                if currentLang == "ru" {
                    return description_bd.ru.name
                }
            }
            return description_bd.de.name
        }
    }
    
    var testTasks: [OneTaskModel] {
        get {
            return tasks
        }
    }
    
    var arrayOfKeys: [String] {
        get {
            if let currentLang = Locale.current.languageCode {
                if currentLang == "ru" {
                    return Array(description_bd.ru.list.keys)
                }
            }
            return Array(description_bd.de.list.keys)
        }
    }
    
    private var name: String
    private var description_bd: TestDescription
    private var tasks: [OneTaskModel]
    
    init(firebaseDic: [String : Any], testName: String) {
//        print("FIREBASE INIT")
        name = testName
        
        tasks = [OneTaskModel]()
        if let firebaseTasks = firebaseDic["Tasks"] as? [[String : String]] {
            for index in 0 ..< firebaseTasks.count {
//                print(index)
                tasks.append(OneTaskModel(firebaseDic: firebaseTasks[index], index: index))
            }
        }
        
        let firebaseDescription = firebaseDic["Description"] as! [String : Any]
        description_bd = TestDescription(firebaseDic: firebaseDescription)
    }
    
    init?(coreDataObject: NSManagedObject) {
        do {
            let descTest = coreDataObject.value(forKey: "description_bd") as! String
            let descData = descTest.data(using: .utf8)!
            let descDecoder = JSONDecoder()
            description_bd = try descDecoder.decode(TestDescription.self, from: descData)
        } catch {
            print("Cant decode description string")
            return nil
        }
        
        do {
            let tasksTest = coreDataObject.value(forKey: "tasks") as! String
            let tasksData = tasksTest.data(using: .utf8)!
            let tasksDecoder = JSONDecoder()
            tasks = try tasksDecoder.decode([OneTaskModel].self, from: tasksData)
        } catch {
            print("Cant decode tasks string")
            return nil
        }
        
        name = coreDataObject.value(forKey: "name") as! String
    }
    
    func saveToCoreData() {
        let entity = NSEntityDescription.entity(forEntityName: TestModel.TestsEntityKey, in: CoreDataManager.shared.context)
        let newTestObject = NSManagedObject(entity: entity!, insertInto: CoreDataManager.shared.context)
        
        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(description_bd)
            let jsonDescription = String(data: jsonData, encoding: .utf8)
            newTestObject.setValue(jsonDescription, forKey: "description_bd")
        } catch {
            print("TEST Failed to encode description")
            return
        }
        
        do {
            let jsonEncoder2 = JSONEncoder()
            let jsonData2 = try jsonEncoder2.encode(tasks)
            let jsonDescription2 = String(data: jsonData2, encoding: .utf8)
            newTestObject.setValue(jsonDescription2, forKey: "tasks")
        } catch {
            print("TEST Failed to encode tasks")
            return
        }
        newTestObject.setValue(name, forKey: "name")
        CoreDataManager.shared.saveContext()
    }
    
}

//MARK: - OneTaks
final class OneTaskModel: Codable {
    
    var answer: String
    var description = ""
    var task: String
    var isSolved: Bool
    var dbIndex: Int
    
    init(firebaseDic: [String : String], index: Int) {
//        print("===================")
//        print(firebaseDic)
        answer = firebaseDic["Answer"]!
        task = firebaseDic["Task"]!
        
        if let desc = firebaseDic["Description"] {
            description = desc
        }
        isSolved = false
        dbIndex = index
    }
    
}

//MARK: - Description
final class TestDescription: Codable {
    var de: OneDescriptionObject
    var ru: OneDescriptionObject
    
    init(firebaseDic: [String : Any]) {
        de = OneDescriptionObject(firebaseDic: firebaseDic["de"] as! [String : Any])
        ru = OneDescriptionObject(firebaseDic: firebaseDic["ru"] as! [String : Any])
    }
}

final class OneDescriptionObject: Codable {
    var name: String = ""
    var text: String = ""
    
    var star: [String] = [String]()
    var list: [String : String] = [String : String]()
    
    init(firebaseDic: [String : Any]) {
        if let nm = firebaseDic["name"] as? String {
            name = nm
        }
        
        if let tx = firebaseDic["text"] as? String {
            text = tx
        }
        
        if let st = firebaseDic["star"] as? [String] {
            star = st
        }
        
        if let ls = firebaseDic["list"] as? [String : String] {
            list = ls
        }
    }
}
