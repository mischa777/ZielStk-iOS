//Created on 9/23/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import Foundation
import CoreData

protocol SecondShopVMProtocol {
    var onStkTestsLoaded: (() -> ())? { get set }
    var sections: [ExpandableSectionProtocol] { get }
    var totalExamsArray: [String : String] { get }
    
    func loadStksDisciplineAndTests(stkString: String)
    func changeSectionExpand(section: Int)
    func getStkName(sectionName: String, testName: String) -> String
    func getAgreementUrl() -> String
}

final class SecondShopVM: SecondShopVMProtocol {
    
    var onStkTestsLoaded: (() -> ())?
    var sections: [ExpandableSectionProtocol] {
        get {
            return allSections
        }
    }
    
    var totalExamsArray: [String : String] = [String : String]()
    
    private var allSections = [ExpandableSectionProtocol] ()
    private var stkName = ""
    private var testType = ""
    private var selectedStk: StkModelProtocol?
    private var structService: StructServiceProtocol?
    
    func loadStksDisciplineAndTests(stkString: String) {
        parseSelectedString(stkString: stkString)
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: StkModel.StksEntityKey)
        request.predicate = NSPredicate(format: "\(StkModel.UniqueStkNameKey) == %@", stkName)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try CoreDataManager.shared.context.fetch(request)
            let objects = result as! [NSManagedObject]
            if objects.count > 0 {
                if let stk = StkModel(coreDataObject: objects.first!) {
                    selectedStk = stk
                    getDisciplineAndTests()
                } else {
                    loadStruct()
                }
            } else {
                loadStruct()
            }
        } catch {
            loadStruct()
        }
    }
    
    func getAgreementUrl() -> String {
//        if let currentLang = Locale.current.languageCode {
//            if currentLang == "ru" {
//                return "https://firebasestorage.googleapis.com/v0/b/ziel-studienkolleg.appspot.com/o/Documents%2FNutzungvertrag.pdf?alt=media&token=2e3cf866-3fe8-4d7a-9512-872939a09248"
//            }
//        }
        return "https://firebasestorage.googleapis.com/v0/b/ziel-studienkolleg.appspot.com/o/Documents%2FNutzungvertrag.pdf?alt=media&token=2e3cf866-3fe8-4d7a-9512-872939a09248"
    }
    
    private func getDisciplineAndTests() {
        if let stk = selectedStk {
            let disciplines = stk.getCourseDisciplines(courseName: testType)
            for oneDiscipline in disciplines {
                if oneDiscipline.lowercased().contains(Constants.Values.InProgressRestriction) {
                    continue
                }
                allSections.append(ExpandableSection(titleObject: oneDiscipline, sectionsObjects: stk.getDisciplineTests(disciplineName: oneDiscipline, courseName: testType)))
            }
            loadStruct()
        } else {
            loadStruct()
        }
    }
    
    private func loadStruct() {
        structService = StructService()
        structService!.onError = { [weak self] in
            self?.onStkTestsLoaded?()
        }
        structService!.onStructLoaded = { [weak self] in
            self?.setChalangesCount()
            self?.onStkTestsLoaded?()
        }
        structService!.loadStructFromCoreData()
    }
    
    private func setChalangesCount() {
        for section in allSections {
            for name in section.sectionsObjects {
                if let name = name as? String,
                   let total_examTuple = structService?.getThemeChalangesCount(nameOfChalange: name),
                   totalExamsArray[name] == nil {
                    totalExamsArray[name] = "\(NSLocalizedString("TotalShortShopText", comment: "")): \(total_examTuple.total) / \(NSLocalizedString("ExShortShopText", comment: "")): \(total_examTuple.exams)"
                }
            }
        }
    }
    
    private func parseSelectedString(stkString: String) {
        let separatedString = stkString.components(separatedBy: Constants.Values.StringSeparator)
        stkName = separatedString[0]
        testType = separatedString[1]
    }
    
    func changeSectionExpand(section: Int) {
        allSections[section].isExpanded = !allSections[section].isExpanded
    }
    
    func getStkName(sectionName: String, testName: String) -> String {
        let shopString = "\(stkName)%\(testType)%\(sectionName)%\(testName)"
        return shopString
    }
}
