//Created on 10/15/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import Foundation
import CoreData
import FirebaseFirestore

protocol TestsServiceProtocol {
    var onTestLoaded: (() -> ())? { get set }
    var onNoPermissions: (() -> ())? { get set }
    var testDescription: OneDescriptionObject? { get }
    var tasks: [OneTaskModel]? { get }
    var arrayOfKeys: [String]? { get }
    var localizedTestName: String? { get }

    func loadTestWithName(testString: String)
    func saveTests()
    func sortTest(sortType: MathTestParentVM.TestsSortTypes)
}

final class TestsService: TestsServiceProtocol {
    
    private let TestsAppVersionKey = "tests_app_version"
    private let TestsConfigVersionKey = "tests_config_version"
    
    var onTestLoaded: (() -> ())?
    var onNoPermissions: (() -> ())?
    var testDescription: OneDescriptionObject? {
        get {
            if let to = testObject {
                return to.testDescriptionObject
            }
            return nil
        }
    }
    var localizedTestName: String? {
        get {
            if let to = testObject {
                return to.testName
            }
            return nil
        }
    }
    var tasks: [OneTaskModel]? {
        get {
            if let at = allTasks {
                return at
            }
            return nil
        }
    }
    var arrayOfKeys: [String]? {
        get {
            if let to = testObject {
                return to.arrayOfKeys
            }
            return nil
        }
    }
    
    private var parentTestString: String = ""
    private var discipline: String = ""
    private var testName: String = ""
    private var testObject: TestModelProtocol?
    private var allTasks: [OneTaskModel]?
    
    //MARK: - CoreData part
    func loadTestWithName(testString: String) {
        parentTestString = testString
        let separatedString = parentTestString.components(separatedBy: Constants.Values.StringSeparator)
        discipline = separatedString[0]
        testName = ""
        for index in 1 ..< separatedString.count {
            testName += separatedString[index] + Constants.Values.StringSeparator
        }
        testName.removeLast(2)
//        testName = separatedString[1]

        loadFromCoreData()
    }

    private func loadFromCoreData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: TestModel.TestsEntityKey)
        request.predicate = NSPredicate(format: "\(TestModel.NameKey) == %@", parentTestString)
        request.returnsObjectsAsFaults = false

        do {
            let result = try CoreDataManager.shared.context.fetch(request)
            let objects = result as! [NSManagedObject]
            if objects.count > 0 {
                parseCoreDataTest(object: objects.first!)
                checkTestUpdates()
            } else {
                loadTestFromFirebase()
            }
        } catch {
            loadTestFromFirebase()
        }
    }
    
    private func parseCoreDataTest(object: NSManagedObject) {
        if let tempTestObject = TestModel(coreDataObject: object) {
            testObject = tempTestObject
            allTasks = testObject!.testTasks
            sortTest(sortType: .order)
            onTestLoaded?()
        } else {
            loadTestFromFirebase()
        }
    }
    
    //MARK: - Firebase part
    private func checkTestUpdates() {
        let db = Firestore.firestore()
        let configRef = db.collection(Constants.FirebaseTables.Config).document(Constants.FirebaseTables.ConfigVersions)
        configRef.getDocument(completion: { [weak self] (docSnapshot, error) in
            if error == nil {
                self?.checkIfNeedUpdate(docSnapshot: docSnapshot!)
            }
        })
    }
    
    private func checkIfNeedUpdate(docSnapshot: DocumentSnapshot) {
        DispatchQueue.global(qos: .background).async {
            if !self.testIsActual(firebaseDic: docSnapshot.data() as! [String : NSNumber]) {
                DispatchQueue.main.async {
                    self.loadTestFromFirebase()
                }
            }
        }
    }
    
    private func testIsActual(firebaseDic: [String : NSNumber]) -> Bool {
        let currentAppVersion = UserDefaults.standard.value(forKey: "\(TestsAppVersionKey)\(parentTestString)") as? Int
        let currentConfigVersion = UserDefaults.standard.value(forKey: "\(TestsConfigVersionKey)\(parentTestString)") as? Int
        
        let serverAppVersion = Int(truncating: firebaseDic["app_version"] ?? 0)
        let serverConfigVersion = Int(truncating: firebaseDic["config_version"] ?? 0)
        
        if currentAppVersion == nil || currentConfigVersion == nil {
            UserDefaults.standard.set(serverAppVersion, forKey: "\(TestsAppVersionKey)\(parentTestString)")
            UserDefaults.standard.set(serverConfigVersion, forKey: "\(TestsConfigVersionKey)\(parentTestString)")
            return false
        } else {
            if currentAppVersion! < serverAppVersion || currentConfigVersion! < serverConfigVersion {
                UserDefaults.standard.set(serverAppVersion, forKey: "\(TestsAppVersionKey)\(parentTestString)")
                UserDefaults.standard.set(serverConfigVersion, forKey: "\(TestsConfigVersionKey)\(parentTestString)")
                return false
            } else {
                return true
            }
        }
    }
    
    private func loadTestFromFirebase() {
        let db = Firestore.firestore()
        let testRef = db.collection(discipline).document(testName)
        testRef.getDocument(completion: { [weak self] (querySnapshot, error) in
            if error != nil {
                let desc = error.debugDescription
                if desc.contains(Constants.Values.PermissionsTextError) {
                    self?.onNoPermissions?()
                } else {
                    self?.onTestLoaded?()
                }
            } else {
                if let data = querySnapshot?.data() {
                    self?.createTestObject(data: data)
                }
                self?.onTestLoaded?()
            }
        })
    }
    
    private func createTestObject(data: [String : Any]) {
        testObject = TestModel(firebaseDic: data, testName: parentTestString)
        allTasks = testObject!.testTasks
        sortTest(sortType: .order)
        testObject?.saveToCoreData()
    }
    
    func saveTests() {
        testObject?.saveToCoreData()
    }
    
    func sortTest(sortType: MathTestParentVM.TestsSortTypes) {
        guard allTasks != nil else { return }
        switch sortType {
        case .solved:
            allTasks!.sort { $0.isSolved && !$1.isSolved }
        case .unsolved:
            allTasks!.sort { !$0.isSolved && $1.isSolved }
        case .exams:
            allTasks!.sort { $0.description > $1.description }
        default:
            allTasks!.sort { $0.dbIndex < $1.dbIndex }
        }
    }
    
//    private func clearCoreData() {
//        print("Try clear")
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: TestModel.TestsEntityKey)
//        fetchRequest.includesPropertyValues = false
//
//        do {
//            let stks = try CoreDataManager.shared.context.fetch(fetchRequest) as! [NSManagedObject]
//
//            for stk in stks {
//                CoreDataManager.shared.context.delete(stk)
//            }
//            CoreDataManager.shared.saveContext()
//            print("REMOVED")
//
//        } catch {
//            print("Error while removing")
//        }
//    }
}
