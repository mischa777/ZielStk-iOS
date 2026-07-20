// Created by Roman Voinitchi on 10/20/20
// Copyright © 2020 Roman Voinitchi. All rights reserved.


import Foundation

protocol TextSelectorVMProtocol {
    var onTextsLoaded: (() -> ())? { get set }
    var onLoadError: (() -> ())? { get set }
    var textLevels: [String] { get }
    var currentTexts: [TextDataModel] { get }
    
    func loadTexts()
    func switchToKey(newKeyIndex: Int)
}

final class TextSelectorVM: TextSelectorVMProtocol {
    
    var onTextsLoaded: (() -> ())?
    var onLoadError: (() -> ())?
    
    var textLevels: [String] = [String]()
    var currentTexts: [TextDataModel] = [TextDataModel]()
    
    private var textsService: TextsServiceProtocol?
    private var textsDict: [String : [TextDataModel]] = [String : [TextDataModel]]()
    
    func loadTexts() {
        textsService = TextsService()
        textsService!.onError = { [weak self] in
            self?.onLoadError?()
        }
        textsService!.onTextsLoaded = { [weak self] in
            self?.parseLoadedTexts()
        }
        textsService!.loadTextsFromCoreData()
    }
    
    private func parseLoadedTexts() {
        guard let texts = textsService?.allTexts else {
            onLoadError?()
            return
        }
        textLevels.removeAll()
        textsDict.removeAll()
        
//        texts.append(getTempTextModel(Answer: "C1", Description: "C1-1", Task: "C1-11111"))
//        texts.append(getTempTextModel(Answer: "C1", Description: "C1-2", Task: "C1-222222"))
//        texts.append(getTempTextModel(Answer: "C1", Description: "C1-3", Task: "C1-333333"))
//        texts.append(getTempTextModel(Answer: "B1", Description: "B1-1", Task: "B1-11111"))
//        texts.append(getTempTextModel(Answer: "A2", Description: "A2-1", Task: "A2-11111"))
//        texts.append(getTempTextModel(Answer: "A2", Description: "A2-2", Task: "A2-22222"))
        
        for text in texts {
            if !textLevels.contains(text.difficulty) {
                textLevels.append(text.difficulty)
            }
            if textsDict.index(forKey: text.difficulty) == nil {
                textsDict[text.difficulty] = [TextDataModel]()
            }
            textsDict[text.difficulty]!.append(text)
        }
        
        textLevels.sort { $0 < $1 }
        switchToKey(newKeyIndex: 0)
        onTextsLoaded?()
    }
    
    func switchToKey(newKeyIndex: Int) {
        guard let texts = textsDict[textLevels[newKeyIndex]] else {
            currentTexts = [TextDataModel]()
            return
        }
        currentTexts = texts
    }
    
//    private func getTempTextModel(Answer: String, Description: String, Task: String) -> TextDataModel {
//        var dict = [String : String]()
//        dict["Answer"] = Answer
//        dict["Description"] = Description
//        dict["Task"] = Task
//        return TextDataModel(firebaseDic: dict)
//    }
}
