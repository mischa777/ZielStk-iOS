//Created on 10/9/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import Foundation
import CoreData
import FirebaseAuth
import FirebaseFirestore
import FirebaseAnalytics

protocol MathTestParentVMProtocol {
    var onTestLoaded: (() -> ())? { get set }
    var onNoPermissions: (() -> ())? { get set }
    var sourceTestString: String { get }
    var testType: String { get }
    var testService: TestsServiceProtocol { get }
    var onTipsStep: ((String, Int) -> ())? { get set }
    var totalTipsNumber: Int { get }
    var onScreenshotProtectionNeeded: (() -> ())? { get set }
    var onCaptureProtectionNeeded: (() -> ())? { get set }
    
    func loadTest(withName: String)
    func saveNewTarget(targetIndex: Int, stkData: String, testData: String)
    func getStarByIndex(indexOfStar: Int) -> String?
    func setNextTip()
    func checkTips()
    func setProtection()
    func removeProtection()
}

final class MathTestParentVM: MathTestParentVMProtocol {
    
    enum ViewStates: Int {
        case tests = 0
        case infos = 1
        case lessons = 2
    }
    
    enum TestsSortTypes: Int {
        case order = 0
        case solved = 1
        case unsolved = 2
        case exams = 3
    }
    
    private let screenshotEventName = "screenshot_taken"
    private let videoCapturedEventName = "video_captured"
    
    var onTestLoaded: (() -> ())?
    var onNoPermissions: (() -> ())?
    var onTipsStep: ((String, Int) -> ())?
    var onScreenshotProtectionNeeded: (() -> ())?
    var onCaptureProtectionNeeded: (() -> ())? 
    var sourceTestString = ""
    var testType = ""
    var testService: TestsServiceProtocol
    
    private var discipline = ""
    
    var totalTipsNumber: Int {
        get {
            return sourceTips.count
        }
    }
    private lazy var currentTips: [String] = {
       return sourceTips
    }()
    private let TipsWasShowedKey = "tips_was_showed"
    private let sourceTips: [String] = [
        NSLocalizedString("Tip1Text", comment: ""),
        NSLocalizedString("Tip2Text", comment: ""),
        NSLocalizedString("Tip3Text", comment: "")
    ]
    
    private var videoTimer: Timer?
    
    init () {
        testService = TestsService()
    }
    
    func loadTest(withName: String) {
        testService.onTestLoaded = { [weak self] in
            self?.onTestLoaded?()
        }
        testService.onNoPermissions = {[weak self] in
            self?.onNoPermissions?()
        }
        testService.loadTestWithName(testString: withName)
        
        sourceTestString = withName
        parseSelectedString(selectedCourseString: withName)
    }
    
    private func parseSelectedString(selectedCourseString: String) {
        let separatedString = selectedCourseString.components(separatedBy: Constants.Values.StringSeparator)
        discipline = separatedString[0]
        testType = separatedString[1]
    }
    
    //MARK: - Target save
    func saveNewTarget(targetIndex: Int, stkData: String, testData: String) {
        if let userUid = Auth.auth().currentUser?.uid {
            if let existingTarget = getExistingTarget(testData: testData, uid: userUid) {
                existingTarget.updateTarget(newTargetIndex: Int32(targetIndex))
            } else {
                let newTarget: TargetModelProtocol = TargetModel(stkData: stkData, testData: testData, targetIndex: Int32(targetIndex), userId: userUid)
                newTarget.saveTarget()
            }
        }
    }
    
    private func getExistingTarget(testData: String, uid: String) -> TargetModelProtocol? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: TargetModel.TargetsEntityKey)
        let subPredicate1 = NSPredicate(format: "(\(TargetModel.UserUidKey) = %@)", uid)
        let subPredicate2 = NSPredicate(format: "(\(TargetModel.TestDataKey) = %@)", testData)
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [subPredicate1, subPredicate2])
        request.predicate = compoundPredicate
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try CoreDataManager.shared.context.fetch(request)
            let objects = result as! [NSManagedObject]
            if objects.count > 0 {
                return TargetModel(coreDataObject: objects.first!)
            }
            return nil
        } catch {
            return nil
        }
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
    
    func checkTips() {
        let tipsWasShowed = UserDefaults.standard.bool(forKey: TipsWasShowedKey)
        if !tipsWasShowed {
            UserDefaults.standard.setValue(true, forKey: TipsWasShowedKey)
            setNextTip()
        }
    }
    
    func setNextTip() {
        guard currentTips.count > 0 else { return }
        let currentTip = currentTips.removeFirst()
        let tipIndex = sourceTips.count - currentTips.count
        onTipsStep?(currentTip, tipIndex)
    }
    
    func setProtection() {
        NotificationCenter.default.addObserver(self, selector: #selector(onScreenshotTaken), name: UIApplication.userDidTakeScreenshotNotification, object: nil)
        checkIfScreenIsCaptured()
        videoTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] timer in
            self?.checkIfScreenIsCaptured()
        })
    }
    
    func removeProtection() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.userDidTakeScreenshotNotification, object: nil)
        videoTimer?.invalidate()
        videoTimer = nil
    }
    
    @objc
    private func onScreenshotTaken() {
        registerProtectionEvent(eventName: screenshotEventName)
        onScreenshotProtectionNeeded?()
    }
    
    private func checkIfScreenIsCaptured() {
        DispatchQueue.global(qos: .background).async {
            for screen in UIScreen.screens {
                if screen.isCaptured {
                    DispatchQueue.main.async {
                        self.setVideoCapture()
                    }
                }
            }
        }
    }
    
    private func setVideoCapture() {
        registerProtectionEvent(eventName: videoCapturedEventName)
        onScreenshotProtectionNeeded?()
        videoTimer?.invalidate()
        videoTimer = nil
    }
    
    private func registerProtectionEvent(eventName: String) {
        var appVersion: String = "unknown version"
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            appVersion = version
        }
        let iosVersion = UIDevice.current.systemVersion
        let deviceName = UIDevice.current.name
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let stringDate = dateFormatter.string(from: Date())
        
        Analytics.logEvent(eventName, parameters: [
            "User_ID" : Auth.auth().currentUser?.uid ?? "no id" as NSObject,
            "User_Email" : Auth.auth().currentUser?.email ?? "no email" as NSObject,
            "Theme" : testType as NSObject,
            "App_version" : appVersion as NSObject,
            "IOS_version" : iosVersion as NSObject,
            "Device_name" : deviceName as NSObject,
            "Time" : stringDate as NSObject
        ])
        print("Event Loged")
        
        let db = Firestore.firestore()
        db.collection("breakers").addDocument(data: [
            "user_id" : Auth.auth().currentUser?.uid ?? "no id",
            "user_email" : Auth.auth().currentUser?.email ?? "no email",
            "theme" : testType,
            "app_version" : appVersion,
            "ios_version" : iosVersion,
            "device_name" : deviceName,
            "time" : stringDate,
            "break_type" : eventName
        ])
    }
    
}
