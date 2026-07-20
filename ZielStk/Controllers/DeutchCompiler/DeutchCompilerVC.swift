//Created on 10/23/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import UIKit

class DeutchCompilerVC: UIViewController, AlertOpennerProtocol, PreloaderOpennerProtocol {
    
    private let MinSpace = 2
    
    @IBOutlet weak var selectTextBtn: RoundedButton!
    @IBOutlet weak var clozeTestBtn: RoundedButton!
    @IBOutlet weak var cTestBtn: RoundedButton!
    @IBOutlet weak var topMenuView: ShadowedView!
    @IBOutlet weak var testTextView: UITextView!
    @IBOutlet weak var cTestStack: UIStackView!
    @IBOutlet weak var clozeStackView: UIStackView!
    @IBOutlet var cTestButtons: [RoundedButton]!
    @IBOutlet weak var hideKeyboardBtn: UIButton!
    @IBOutlet var selectionLines: [UIView]!
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var lessonsCollection: UICollectionView!
    @IBOutlet weak var scrollForGenerator: UIScrollView!
    
    private var viewModel: DeutchCompilerVMProtocol! {
        didSet {
            self.viewModel.onTestLoaded = { [weak self] in
                print("[0]")
                self?.setOnTestLoadedActions()
            }
            self.viewModel.onNoPermissions = { [weak self] in
                print("[1]")
                //[DEBUG]
                self?.setPermissionRestrictedError()
            }
        }
    }
    
    private var selectedTestType = DeutchCompilerVM.DeutchTestTypes.cTest
    private var spaceIndex = 0
    var postedString: String?
    var testName: String?
    
