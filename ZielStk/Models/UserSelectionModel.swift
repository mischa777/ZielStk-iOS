//Created on 9/30/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import Foundation
import CoreData

protocol UserSelectionModelProtocol {
    init? (coreDataObject: NSManagedObject, uid: String)
    init (uid: String)
    
    func addOneSelection(title: String, course: String)
    func removeOneSelection(title: String, course: String)
    func getSelectedCoursesCount(stkName: String) -> Int
    func courseIsSelected(stkName: String, courseName: String) -> Bool
    func getStksNames() -> [String]
    func getCoursesFromStk(stkName: String) -> [String]
    func getSelections() -> [String : [String]]
}

final class UserSelectionModel: UserSelectionModelProtocol {
    
    static let UserSelectionEntityKey = "UserSelections"
    static let UserUidKey = "uid"
    
    private var containterSelections: SelectionsContainer
    private var uid: String
    
    init(uid: String) {
        self.uid = uid
        containterSelections = SelectionsContainer()
        saveToCoreData()
    }
    
    init?(coreDataObject: NSManagedObject, uid: String) {
        do {
            let coursesText = coreDataObject.value(forKey: "selections_string") as! String
            let jsonData = coursesText.data(using: .utf8)!
            let jsonDecoder = JSONDecoder()
            containterSelections = try jsonDecoder.decode(SelectionsContainer.self, from: jsonData)
        } catch {
            print("Cant decode courses string")
            return nil
        }
        self.uid = uid
    }
    
    private func saveToCoreData() {
        let entity = NSEntityDescription.entity(forEntityName: UserSelectionModel.UserSelectionEntityKey, in: CoreDataManager.shared.context)
        let newStkObject = NSManagedObject(entity: entity!, insertInto: CoreDataManager.shared.context)
        
        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(containterSelections)
            let jsonSelectionsString = String(data: jsonData, encoding: .utf8)
            newStkObject.setValue(jsonSelectionsString, forKey: "selections_string")
        } catch {
            print("SELECTION Failed to encode selections")
            return
        }
//        print("SELECTION encoded")
        newStkObject.setValue(uid, forKey: "uid")
        CoreDataManager.shared.saveContext()
    }
    
    func addOneSelection(title: String, course: String) {
        containterSelections.addOneSelection(title: title, course: course)
        saveToCoreData()
    }
    
    func removeOneSelection(title: String, course: String) {
        containterSelections.removeOneSelection(title: title, course: course)
        saveToCoreData()
    }
    
    func getSelectedCoursesCount(stkName: String) -> Int {
        return containterSelections.getCoursesCount(title: stkName)
    }
    
    func courseIsSelected(stkName: String, courseName: String) -> Bool {
        return containterSelections.courseIsSelected(title: stkName, courseName: courseName)
    }
    
    func getStksNames() -> [String] {
        return containterSelections.getStksNames()
    }
    
    func getCoursesFromStk(stkName: String) -> [String] {
        return containterSelections.getCoursesFromStk(stkName: stkName)
    }
    
    func getSelections() -> [String : [String]] {
        return containterSelections.allSelections
    }
}

//MARK: - Selected courses
fileprivate final class SelectionsContainer: Codable {
    var allSelections: [String : [String]]

    init() {
        allSelections = [String : [String]]()
    }

    init(selections: [String : [String]]) {
        allSelections = selections
    }
    
    func addOneSelection(title: String, course: String) {
        if allSelections[title] != nil {
            allSelections[title]!.append(course)
        } else {
            allSelections[title] = [course]
        }
//        print("SELECTION   \(title) = \(allSelections[title]!)")
    }
    
    func removeOneSelection(title: String, course: String) {
        if allSelections[title] != nil {
            allSelections[title]! = allSelections[title]!.filter{ $0 != course}
            if allSelections[title]!.count == 0 {
                allSelections.removeValue(forKey: title)
            }
        }
    }
    
    func getCoursesCount(title: String) -> Int {
//        print("SELECTION   \(title) = \(allSelections[title]?.count ?? -1)")
        if allSelections[title] != nil {
            return allSelections[title]!.count
        }
        return 0
    }
    
    func courseIsSelected(title: String, courseName: String) -> Bool {
        if allSelections[title] != nil {
            return allSelections[title]!.contains(courseName)
        }
        return false
    }
    
    func getStksNames() -> [String] {
        return Array(allSelections.keys.map { String($0) })
    }
    
    func getCoursesFromStk(stkName: String) -> [String] {
        if allSelections[stkName] != nil {
            return allSelections[stkName]!
        }
        return [String]()
    }
}
