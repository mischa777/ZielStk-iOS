//Created on 10/9/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import UIKit

class MathTestParentVC: UIViewController, PreloaderOpennerProtocol, AlertOpennerProtocol {
    
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var targetBtnView: UIView!
    @IBOutlet weak var sortBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet var selectionLines: [UIView]!
    @IBOutlet weak var toastView: UIView!
    @IBOutlet weak var topMenuView: ShadowedView!
    @IBOutlet weak var testsTable: UITableView!
    @IBOutlet weak var lessonsCollection: UICollectionView!
    
    private var viewModel: MathTestParentVMProtocol! {
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
            self.viewModel.onTipsStep = { [weak self] tipText, indexOfTip in
                print("[2]")
                self?.showTip(with: tipText, tip: indexOfTip)
            }
            self.viewModel.onScreenshotProtectionNeeded = { [weak self] in
                print("[3]")
                self?.setFakeScreen()
                self?.setScreenshotTimer()
                self?.setScreenshotAlert()
            }
        }
    }
    
    private var fakeView: UIView?
    
    var testTypeString = ""
    var parentTestData = ""
    var lastSolvedIndex = 0

    //MARK: - Main part
    override func viewDidLoad() {
        
        print("[VC] => MathTestParentVC")
        
        viewModel = MathTestParentVM()
        super.viewDidLoad()
        setSortState(newSortState: .tests)
        setCollectionFlow()
        
        showPreloader()
        viewModel.checkTips()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.setProtection()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.removeProtection()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
         viewModel.loadTest(withName: testTypeString)
    }
    
    private func setOnTestLoadedActions() {
        hidePreloader()
        testsTable.reloadData()
        lessonsCollection.reloadData()
        if let to = viewModel.testService.tasks {
            if to.count > 0 {
                testsTable.scrollToRow(at: IndexPath(row: lastSolvedIndex, section: 0), at: .top, animated: false)
            }
        }
        if let tn = viewModel.testService.localizedTestName {
            backBtn.setTitle(tn, for: .normal)
        }
        setInfoLabel()
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
    
    private func setInfoLabel() {
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
    
//    private func setScreenshotAlert() {
//        let mainQueue = OperationQueue.main
//        NotificationCenter.default.addObserver(forName: UIApplication.userDidTakeScreenshotNotification, object: nil, queue: mainQueue, using: { [weak self] notification  in
//            self?.hideTopMenu()
//            let title = NSLocalizedString("AttentionTitle", comment: "")
//            let message = NSLocalizedString("ScreenshotCopyrights", comment: "")
//            self?.showAlert(title: title, message: message)
//        })
//    }
    
    @IBAction func onBackTap(_ sender: Any) {
        if let nc = navigationController {
            nc.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func onSortTap(_ sender: Any) {
        showTopMenu()
    }
    
    @IBAction func onTargetBtnTap(_ sender: Any) {
        hideTopMenu()
        setToastAnimation()
        viewModel.saveNewTarget(targetIndex: lastSolvedIndex, stkData: parentTestData, testData: testTypeString)
    }
    
    private func setToastAnimation() {
        guard toastView.alpha == 0 else { return }
        let animator = UIViewPropertyAnimator(duration: Constants.Timers.CommonAnimationSeconds, curve: .easeIn, animations: {
            self.toastView.alpha = 1
        })
        animator.startAnimation()
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Timers.AppearenceSeconds, execute: {
            let animator = UIViewPropertyAnimator(duration: Constants.Timers.CommonAnimationSeconds, curve: .easeIn, animations: {
                self.toastView.alpha = 0
            })
            animator.startAnimation()
        })
    }
    
    //MARK: - Change viewcontrollers
    private func setSortState(newSortState: MathTestParentVM.ViewStates) {
        sortBtn.isHidden = newSortState != .tests
        targetBtnView.isHidden = newSortState != .tests
        for index in 0 ..< selectionLines.count {
            selectionLines[index].isHidden = index != newSortState.rawValue
        }
        testsTable.isHidden = newSortState != .tests
        infoTextView.isHidden = newSortState != .infos
        lessonsCollection.isHidden = newSortState != .lessons
    }
    
    @IBAction func onTestsTap(_ sender: Any) {
        hideTopMenu()
        setSortState(newSortState: .tests)
    }
    
    @IBAction func onInfoTap(_ sender: Any) {
        hideTopMenu()
        setSortState(newSortState: .infos)
    }
    
    @IBAction func onMaterialsTap(_ sender: Any) {
        hideTopMenu()
        setSortState(newSortState: .lessons)
    }
    
    //MARK: - TopMenu
    private func showTopMenu() {
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
    
    private func setNewSort(sortType: MathTestParentVM.TestsSortTypes) {
        hideTopMenu()
        viewModel.testService.sortTest(sortType: sortType)
        testsTable.reloadData()
    }
    
    @IBAction func onMenuBtn1Tap(_ sender: Any) {
        setNewSort(sortType: .order)
    }
    
    @IBAction func onMenuBtn2Tap(_ sender: Any) {
        setNewSort(sortType: .solved)
    }
    
    @IBAction func onMenuBtn3Tap(_ sender: Any) {
        setNewSort(sortType: .unsolved)
    }
    
    @IBAction func onMenuBtn4Tap(_ sender: Any) {
        setNewSort(sortType: .exams)
    }
    
}

private extension MathTestParentVC {
    func showTip(with text: String, tip index: Int) {
        let title = "\(NSLocalizedString("TipTitleText", comment: "")) \(index)/\(viewModel.totalTipsNumber)"
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        
        if index < viewModel.totalTipsNumber {
            let skipAction = UIAlertAction(title: NSLocalizedString("TipsSkipText", comment: ""), style: .destructive, handler: nil)
            let nextAction = UIAlertAction(title: NSLocalizedString("TipNextText", comment: ""), style: .default) { [weak self] action in
                self?.viewModel.setNextTip()
            }
            alert.addAction(nextAction)
            alert.addAction(skipAction)
        } else {
            let closeAction = UIAlertAction(title: NSLocalizedString("TipsSkipText", comment: ""), style: .default, handler: nil)
            alert.addAction(closeAction)
        }
        
        self.present(alert, animated: true, completion: nil)
    }
}

//MARK: - TableView
extension MathTestParentVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let to = viewModel.testService.tasks {
            return to.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mathTestCell = tableView.dequeueReusableCell(withIdentifier: "MathTestCell", for: indexPath) as! MathTestCellProtocol
        mathTestCell.setData(taskModel: viewModel.testService.tasks![indexPath.row], index: indexPath.row, delegate: self)
        return mathTestCell
    }
    
}

//MARK: - CollectionView
extension MathTestParentVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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

//MARK: - Textview delegate
extension MathTestParentVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if let tappedIndex = Int(URL.absoluteString) {
            if let starString = viewModel.getStarByIndex(indexOfStar: tappedIndex) {
                let title = NSLocalizedString("NoteString", comment: "")
                showAlert(title: title, message: starString)
            }
        }
        return false
    }
}

