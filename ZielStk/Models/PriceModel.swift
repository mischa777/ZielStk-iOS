//Created on 9/27/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import Foundation
import CoreData

protocol PriceModelProtocol {
    var is_discounts: Bool { get }
    
    var biologie: Float { get }
    var deutsch: Float { get }
    var englisch: Float { get }
    var geisteswissenschaft: Float { get }
    var in_der_entwicklung: Float { get }
    var mathematik: Float { get }
    var naturwissenschaften: Float { get }
    var physik: Float { get }
    var sprachwissenschaft: Float { get }
    var wirtschaftslehre: Float { get }
    
    init(firebaseDic: [String : NSNumber], type: String)
    init(coreDataObject: NSManagedObject)
    func saveToCoreData()
    func getPriceForDiscipline(disciplineName: String) -> Float
}

final class PriceModel: PriceModelProtocol {
    
    static let PriceEntityKey = "Prices"
    
    var is_discounts: Bool
    
    var biologie: Float = 0
    var deutsch: Float = 0
    var englisch: Float = 0
    var geisteswissenschaft: Float = 0
    var in_der_entwicklung: Float = 0
    var mathematik: Float = 0
    var naturwissenschaften: Float = 0
    var physik: Float = 0
    var sprachwissenschaft: Float = 0
    var wirtschaftslehre: Float = 0
    
    private var document_key: String
    
    init(firebaseDic: [String : NSNumber], type: String) {
        is_discounts = type != "Subjects"
        document_key = type
        
        for (key, value) in firebaseDic {
            let floatValue = Float(truncating: value)
            
            switch key {
            case "Mathematik":
                mathematik = floatValue
            case "Geisteswissenschaft":
                geisteswissenschaft = floatValue
            case "Deutsch":
                deutsch = floatValue
            case "Wirtschaftslehre":
                wirtschaftslehre = floatValue
            case "Englisch":
                englisch = floatValue
            case "Physik":
                physik = floatValue
            case "Sprachwissenschaft":
                sprachwissenschaft = floatValue
            case "In der Entwicklung":
                in_der_entwicklung = floatValue
            case "Naturwissenschaften":
                naturwissenschaften = floatValue
            case "Biologie":
                biologie = floatValue
            default:
                print("some price key is not initialised")
            }
        }
    }
    
    init(coreDataObject: NSManagedObject) {
        is_discounts = coreDataObject.value(forKey: "is_discounts") as! Bool
        document_key = coreDataObject.value(forKey: "document_key") as! String
        
        biologie = coreDataObject.value(forKey: "biologie") as! Float
        deutsch = coreDataObject.value(forKey: "deutsch") as! Float
        englisch = coreDataObject.value(forKey: "englisch") as! Float
        geisteswissenschaft = coreDataObject.value(forKey: "geisteswissenschaft") as! Float
        in_der_entwicklung = coreDataObject.value(forKey: "in_der_entwicklung") as! Float
        mathematik = coreDataObject.value(forKey: "mathematik") as! Float
        naturwissenschaften = coreDataObject.value(forKey: "naturwissenschaften") as! Float
        physik = coreDataObject.value(forKey: "physik") as! Float
        sprachwissenschaft = coreDataObject.value(forKey: "sprachwissenschaft") as! Float
        wirtschaftslehre = coreDataObject.value(forKey: "wirtschaftslehre") as! Float
    }
    
    func saveToCoreData() {
        let entity = NSEntityDescription.entity(forEntityName: PriceModel.PriceEntityKey, in: CoreDataManager.shared.context)
        let newPriceObject = NSManagedObject(entity: entity!, insertInto: CoreDataManager.shared.context)
        
        newPriceObject.setValue(is_discounts, forKey: "is_discounts")
        newPriceObject.setValue(document_key, forKey: "document_key")
        newPriceObject.setValue(biologie, forKey: "biologie")
        newPriceObject.setValue(deutsch, forKey: "deutsch")
        newPriceObject.setValue(englisch, forKey: "englisch")
        newPriceObject.setValue(geisteswissenschaft, forKey: "geisteswissenschaft")
        newPriceObject.setValue(in_der_entwicklung, forKey: "in_der_entwicklung")
        newPriceObject.setValue(mathematik, forKey: "mathematik")
        newPriceObject.setValue(naturwissenschaften, forKey: "naturwissenschaften")
        newPriceObject.setValue(physik, forKey: "physik")
        newPriceObject.setValue(sprachwissenschaft, forKey: "sprachwissenschaft")
        newPriceObject.setValue(wirtschaftslehre, forKey: "wirtschaftslehre")
        
        CoreDataManager.shared.saveContext()
    }
    
    func getPriceForDiscipline(disciplineName: String) -> Float {
        switch disciplineName.lowercased() {
        case "mathematik":
            return mathematik
        case "biologie":
            return biologie
        case "deutsch":
            return deutsch
        case "englisch":
            return englisch
        case "geisteswissenschaft":
            return geisteswissenschaft
        case "in_der_entwicklung":
            return in_der_entwicklung
        case "naturwissenschaften":
            return naturwissenschaften
        case "physik":
            return physik
        case "sprachwissenschaft":
            return sprachwissenschaft
        case "wirtschaftslehre":
            return wirtschaftslehre
        default:
            return 0.0
        }
    }
    
}
