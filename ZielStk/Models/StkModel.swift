//Created on 9/29/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import Foundation
import CoreData

protocol StkModelProtocol {
    var stk_name: String { get }
    var courses: CoursesParent { get }
    var logo: String { get }
    var picture: String { get }
    var description: DescriptionStk { get }
    var coursesCount: Int { get }
    var localizedDescription: String { get }
    var localizedStarDescription: String { get }
    
    init(firebaseDic: [String: Any])
    init?(coreDataObject: NSManagedObject)
    
    func saveToCoreData()
    func getCourseDisciplines(courseName: String) -> [String]
    func getDisciplineTests(disciplineName: String, courseName: String) -> [String]
}

final class StkModel: StkModelProtocol {
    
    static let StksEntityKey = "Stks"
    static let UniqueStkNameKey = "stk_name"
    
    var coursesCount: Int {
        get {
            return courses.courses.count
        }
    }
    
    var localizedDescription: String {
        get {
            if let currentLang = Locale.current.languageCode {
                if currentLang == "ru" {
                    return description.ruText.replacingOccurrences(of: "\\n", with: "\n")
                }
            }
            return description.deText.replacingOccurrences(of: "\\n", with: "\n")
        }
    }
    
    var localizedStarDescription: String {
        get {
            if let currentLang = Locale.current.languageCode {
                if currentLang == "ru" {
                    return description.ruStar.replacingOccurrences(of: "\\n", with: "\n")
                }
            }
            return description.deStar.replacingOccurrences(of: "\\n", with: "\n")
        }
    }
    
    var description: DescriptionStk
    var logo: String
    var picture: String
    var courses: CoursesParent
    var stk_name: String
    
    init(firebaseDic: [String : Any]) {
        let tempLogo = firebaseDic["Logo"] as! String
        logo = tempLogo
        
        let tempPicture = firebaseDic["Picture"] as! String
        picture = tempPicture
        
        let tempStkName = firebaseDic["StkName"] as! String
        stk_name = tempStkName.removingPercentEncoding ?? ""
       
        description = DescriptionStk(firebaseDescription: firebaseDic["Description"] as! [String : Any])
        
        
        let allCoursesDic = firebaseDic["Courses"] as! [String : Any]
        courses = CoursesParent(firebaseDic: allCoursesDic)
    }
    
    func saveToCoreData() {
        let entity = NSEntityDescription.entity(forEntityName: StkModel.StksEntityKey, in: CoreDataManager.shared.context)
        let newStkObject = NSManagedObject(entity: entity!, insertInto: CoreDataManager.shared.context)
        
        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(courses)
            let jsonCoursesString = String(data: jsonData, encoding: .utf8)
            newStkObject.setValue(jsonCoursesString, forKey: "courses")
        } catch {
            print("Failed to encode courses")
            return
        }
        
        newStkObject.setValue(description.deStar, forKey: "deStar")
        newStkObject.setValue(description.deText, forKey: "deText")
        newStkObject.setValue(logo, forKey: "logo")
        newStkObject.setValue(picture, forKey: "picture")
        newStkObject.setValue(description.ruStar, forKey: "ruStar")
        newStkObject.setValue(description.ruText, forKey: "ruText")
        newStkObject.setValue(stk_name, forKey: "stk_name")

        CoreDataManager.shared.saveContext()
    }
    
    init?(coreDataObject: NSManagedObject) {
        do {
            guard let coursesText = coreDataObject.value(forKey: "courses") as? String, let jsonData = coursesText.data(using: .utf8) else {
                print("[ERR] - 110")
                return nil
            }
            let jsonDecoder = JSONDecoder()
            courses = try jsonDecoder.decode(CoursesParent.self, from: jsonData)
        } catch {
            print("Cant decode courses string")
            return nil
        }
        
        let deStar = coreDataObject.value(forKey: "deStar") as! String
        let deText = coreDataObject.value(forKey: "deText") as! String
        let ruStar = coreDataObject.value(forKey: "ruStar") as! String
        let ruText = coreDataObject.value(forKey: "ruText") as! String
        
        description = DescriptionStk(deSt: deStar, deTx: deText, ruSt: ruStar, ruTx: ruText)
        
        logo = coreDataObject.value(forKey: "logo") as! String
        picture = coreDataObject.value(forKey: "picture") as! String
        stk_name = coreDataObject.value(forKey: "stk_name") as! String
    }
    
    func getCourseDisciplines(courseName: String) -> [String] {
        return courses.getCourseDisciplines(courseName: courseName)
    }
    
    func getDisciplineTests(disciplineName: String, courseName: String) -> [String] {
        return courses.getDisciplineTests(disciplineName: disciplineName, courseName: courseName)
    }
}

//MARK: - Subcalsses
struct CoursesParent: Codable {
    var courses: [CoursesStk]
    
    init (firebaseDic: [String : Any]) {
        courses = [CoursesStk]()
        for (key, value) in firebaseDic {
            courses.append(CoursesStk(name: key, subCourseObject: value))
        }
    }
    
    func getCourseDisciplines(courseName: String) -> [String] {
        for oneCourse in courses {
            if courseName == oneCourse.courseName {
                return oneCourse.getCourseDisciplines()
            }
        }
        return [String]()
    }
    
    func getDisciplineTests(disciplineName: String, courseName: String) -> [String] {
        for course in courses {
            if course.courseName == courseName {
                return course.getDisciplineTests(disciplineName: disciplineName)
            }
        }
        return [String]()
    }
}

struct CoursesStk: Codable {
    var courseName: String
    var subCourses: [SubCourseStk]
    
    init (name: String, subCourseObject: Any) {
        courseName = name
        let subObjects = subCourseObject as! [[String : [String]]]
        
//        print("COURSE NAME \(courseName)")
        subCourses = [SubCourseStk]()
        for item in subObjects {
            for (key, value) in item {
                subCourses.append(SubCourseStk(name: key, coursesTypes: value))
            }
        }
    }
    
    func getCourseDisciplines() -> [String] {
        var disciplines = [String] ()
        for discipline in subCourses {
            disciplines.append(discipline.discipline)
        }
        return disciplines
    }
    
    func getDisciplineTests(disciplineName: String) -> [String] {
        for course in subCourses {
            if disciplineName == course.discipline {
                return course.types
            }
        }
        return [String]()
    }
    
}

struct SubCourseStk: Codable {
    var discipline: String
    var types: [String]

    init(name: String, coursesTypes: [String]) {
        discipline = name
        types = coursesTypes
    }
}

struct DescriptionStk {
    var deStar: String
    var deText: String
    var ruStar: String
    var ruText: String
    
    init (firebaseDescription: [String : Any]) {
        
        let dePart = firebaseDescription["de"] as! [String : Any]
        let deStarPart = dePart["star"] as! [String]
        deStar = deStarPart.first!
        deText = dePart["text"] as! String
        
        let ruPart = firebaseDescription["ru"] as! [String : Any]
        let ruStarPart = ruPart["star"] as! [String]
        ruStar = ruStarPart.first!
        ruText = ruPart["text"] as! String
    }
    
    init (deSt: String, deTx: String, ruSt: String, ruTx: String) {
        deStar = deSt
        deText = deTx
        ruStar = ruSt
        ruText = ruTx
    }
}
