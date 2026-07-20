//Created on 9/29/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import Foundation

protocol ChooseCoursesVMProtocol {
    var onStksError: (() -> ())? { get set }
    var onStksLoaded: (() -> ())? { get set }
    var sections: [ExpandableSectionProtocol] { get }
    var selectionService: UserSelectionServiceProtocol { get }
    
    func loadStks()
    
    func changeSectionExpand(section: Int)
}

final class ChooseCoursesVM: ChooseCoursesVMProtocol {
    
    var onStksError: (() -> ())?
    var onStksLoaded: (() -> ())?
    var sections: [ExpandableSectionProtocol] {
        get {
            return allSections
        }
    }
    var selectionService: UserSelectionServiceProtocol {
        get {
            return userSelectionService
        }
    }
    
    private var allSections = [ExpandableSectionProtocol] ()
    
    private var stkService: StkServiceProtocol
    private var userSelectionService: UserSelectionServiceProtocol
    
    init() {
        stkService = StkService()
        userSelectionService = UserSelectionService()
    }
    
    func loadStks() {
        stkService.onError = { [weak self] in
            self?.onStksError?()
        }
        stkService.onStksLoaded = { [weak self] in
            self?.setSections()
        }
        userSelectionService.loadUserSelection()
        stkService.loadStksFromCoreData()
    }
    
    private func setSections() {
        for oneStk in stkService.allStks {
            var coursesNames = [String]()
            for oneObject in oneStk.courses.courses {
                coursesNames.append(oneObject.courseName)
            }
            allSections.append(ExpandableSection(titleObject: oneStk, sectionsObjects: coursesNames))
        }
        onStksLoaded?()
    }
    
    func changeSectionExpand(section: Int) {
        allSections[section].isExpanded = !allSections[section].isExpanded
    }
}
