//Created on 9/27/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import Foundation

protocol ExpandableSectionProtocol {
    var titleObject: Any { get }
    var sectionsObjects: [Any] { get }
    var isExpanded: Bool { get set }
    
    init (titleObject: Any, sectionsObjects: [Any])
}

struct ExpandableSection: ExpandableSectionProtocol {
    
    var titleObject: Any
    var sectionsObjects: [Any]
    var isExpanded: Bool
    
    init(titleObject: Any, sectionsObjects: [Any]) {
        self.titleObject = titleObject
        self.sectionsObjects = sectionsObjects
        isExpanded = false
    }
    
}