//MARK: - Protocols
extension MathTestParentVC: LessonCellDelegate, TestCellDelegate {
    
    func showBigImage(image: UIImage) {
        hideTopMenu()
        performSegue(withIdentifier: Constants.Segues.BigImageSegue, sender: image)
    }
    
    func setLastSolved(index: Int) {
        hideTopMenu()
        lastSolvedIndex = index
        viewModel.testService.saveTests()
    }
    
    func onLecconCellTap(link: String) {
        if let url = URL(string: link) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let bigImageVC = segue.destination as? BigImageVC {
            if let img = sender as? UIImage {
                bigImageVC.imageToShow = img
            }
        }
    }
    
}

protocol LessonCellDelegate: UIViewController {
    func onLecconCellTap(link: String)
}

protocol TestCellDelegate: UIViewController {
    func showBigImage(image: UIImage)
    func setLastSolved(index: Int)
}

private extension MathTestParentVC {
    func setFakeScreen() {
        guard fakeView == nil else {
            return
        }
        fakeView = UIView(frame: UIScreen.main.bounds)
        fakeView?.backgroundColor = UIColor(red: 187 / 255, green: 219 / 255, blue: 243 / 255, alpha: 1)
        self.view.addSubview(fakeView!)
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "LogoMain")
        imageView.contentMode = .scaleAspectFit
        fakeView!.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: fakeView!.topAnchor, constant: 100).isActive = true
        imageView.bottomAnchor.constraint(equalTo: fakeView!.bottomAnchor, constant: -100).isActive = true
        imageView.trailingAnchor.constraint(equalTo: fakeView!.trailingAnchor, constant: -100).isActive = true
        imageView.leadingAnchor.constraint(equalTo: fakeView!.leadingAnchor, constant: 100).isActive = true
    }
    
    func setScreenshotAlert() {
        self.hideTopMenu()
        
        guard !Profile.shared.subsDeleted else { return }
        let title = NSLocalizedString("Copyright_Title", comment: "").replacingOccurrences(of: "{NA}", with: "\(5 - Profile.copyrightTrigger)")
        let message = NSLocalizedString("Copyright_Message", comment: "")
        showAlertMess(title: title, message: message, buttonTitle: "OK") {
            Profile.copyrightTrigger += 1
        }
    }
    
    func setScreenshotTimer() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { [weak self] timer in
            self?.navigationController?.popViewController(animated: true)
        })
    }
}
