//Created on 9/28/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import Foundation
import CoreData
import FirebaseFirestore

protocol SubCollegTestVMProtocol {
    var onDeutchPermitted: ((String) -> ())? { get set }
    var onTestPermitted: ((String) -> ())? { get set }
    var onTestRestricted: (() -> ())? { get set }
    var onTestsLoaded: (() -> ())? { get set }
    
    var tests: [String] { get }
    var courseType: String { get }
    var opennedDiscipline: String { get }
    var parentString: String { get }
    var structTotalText: String { get }
    var totalExamsArray: [String : Int?] { get }
    
    func loadDisciplineTests(selectedCourseString: String, stkName: String)
    func checkIfDeutchPurchased(testName: String)
    func checkIfMathPurchased(disciplineName: String, testName: String)
}

final class SubCollegTestVM: SubCollegTestVMProtocol {
    
    var onDeutchPermitted: ((String) -> ())?
    var onTestPermitted: ((String) -> ())?
    var onTestRestricted: (() -> ())?
    
    var onTestsLoaded: (() -> ())?
    var tests: [String] {
        get {
            return testsOfDiscipline
        }
    }
    var courseType: String {
        get {
            return courseSourceType
        }
    }
    var opennedDiscipline: String {
        get {
            return discipline
        }
    }
    
    var parentString = ""
    var structTotalText = ""
    var totalExamsArray: [String : Int?] = [String : Int?]()
    
    private var courseSourceType = ""
    private var discipline = ""
    private var testsOfDiscipline = [String]()
    private var selectedStk: StkModelProtocol?
    private var structService: StructServiceProtocol?
 
    func loadDisciplineTests(selectedCourseString: String, stkName: String) {
        parseSelectedString(selectedCourseString: selectedCourseString)
        parentString = "\(stkName)\(Constants.Values.StringSeparator)\(courseType)"
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: StkModel.StksEntityKey)
        request.predicate = NSPredicate(format: "\(StkModel.UniqueStkNameKey) == %@", stkName)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try CoreDataManager.shared.context.fetch(request)
            let objects = result as! [NSManagedObject]
            if objects.count > 0 {
                if let stk = StkModel(coreDataObject: objects.first!) {
                    selectedStk = stk
                    getDisciplineTests()
                } else {
                    loadStructures()
                }
            } else {
                loadStructures()
            }
        } catch {
            loadStructures()
        }
    }
    
    private func parseSelectedString(selectedCourseString: String) {
        let separatedString = selectedCourseString.components(separatedBy: Constants.Values.StringSeparator)
        courseSourceType = separatedString[0]
        discipline = separatedString[1]
    }
    
    private func getDisciplineTests() {
        if let stk = selectedStk {
            testsOfDiscipline = stk.getDisciplineTests(disciplineName: discipline, courseName: courseSourceType)
            loadStructures()
        } else {
            loadStructures()
        }
    }
    
    private func loadStructures() {
        structService = StructService()
        structService!.onError = { [weak self] in
            self?.onTestsLoaded?()
        }
        structService!.onStructLoaded = { [weak self] in
            self?.setChalangesCount()
            self?.onTestsLoaded?()
        }
        structService!.loadStructFromCoreData()
    }
    
    private func setChalangesCount() {
        var totalExamsCount = 0
        var totalCount = 0
        for testName in testsOfDiscipline {
            if let total_examTuple = structService?.getThemeChalangesCount(nameOfChalange: testName) {
                totalCount += total_examTuple.total
                totalExamsCount += total_examTuple.exams
                totalExamsArray[testName] = total_examTuple.total
            }
        }
        structTotalText = "\(NSLocalizedString("TotalFullText", comment: "")): \(totalCount)\n \(NSLocalizedString("FromExamFullText", comment: "")): \(totalExamsCount)"
    }
    
    //MARK: - Check permissions
    func checkIfDeutchPurchased(testName: String) {
        
        print("[checkIfDeutchPurchased] => \(testName)")
        
        let db = Firestore.firestore()
        let testRef = db.collection("Deutsch").document(testName)
        
        testRef.getDocument(completion: { [weak self] (querySnapshot, error) in
            
            if error != nil {
                let desc = error.debugDescription
                if desc.contains(Constants.Values.PermissionsTextError) {
                    self?.onTestRestricted?()
                    //[DEBUG]
                } else {
                    self?.onDeutchPermitted?(testName)
                }
            } else {
                self?.onDeutchPermitted?(testName)
            }
        })
    }
    func checkIfMathPurchased(disciplineName: String, testName: String) {
        
        print("[checkIfTestPurchased] => disciplineName: \(disciplineName) => testName: \(testName)")
        
        let stringOfTest = "\(disciplineName)\(Constants.Values.StringSeparator)\(testName)"
        let db = Firestore.firestore()
        let testRef = db.collection(disciplineName).document(testName)
        
        testRef.getDocument(completion: { [weak self] (querySnapshot, error) in
            
            if error != nil {
                let desc = error.debugDescription
                if desc.contains(Constants.Values.PermissionsTextError) {
                    self?.onTestRestricted?()
                    //[DEBUG]
                } else {
                    self?.onTestPermitted?(stringOfTest)
                }
            } else {
                self?.onTestPermitted?(stringOfTest)
            }
        })
    }
}
