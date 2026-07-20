//Created on 10/7/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import Foundation
import CoreData

protocol CollegTestsVMProtocol {
    var onTestTypesLoaded: (() -> ())? { get set }
    var sections: [ExpandableSectionProtocol] { get }
    
    func loadStksSelectedTestTypes(stkName: String)
    func getSelectedString(indexPath: IndexPath) -> String
}

final class CollegTestsVM: CollegTestsVMProtocol {
    
    var onTestTypesLoaded: (() -> ())?
    
    var sections = [ExpandableSectionProtocol] ()
    
    private var usersSelectionService: UserSelectionServiceProtocol
    private var selectedStk: StkModelProtocol?
    
    init() {
        usersSelectionService = UserSelectionService()
        usersSelectionService.loadUserSelection()
    }
    
    func loadStksSelectedTestTypes(stkName: String) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: StkModel.StksEntityKey)
        request.predicate = NSPredicate(format: "\(StkModel.UniqueStkNameKey) == %@", stkName)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try CoreDataManager.shared.context.fetch(request)
            let objects = result as! [NSManagedObject]
            if objects.count > 0 {
                if let stk = StkModel(coreDataObject: objects.first!) {
                    selectedStk = stk
                    getSelectedTestDisciplines()
                } else {
                    onTestTypesLoaded?()
                }
            } else {
                onTestTypesLoaded?()
            }
        } catch {
            onTestTypesLoaded?()
        }
    }
    
    private func getSelectedTestDisciplines() {
        if let stk = selectedStk {
            let selectedTestTypes = usersSelectionService.getStksSelectedTestTypes(stkName: stk.stk_name)
            for selectedType in selectedTestTypes {
                let disciplines = stk.getCourseDisciplines(courseName: selectedType)
                var currentDisciplines = [String]()
                for oneDiscipline in disciplines {
                    if oneDiscipline.lowercased().contains(Constants.Values.InProgressRestriction) {
                        continue
                    }
                    currentDisciplines.append(oneDiscipline)
                }
                var newSection = ExpandableSection(titleObject: selectedType, sectionsObjects: currentDisciplines)
                newSection.isExpanded = true
                sections.append(newSection)
            }
            onTestTypesLoaded?()
        } else {
            onTestTypesLoaded?()
        }
    }
    
    func getSelectedString(indexPath: IndexPath) -> String {
        let section = sections[indexPath.section]
        return "\(section.titleObject)\(Constants.Values.StringSeparator)\(section.sectionsObjects[indexPath.row])"
    }
    
}
