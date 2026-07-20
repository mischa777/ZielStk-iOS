//Created on 9/30/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import Foundation
import CoreData
import FirebaseAuth

protocol UserSelectionServiceProtocol {
    func saveSelection(title: String, course: String)
    func removeSelection(title: String, course: String)
    func loadUserSelection()
    
    func getSelectedCoursesCount(stkName: String) -> Int
    func courseIsSelected(stkName: String, courseName: String) -> Bool
    func getStksSelectedTestTypes(stkName: String) -> [String]
    func getAllSelectedCourses() -> [String : [String]]
}

final class UserSelectionService: UserSelectionServiceProtocol {
    
    private var userSelections: UserSelectionModelProtocol?
    
    func loadUserSelection() {
        if let userUid = Auth.auth().currentUser?.uid {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: UserSelectionModel.UserSelectionEntityKey)
            request.predicate = NSPredicate(format: "\(UserSelectionModel.UserUidKey) == %@", userUid)
            request.returnsObjectsAsFaults = false
            
            do {
                let result = try CoreDataManager.shared.context.fetch(request)
                let objects = result as! [NSManagedObject]
                if objects.count > 0 {
                    if let coreDataSelections = UserSelectionModel(coreDataObject: objects.first!, uid: userUid) {
                        userSelections = coreDataSelections
                    } else {
                        userSelections = UserSelectionModel(uid: userUid)
                    }
                } else {
                    userSelections = UserSelectionModel(uid: userUid)
                }
            } catch {
                userSelections = UserSelectionModel(uid: userUid)
            }
        }
    }
    
    func saveSelection(title: String, course: String) {
        userSelections?.addOneSelection(title: title, course: course)
    }
    
    func removeSelection(title: String, course: String) {
        userSelections?.removeOneSelection(title: title, course: course)
    }
    
    func getSelectedCoursesCount(stkName: String) -> Int {
        if let us = userSelections {
            return us.getSelectedCoursesCount(stkName: stkName)
        }
        return 0
    }
    
    func courseIsSelected(stkName: String, courseName: String) -> Bool {
        if let us = userSelections {
            return us.courseIsSelected(stkName: stkName, courseName: courseName)
        }
        return false
    }
    
    func getStksSelectedTestTypes(stkName: String) -> [String] {
        if let us = userSelections {
            return us.getCoursesFromStk(stkName: stkName)
        }
        return [String]()
    }
    
    func getAllSelectedCourses() -> [String : [String]] {
        if let us = userSelections {
            return us.getSelections()
        }
        return [String : [String]]()
    }
}
