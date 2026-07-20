//
//  TranslationsVC.swift
//  ZielStk
//
//  Created by Roman Voinitchi on 9/18/19.
//  Copyright © 2019 Roman Voinitchi. All rights reserved.
//

import UIKit

class TranslationsVC: UIViewController, PreloaderOpennerProtocol, AlertOpennerProtocol {
    
    @IBOutlet weak var traslationsTable: UITableView!
    @IBOutlet weak var searchField: UITextField!
    
    private var translationToChange: TranslationModelProtocol!
    
    private var viewModel: TranslationsVMProtocol! {
        didSet {
            self.viewModel.onError = { [weak self] (title, message) in
                self?.hidePreloader()
                self?.showAlert(title: title, message: message)
            }
            self.viewModel.onTranslationsReady = { [weak self] in
                self?.hidePreloader()
                self?.reloadTableWithoutScroll()
            }
        }
    }
    
    override func viewDidLoad() {
        viewModel = TranslationsVM()
        super.viewDidLoad()
        traslationsTable.tableFooterView = UIView(frame: .zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showPreloader()
        viewModel.loadTranslations(needFirebaseLoad: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.clearData()
    }
    
    @IBAction func onSearchTap(_ sender: Any) {
        if searchField.isHidden {
            searchField.isHidden = false
            
            let animator = UIViewPropertyAnimator(duration: Constants.Timers.CommonAnimationSeconds, curve: .easeIn, animations: {
                self.searchField.alpha = 1
            })
            animator.startAnimation()
            
            searchField.becomeFirstResponder()
        } else {
            
            let animator = UIViewPropertyAnimator(duration: Constants.Timers.CommonAnimationSeconds, curve: .easeIn, animations: {
                self.searchField.alpha = 0
            })
            animator.addCompletion({ (position) in
                self.searchField.text = nil
                self.searchField.isHidden = true
            })
            animator.startAnimation()
            
            searchField.resignFirstResponder()
            searchField.text = nil
            viewModel.searchedString = searchField.text
        }
    }
    
    @IBAction func onSearchEditChange(_ sender: Any) {
        viewModel.searchedString = searchField.text
    }
    
}

//MARK: - Table
extension TranslationsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tranlations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TranslationCell", for: indexPath) as! TranslationCellProtocol
        cell.setCellData(translationModel: viewModel.tranlations[indexPath.row], editTranslationDelegate: self)
        return cell
    }
    
    private func reloadTableWithoutScroll() {
        let contentOffset = traslationsTable.contentOffset
        traslationsTable.reloadData()
        traslationsTable.setContentOffset(contentOffset, animated: false)
    }
}

//MARK: - Protocols
extension TranslationsVC: EditTranslationDelegateProtocol, TranslationToChangeDelegate {
    
    var currentTranslationModel: TranslationModelProtocol {
        get {
            return translationToChange
        }
    }
    
    func saveTranlationWith(newTranlsation: String) {
        translationToChange.translation = newTranlsation
        translationToChange.saveToCoreData()
        reloadTableWithoutScroll()
    }
    
    func editTranslation(tranlsationProtocol: TranslationModelProtocol) {
        self.translationToChange = tranlsationProtocol
        performSegue(withIdentifier: Constants.Segues.AddTranlation, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let editTranslationVC = segue.destination as? EditTranslationVC {
            editTranslationVC.translationToChangeDelegate = self
        }
    }
    
}

protocol EditTranslationDelegateProtocol: TranslationsVC {
    func editTranslation(tranlsationProtocol: TranslationModelProtocol)
}

protocol TranslationToChangeDelegate: TranslationsVC {
    var currentTranslationModel: TranslationModelProtocol { get }
    func saveTranlationWith(newTranlsation: String)
}
