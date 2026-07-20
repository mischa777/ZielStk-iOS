//Created on 10/23/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import Foundation
import FirebaseFirestore

protocol DeutchCompilerVMProtocol {
    var onNoPermissions: (() -> ())? { get set }
    var onTestLoaded: (() -> ())? { get set }
    var sourceTestString: String { get }
    var testType: String { get }
    var testService: TestsServiceProtocol { get }
    
    func loadTest(withName: String)
    func getStarByIndex(indexOfStar: Int) -> String?
}

final class DeutchCompilerVM: DeutchCompilerVMProtocol {
    
    enum DeutchTestTypes: String {
        case cTest = "C-Test"
        case clozeTest = "Cloze-Test"
    }
    
    var onNoPermissions: (() -> ())?
    var onTestLoaded: (() -> ())?
    
    var testService: TestsServiceProtocol
    var sourceTestString: String = ""
    var testType = ""
    private var wasLoaded: Bool = false
    private var discipline = ""
    
    init () {
        testService = TestsService()
    }
    
    func loadTest(withName: String) {
        if !wasLoaded {
            wasLoaded = true
            testService.onTestLoaded = { [weak self] in
                self?.onTestLoaded?()
            }
            testService.onNoPermissions = {[weak self] in
                self?.onNoPermissions?()
            }
            testService.loadTestWithName(testString: withName)
        }
        sourceTestString = withName
        parseSelectedString(selectedCourseString: withName)
    }
    
    private func parseSelectedString(selectedCourseString: String) {
        testType = ""
        let separatedString = selectedCourseString.components(separatedBy: Constants.Values.StringSeparator)
        discipline = separatedString[0]
        for index in 1 ..< separatedString.count {
            testType += separatedString[index] + Constants.Values.StringSeparator
        }
        testType.removeLast(2)
    }
    
    //MARK: - get star text
    func getStarByIndex(indexOfStar: Int) -> String? {
        if let td = testService.testDescription {
            switch indexOfStar {
            case 0:
                return td.star[0]
            case 1,2:
                return td.star[1]
            case 3,4,5:
                return td.star[2]
            case 6,7,8,9:
                return td.star[3]
            default:
                return nil
            }
        }
        return nil
    }    
}
