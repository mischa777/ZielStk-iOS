//Created on 10/24/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import Foundation
import UIKit

protocol DeutchTesterVMProtocol {
    
    var onTestReady: (() -> ())? { get set }
    var attributedString: NSMutableAttributedString { get }
    var enteredWords: [String] { get }
    var correctWords: [String] { get }
    var ranges: [Range<String.Index>] { get }
    var removedLetters: [String] { get }
    
    func setTest(type: DeutchCompilerVM.DeutchTestTypes, space: Int, text: String)
    func setEnteredWordAtIndex(indexOfWord: Int, newWord: String)
    func renewTestData()
    func setStartTestString()
}

final class DeutchTesterVM: DeutchTesterVMProtocol {
    
    private let UnusedSmbolsLength = 50
    
    var onTestReady: (() -> ())?
    var attributedString: NSMutableAttributedString = NSMutableAttributedString(string: "")
    
    var ranges = [Range<String.Index>]()
    var correctWords = [String]()
    var enteredWords = [String]()
    var removedLetters = [String]()
    
    private var testType: DeutchCompilerVM.DeutchTestTypes = .clozeTest
    private var spaceForTasks: Int = 2
    private var textForTest: String = ""
    private var frontiers = (startFrontier: 0, endFrontier: 0)
    
    func setTest(type: DeutchCompilerVM.DeutchTestTypes, space: Int, text: String) {
        self.testType = type
        self.spaceForTasks = space
        self.textForTest = text
        
        setTestFrontiers()
        devideToWords()
        
        attributedString = NSMutableAttributedString.init(string: textForTest)
        onTestReady?()
    }
    
    private func setTestFrontiers() {
        var sentences = [String]()
        textForTest.enumerateSubstrings(in: textForTest.startIndex ..< textForTest.endIndex, options: .bySentences, { substring, _, _, _ in
            if let ss = substring {
                sentences.append(ss)
            }
        })
        
        if sentences.count > 2 {
            frontiers.startFrontier = sentences.first!.count
            frontiers.endFrontier = sentences.last!.count
        } else {
            frontiers.startFrontier = UnusedSmbolsLength
            frontiers.endFrontier = UnusedSmbolsLength
        }
    }
    
    private func devideToWords() {
        correctWords.removeAll()
        ranges.removeAll()
        enteredWords.removeAll()
        removedLetters.removeAll()
        let startIndex = textForTest.index(textForTest.startIndex, offsetBy: frontiers.startFrontier)
        let endIndex = textForTest.index(textForTest.endIndex, offsetBy: -frontiers.endFrontier)
        
        textForTest.enumerateSubstrings(in: startIndex ..< endIndex, options: .byWords, { substring, wordRange, _, _ in
            if let ss = substring {
                
                let numbersRange = ss.rangeOfCharacter(from: .decimalDigits)
                if numbersRange == nil {
                    self.correctWords.append(ss)
                    self.ranges.append(wordRange)
                    
                    if self.testType == .clozeTest {
                        self.enteredWords.append(self.getFullTestString(fullWord: ss))
                    } else {
                        self.enteredWords.append(self.getSeparatedTestString(fullWord: ss))
                    }
//                    print("\(ss)-\(ss.count)   \(self.enteredWords.last!)-\(self.enteredWords.last!.count)   \(self.removedLetters.last!)-\(self.removedLetters.last!.count)")
                }
            }
        })
    }
    
    private func getSeparatedTestString(fullWord: String) -> String {
        let startIndexOffset = fullWord.count / 2
        let startIndex = fullWord.index(fullWord.startIndex, offsetBy: startIndexOffset)
        let substringToChange = fullWord[startIndex ..< fullWord.endIndex]
        self.removedLetters.append(String(substringToChange))
        var emptyString = ""
        while emptyString.count + startIndexOffset < fullWord.count {
            emptyString += " "
        }
        let resultWord = fullWord.replacingOccurrences(of: substringToChange, with: emptyString)
        return resultWord
    }
    
    private func getFullTestString(fullWord: String) -> String {
        var str = ""
        self.removedLetters.append(fullWord)
        for _ in 0 ..< fullWord.count {
            str += " "
        }
        return str
    }
    
    func setEnteredWordAtIndex(indexOfWord: Int, newWord: String) {
        let previousWord = enteredWords[indexOfWord]
        enteredWords[indexOfWord] = newWord
        attributedString.mutableString.replaceCharacters(in: NSRange(ranges[indexOfWord], in: attributedString.string), with: newWord)
        let lengthDifference = newWord.count - previousWord.count
        if lengthDifference != 0 {
            chanegeRanges(startChangeIndex: indexOfWord, difference: lengthDifference)
        }
    }
    
    private func chanegeRanges(startChangeIndex: Int, difference: Int) {
//        print("\(ranges[startChangeIndex].lowerBound.utf16Offset(in: attributedString.string))   \(ranges[startChangeIndex].upperBound.utf16Offset(in: attributedString.string))")
        ranges[startChangeIndex] = getNewRange(lowerBound: ranges[startChangeIndex].lowerBound.utf16Offset(in: attributedString.string), upperBound: ranges[startChangeIndex].upperBound.utf16Offset(in: attributedString.string) + difference)
        for index in startChangeIndex + 1 ..< ranges.count {
            ranges[index] = getNewRange(lowerBound: ranges[index].lowerBound.utf16Offset(in: attributedString.string) + difference, upperBound: ranges[index].upperBound.utf16Offset(in: attributedString.string) + difference)
        }
    }
    
    private func getNewRange(lowerBound: Int, upperBound: Int) -> Range<String.Index> {
        let startIndex = attributedString.string.index(attributedString.string.startIndex, offsetBy: lowerBound)
        let endIndex = attributedString.string.index(attributedString.string.startIndex, offsetBy: upperBound)
        return startIndex ..< endIndex
    }
   
    func renewTestData() {
        devideToWords()
        
        attributedString = NSMutableAttributedString.init(string: textForTest)
        onTestReady?()
    }
    
    func setStartTestString() {
        
        for index in stride(from: spaceForTasks, to: ranges.count, by: spaceForTasks) {
            attributedString.mutableString.replaceCharacters(in: NSRange(ranges[index], in: attributedString.string), with: enteredWords[index])
            attributedString.addAttribute(.link, value: "\(index)", range: NSRange(ranges[index], in: textForTest))
            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(ranges[index], in: textForTest))
        }
        
        let font = UIFont(name: "SF Pro Display", size: 18.0)
        attributedString.addAttributes([.font: font!], range: NSRange(location: 0, length: textForTest.count))
        
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .justified
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: textForTest.count))
    }
}
