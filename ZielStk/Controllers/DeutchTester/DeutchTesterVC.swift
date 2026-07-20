//Created on 10/23/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.


import UIKit

class DeutchTesterVC: UIViewController, PreloaderOpennerProtocol, AlertOpennerProtocol {
    
    private var oldResult: [String: Any]? {
        get {
            UserDefaults.standard.dictionary(forKey: textForTest)
        }
        set {
            print("[oldResult] => Set")
            UserDefaults.standard.setValue(newValue, forKey: textForTest)
            UserDefaults.standard.synchronize()
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var testTextView: UITextView!
    @IBOutlet weak var checkTestBtn: RoundedButton!
    @IBOutlet weak var scrollBtn: UIButton!
    
    var testType: DeutchCompilerVM.DeutchTestTypes = .clozeTest
    var spaceForTasks: Int = 2
    var textForTest: String = ""
    
    private var isCompleted = false
    private var isTestingComplete = false
    private var isScrolledDown = false
    
    private var viewModel: DeutchTesterVMProtocol! {
        didSet {
            self.viewModel.onTestReady = { [weak self] in
                self?.setOnTestCompleteActions()
            }
        }
    }
    
    override func viewDidLoad() {
        viewModel = DeutchTesterVM()
        super.viewDidLoad()
        setTestTextBorder()
        titleLabel.text = testType.rawValue
        
        showPreloader()
        viewModel.setTest(type: testType, space: spaceForTasks, text: textForTest)
        
        if let lastTest = oldResult {
            for (key, value) in lastTest {
                print("KEY: \(key) VALUE: \(value)")
                if let word = value as? String {
                    changeWord(indexOfWord: Int(key)!, changedWord: word, record: false)
                }
            }
            //let _ = setTestErrors()
        }
    }
    
    private func setTestTextBorder() {
        testTextView.layer.borderWidth = 1
        testTextView.layer.cornerRadius = 3
        testTextView.layer.borderColor = UIColor.lightGray.cgColor
        testTextView.linkTextAttributes = [
            .foregroundColor: UIColor.black
        ]
    }
    
    private func setOnTestCompleteActions() {
        
        print("[setOnTestCompleteActions]")
        
        hidePreloader()
        isTestingComplete = false
        viewModel.setStartTestString()
        testTextView.attributedText = viewModel.attributedString
        testTextView.flashScrollIndicators()
    }
    
    @IBAction func onCheckTap(_ sender: Any) {
        
        print("[CHECK]")
        
        if !isCompleted {
            print("[0]")
            showFinalDialogue()
        } else {
            print("[1]")
            goBack()
        }
    }
    
    @IBAction func onScrollTap(_ sender: Any) {
        
        goBack()
        
//        if isScrolledDown {
//            let animator = UIViewPropertyAnimator(duration: Constants.Timers.CommonAnimationSeconds, curve: .easeIn, animations: {
//                self.scrollBtn.transform = CGAffineTransform(rotationAngle: 0)
//            })
//            animator.startAnimation()
//            testTextView.setContentOffset(.zero, animated: true)
//        } else {
//            let animator = UIViewPropertyAnimator(duration: Constants.Timers.CommonAnimationSeconds, curve: .easeIn, animations: {
//                self.scrollBtn.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
//            })
//            animator.startAnimation()
//            let bottom = self.testTextView.contentSize.height - self.testTextView.bounds.size.height
//            self.testTextView.setContentOffset(CGPoint(x: 0, y: bottom), animated: true)
//        }
//        isScrolledDown = !isScrolledDown
    }
    
    //MARK: - Complete dialogue
    private func showFinalDialogue() {
        
        self.isTestingComplete = true
        
        let percents = setTestErrors()
        let title = NSLocalizedString("ResultsTitle", comment: "")
        let errorsBtnTitle = NSLocalizedString("ShowErrorsBtn", comment: "")
        let tryAgainTitle = NSLocalizedString("TryAgainBtn", comment: "")
        
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: errorsBtnTitle, style: .default, handler: { alertAction in
                self.setTestCompletion()
            }))
            alert.addAction(UIAlertAction(title: tryAgainTitle, style: .default, handler: { alertAction in
                self.oldResult = nil
                self.onTryAgainAction()
            }))
        
        let message = "\n\(percents)%\n"
        let font = UIFont.boldSystemFont(ofSize: 30)
        let attributeString = NSMutableAttributedString(string: message)
        attributeString.addAttributes([.font: font], range: NSRange(location: 0, length: message.count))
        attributeString.addAttribute(.foregroundColor, value: getPercentsColor(percents: percents), range: NSRange(location: 0, length: message.count))
        
        alert.setValue(attributeString, forKey: "attributedMessage")
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func getPercentsColor(percents: Int) -> UIColor {
        if percents < 30 {
            return UIColor.red
        } else if percents > 69 {
            return UIColor.green
        } else {
            return UIColor.yellow
        }
    }
    
//    private func onTellFrindsAction() {
//        setTestCompletion()
//        callShareDialog()
//    }
    
    private func onTryAgainAction() {
        viewModel.renewTestData()
    }
    
    private func setTestCompletion() {
        isCompleted = true
        let finishBtnTitle = NSLocalizedString("EndTestBtn", comment: "")
        checkTestBtn.setTitle(finishBtnTitle, for: .normal)
    }
    
    private func goBack() {
        if let nc = navigationController {
            nc.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
//MARK: errors
    private func setTestErrors() -> Int {
        
        print("[setTestErrors]")
        
        var totalTasks = 0
        var correctAnswers = 0
        
        for index in stride(from: spaceForTasks, to: viewModel.ranges.count, by: spaceForTasks) {
            totalTasks += 1
            let isCorrect = viewModel.correctWords[index].lowercased() == viewModel.enteredWords[index].lowercased()
            correctAnswers = isCorrect ? correctAnswers + 1 : correctAnswers
            let selectionColor = isCorrect ? UIColor.green : UIColor.red
            
            viewModel.attributedString.addAttribute(.backgroundColor, value: selectionColor, range: NSRange(viewModel.ranges[index], in: textForTest))
        }
        testTextView.attributedText = viewModel.attributedString
        
        return correctAnswers * 100 / totalTasks
    }
    
    private func callShareDialog() {
        let imageForShare = UIImage(named: "LogoMain")!
        let textForShare = "ZielStudienkolleg"
        let urlForShare = URL(string: "https://zielstudienkolleg.de")!
        let items:[Any] = [imageForShare, textForShare, urlForShare]
        
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        ac.popoverPresentationController?.sourceView = self.view
        ac.excludedActivityTypes = [.airDrop, .openInIBooks, .saveToCameraRoll]
        self.present(ac, animated: true, completion: nil)
    }
    
}

//MARK: - Protocols
extension DeutchTesterVC: UITextViewDelegate, TestTextEditDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let selectedIndex = Int(URL.absoluteString)!
        if !isTestingComplete {
            print(viewModel.correctWords[selectedIndex])
            performSegue(withIdentifier: Constants.Segues.TextEdit, sender: selectedIndex)
        } else {
            let title = NSLocalizedString("AttentionTitle", comment: "")
            let message = viewModel.correctWords[selectedIndex]
            self.showAlert(title: title, message: message)
        }
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let testEditVC = segue.destination as? TestTextEditVC {
            testEditVC.editDelegate = self
            if let index = sender as? Int {
                testEditVC.wordToChange = viewModel.enteredWords[index]
                testEditVC.indexOfWord = index
                testEditVC.removedLetters = viewModel.removedLetters[index]
                testEditVC.correctWord = viewModel.correctWords[index]
            }
        }
    }
    
    var editTestType: DeutchCompilerVM.DeutchTestTypes {
        get {
            return testType
        }
    }
    
    func changeWord(indexOfWord: Int, changedWord: String, record: Bool = true) {
        
        print("changeWord")
        
        if record {
            var newDict: [String: Any] = oldResult ?? [:]
                newDict["\(indexOfWord)"] = changedWord
                oldResult = newDict
        }
        
        viewModel.setEnteredWordAtIndex(indexOfWord: indexOfWord, newWord: changedWord)
        testTextView.attributedText = viewModel.attributedString
    }
}

protocol TestTextEditDelegate: UIViewController {
    var editTestType: DeutchCompilerVM.DeutchTestTypes { get }
    
    func changeWord(indexOfWord: Int, changedWord: String, record: Bool)
}