    override func viewDidLoad() {
        
        print("[VC] => DeutchCompilerVC")
        
        viewModel = DeutchCompilerVM()
        
        super.viewDidLoad()
        setSortState(newSortState: .tests)
        setTestTypeViews()
        tabBarController?.tabBar.isHidden = true
        selectTextBtn.setTitle(NSLocalizedString("SelectTextBtnTitle", comment: ""), for: .normal)
        
        setTestTextBorder()
        if let pString = postedString {
            testTextView.text = pString
        } else {
            setPlaceholder()
        }
        if testName == nil {
            testName = "Deutsch, C-Test"
        } else {
            testName = "Deutsch, \(testName!)"
        }
        
        //TODO load test
        showPreloader()
//        viewModel.checkPermissions()
        testTextView.isEditable = true
        
        hideKeyboardBtn.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewModel.loadTest(withName: testName!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkPosted()
        registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterForKeyboardNotifications()
    }
    
    private func checkPosted() {
        let ud = UserDefaults(suiteName: "group.com.CTestGroup")
        ud?.synchronize()
        if let postedString = ud?.value(forKey: Constants.Values.KeyPostedString) as? String {
            if !postedString.isEmpty {
                ud!.removeObject(forKey: Constants.Values.KeyPostedString)
                ud!.synchronize()
                testTextView.text = postedString
            }
        }
    }
    
    private func setPermissionRestrictedError() {
        let title = NSLocalizedString("AttentionTitle", comment: "")
        let message = NSLocalizedString("NoPermissionsWarning", comment: "")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { action in
            self.onBackTap(self)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func readPostedText() {
        let ud = UserDefaults(suiteName: "group.com.CTestGroup")
        ud?.synchronize()
        if let postedString = ud?.value(forKey: Constants.Values.KeyPostedString) as? String {
            if !postedString.isEmpty {
                ud!.removeObject(forKey: Constants.Values.KeyPostedString)
                ud!.synchronize()
                testTextView.text = postedString
                testTextView.textColor = UIColor.black
            }
        }
    }
    
    private func setTestTextBorder() {
        testTextView.layer.borderWidth = 1
        testTextView.layer.cornerRadius = 3
        testTextView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    //MARK: - Change viewcontrollers
    private func setSortState(newSortState: MathTestParentVM.ViewStates) {
        for index in 0 ..< selectionLines.count {
            selectionLines[index].isHidden = index != newSortState.rawValue
        }
        infoTextView.isHidden = newSortState != .infos
        lessonsCollection.isHidden = newSortState != .lessons
        scrollForGenerator.isHidden = newSortState != .tests
    }
    
    @IBAction func onTestsTap(_ sender: Any) {
        hideKeyboardBtn.isHidden = true
        testTextView.resignFirstResponder()
        setSortState(newSortState: .tests)
    }
    
    @IBAction func onInfoTap(_ sender: Any) {
        hideKeyboardBtn.isHidden = true
        testTextView.resignFirstResponder()
        setSortState(newSortState: .infos)
    }
    
    @IBAction func onMaterialsTap(_ sender: Any) {
        hideKeyboardBtn.isHidden = true
        testTextView.resignFirstResponder()
        setSortState(newSortState: .lessons)
    }
    
    @IBAction func onSelectTextTap(_ sender: Any) {
        performSegue(withIdentifier: Constants.Segues.TextSelectorSegue, sender: nil)
    }
    
    @IBAction func onHideKeyTap(_ sender: Any) {
        hideKeyboardBtn.isHidden = true
        testTextView.resignFirstResponder()
    }
    
    @IBAction func onBackTap(_ sender: Any) {
        hideTopMenu()
        testTextView.resignFirstResponder()
        if let nc = navigationController {
            nc.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: - Test Settings
    @IBAction func onCTestTap(_ sender: Any) {
        if selectedTestType == .clozeTest {
            selectedTestType = .cTest
            setTestTypeViews()
        }
    }
    
    @IBAction func onClozeTestTap(_ sender: Any) {
        if selectedTestType == .cTest {
            selectedTestType = .clozeTest
            setTestTypeViews()
        }
    }
    
    private func setTestTypeViews() {
        hideTopMenu()
        let activeButton = selectedTestType != .cTest ? clozeTestBtn : cTestBtn
        let disabledButton = selectedTestType == .cTest ? clozeTestBtn : cTestBtn
        activateButton(buttonForActivate: activeButton!)
        disableButton(buttonForDisable: disabledButton!)
        
        cTestStack.isHidden = selectedTestType != .cTest
        clozeStackView.isHidden = selectedTestType == .cTest
        spaceIndex = 0
        setSpaceButtons()
    }
    
    private func activateButton(buttonForActivate: RoundedButton) {
        buttonForActivate.setTitleColor(UIColor.white, for: .normal)
        buttonForActivate.backgroundColor = UIColor.ProjectBlueColor
        buttonForActivate.borderColor = nil
    }
    
    private func disableButton(buttonForDisable: RoundedButton) {
        buttonForDisable.setTitleColor(UIColor.black, for: .normal)
        buttonForDisable.backgroundColor = UIColor.white
        buttonForDisable.borderColor = UIColor.ProjectBlueColor
    }
    
    @IBAction func onGenerateTap(_ sender: Any) {
        hideTopMenu()
        testTextView.resignFirstResponder()
        if testTextView.text.count >= Constants.Values.MinSymbolsForTest {
            performSegue(withIdentifier: Constants.Segues.DeutchTester, sender: nil)
        } else {
            let title = NSLocalizedString("ErrorTitle", comment: "")
            let message = NSLocalizedString("NotEnoughtSymbols", comment: "")
            showAlert(title: title, message: message)
        }
    }
    
    @IBAction func onSpaceNumberTap(_ sender: Any) {
        if let tapedBtn = sender as? UIButton {
            let numberOfButton = Int(tapedBtn.title(for: .normal)!)!
            spaceIndex = numberOfButton - MinSpace
            setSpaceButtons()
        }
    }
    
    private func setSpaceButtons() {
        for btn in cTestButtons {
            let btnNumber = Int(btn.title(for: .normal)!)!
            if btnNumber - MinSpace == spaceIndex {
                activateButton(buttonForActivate: btn)
            } else {
                disableButton(buttonForDisable: btn)
            }
        }
    }
    
    //MARK: - TopMenu part
    @IBAction func onOpenMenuTap(_ sender: Any) {
        showTopMenu()
    }
    
    @IBAction func onMenuBtn1Tap(_ sender: Any) {
        hideTopMenu()
        testTextView.resignFirstResponder()
        performSegue(withIdentifier: Constants.Segues.WebViewSegue, sender: "https://lingua.com/de/deutsch/lesen/")
    }
    
    @IBAction func onMenuBtn2Tap(_ sender: Any) {
        hideTopMenu()
        testTextView.resignFirstResponder()
        performSegue(withIdentifier: Constants.Segues.WebViewSegue, sender: "https://www.pasch-net.de/de/pas/cls/sch/jus.html")
    }
    
    @IBAction func onMenuBtn3Tap(_ sender: Any) {
        hideTopMenu()
        testTextView.resignFirstResponder()
        performSegue(withIdentifier: Constants.Segues.WebViewSegue, sender: "https://www.yomunda.com/")
    }
    
    //MARK: - TopMenu
    private func showTopMenu() {
        testTextView.resignFirstResponder()
        guard topMenuView.isHidden else { return }
        topMenuView.isHidden = false
        let animator = UIViewPropertyAnimator(duration: Constants.Timers.CommonAnimationSeconds, curve: .easeIn, animations: {
            self.topMenuView.alpha = 1
        })
        animator.startAnimation()
    }
    
    private func hideTopMenu() {
        guard !topMenuView.isHidden else { return }
        let animator = UIViewPropertyAnimator(duration: Constants.Timers.CommonAnimationSeconds, curve: .easeIn, animations: {
            self.topMenuView.alpha = 0
        })
        animator.addCompletion({ (position) in
            self.topMenuView.isHidden = true
        })
        animator.startAnimation()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let deutchTesterVC = segue.destination as? DeutchTesterVC {
            deutchTesterVC.spaceForTasks = spaceIndex + MinSpace
            deutchTesterVC.testType = selectedTestType
            deutchTesterVC.textForTest = testTextView.text
        } else if let webVC = segue.destination as? SelectionWebVC {
            if let urlString = sender as? String {
                webVC.urlString = urlString
            }
        } else if let textSelector = segue.destination as? TextSelectorVC {
            textSelector.moduleDelegate = self
        }
    }
}

private extension DeutchCompilerVC {
    private func setOnTestLoadedActions() {
        hidePreloader()
        lessonsCollection.reloadData()
        setInfoLabel()
    }
    
    func setInfoLabel() {
        if let info = viewModel.testService.testDescription?.text {
            let infoString = info.replacingOccurrences(of: "\\n", with: "\n")
            let infoRanges = infoString.allRanges(of: "*")
            let attributed = NSMutableAttributedString.init(string: infoString)
            for index in 0 ..< infoRanges.count {
                attributed.addAttribute(.link, value: "\(index)", range: NSRange(infoRanges[index], in: infoString))
            }
            
            infoTextView.linkTextAttributes = [
                .foregroundColor: UIColor.systemGreen
            ]
            let font = UIFont(name: "SF Pro Display", size: 15.0)
            attributed.addAttributes([.font: font!], range: NSRange(location: 0, length: infoString.count))
            
            infoTextView.attributedText = attributed
        }
    }
}

//MARK: - TextView delegate
extension DeutchCompilerVC: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if textView == infoTextView {
            if let tappedIndex = Int(URL.absoluteString) {
                if let starString = viewModel.getStarByIndex(indexOfStar: tappedIndex) {
                    let title = NSLocalizedString("NoteString", comment: "")
                    showAlert(title: title, message: starString)
                }
            }
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            setPlaceholder()
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        hideTopMenu()
        return true
    }
    
    private func setPlaceholder() {
        testTextView.text = NSLocalizedString("TestTextPlaceholder", comment: "")
        testTextView.textColor = UIColor.lightGray
    }
    
}

extension DeutchCompilerVC: TextSelectorModuleDelegate {
    func setNewText(text: String) {
        testTextView.text = nil
        testTextView.textColor = UIColor.black
        testTextView.text = text
    }
}

//MARK: - CollectionView
extension DeutchCompilerVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private func setCollectionFlow() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 180, height: 180)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumLineSpacing = 1.0
        layout.minimumInteritemSpacing = 1.0
        lessonsCollection.setCollectionViewLayout(layout, animated: false)
        lessonsCollection.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 180, height: 180)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let td = viewModel.testService.testDescription {
            return td.list.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let lessonCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LessonCell", for: indexPath) as! LessonCellProtocol
        let description = viewModel.testService.arrayOfKeys![indexPath.row]
        let link = viewModel.testService.testDescription!.list[description]!
        
        lessonCell.setCellData(desc: description, youtubeLink: link, delegate: self)
        return lessonCell
    }
    
}

//MARK: - Protocols
extension DeutchCompilerVC: LessonCellDelegate {
    
    func onLecconCellTap(link: String) {
        if let url = URL(string: link) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
}

extension DeutchCompilerVC {
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unregisterForKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWasShown(notification: NSNotification) {
        hideKeyboardBtn.isHidden = false
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
            scrollForGenerator.contentInset = contentInsets
            scrollForGenerator.scrollIndicatorInsets = contentInsets
            scrollForGenerator.flashScrollIndicators()
            scrollForGenerator.setContentOffset(CGPoint(x: 0, y: keyboardHeight / 2), animated: true)
        }
    }
    
    @objc private func keyboardWillBeHidden(notification: NSNotification) {
        scrollForGenerator.contentInset = .zero
        scrollForGenerator.scrollIndicatorInsets = .zero
    }
    
}
