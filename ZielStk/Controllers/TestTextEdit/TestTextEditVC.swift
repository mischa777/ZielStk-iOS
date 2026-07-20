//Created on 10/25/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import UIKit

class TestTextEditVC: UIViewController {
    
    @IBOutlet weak var testTextField: UITextField!
    
    unowned var editDelegate: TestTextEditDelegate!
    var correctWord = ""
    var wordToChange = ""
    var removedLetters = ""
    var indexOfWord = 0
    
    private var wasChanged = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setTextToField()
        print("\(correctWord)   \(wordToChange)   \(removedLetters)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        testTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        testTextField.resignFirstResponder()
    }
    
    private func setTextToField() {
        if editDelegate.editTestType == .clozeTest {
            testTextField.text = wordToChange.replacingOccurrences(of: " ", with: "")
        } else {
            let startIndexOffset = correctWord.count / 2
            let startIndex = wordToChange.index(wordToChange.startIndex, offsetBy: startIndexOffset)
            let substringToChange = wordToChange[startIndex ..< wordToChange.endIndex]
            testTextField.text = substringToChange.replacingOccurrences(of: " ", with: "")
        }
    }

    @IBAction func onCancelTap(_ sender: Any) {
        if let nc = navigationController {
            nc.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func onOkTap(_ sender: Any) {
        if wasChanged {
            editDelegate.changeWord(indexOfWord: indexOfWord, changedWord: getChangedWord(), record: true)
        }
        onCancelTap(self)
    }
    
    private func getChangedWord() -> String {
        let enteredText = testTextField.text == nil ? "" : testTextField.text!
        if editDelegate.editTestType == .cTest {
            return getCTestEnterdString(enteredText: enteredText)
        } else {
            return enteredText.count > 0 ? enteredText : "   "
        }
    }
   
    private func getCTestEnterdString(enteredText: String) -> String {
        let startIndexOffset = correctWord.count / 2
        let startIndex = correctWord.index(correctWord.startIndex, offsetBy: startIndexOffset)
        let correctStartSubstring = correctWord[correctWord.startIndex ..< startIndex]
        return String(correctStartSubstring) + enteredText
    }
}

extension TestTextEditVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let enteredSet = CharacterSet(charactersIn: string)
        if !enteredSet.isSubset(of: CharacterSet.alphanumerics) {
            return false
        }
        if !(testTextField.text ?? "").isEmpty {
            if testTextField.text!.count > 50 {
                return false
            }
        }
        wasChanged = true
        return true
    }
}
