//
//  TargetsVC.swift
//  ZielStk
//
//  Created by Roman Voinitchi on 9/18/19.
//  Copyright © 2019 Roman Voinitchi. All rights reserved.
//

import UIKit

class TargetsVC: UIViewController, PreloaderOpennerProtocol {

    @IBOutlet weak var targetsTable: UITableView!
    @IBOutlet weak var dummyView: UIView!
    
    private var viewModel: TargetsVMProtocol! {
        didSet {
            self.viewModel.onTargetsLoaded = { [weak self] in
                self?.setTargetsLoadedActions()
            }
        }
    }
    
    override func viewDidLoad() {
        viewModel = TargetsVM()
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hidePreloader()
        showPreloader()
        targetsTable.isHidden = true
        dummyView.isHidden = true
        viewModel.loadTargets()
    }

    private func setTargetsLoadedActions() {
        hidePreloader()
        dummyView.isHidden = viewModel.targets.count != 0
        targetsTable.isHidden = viewModel.targets.count == 0
        targetsTable.reloadData()
    }
}

//MARK: - Tableview delegate
extension TargetsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.targets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TargetCell", for: indexPath) as! TargetCellProtocol
        cell.setCellData(indexOfCell: indexPath.row, trgModel: viewModel.targets[indexPath.row], delegate: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let removeTitle = NSLocalizedString("RemoveString", comment: "")
        let deleteAction = UIContextualAction(style: .destructive, title: removeTitle, handler: { contextAction, view, _  in
            self.showPreloader()
            self.viewModel.removeTargetAt(index: indexPath.row)
        })
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
}

//MARK: - Delegates
extension TargetsVC: TargetCellDelegate {
    func goToTest(indexOfModel: Int) {
        
        let targetModel = viewModel.targets[indexOfModel]
        let separatedString = targetModel.test_data.components(separatedBy: Constants.Values.StringSeparator)
        let discipline = separatedString[0]
        
        print("[Discipline] => \(discipline)")
        
        if discipline == Constants.FirebaseTables.Deutch {
            print("[Deutch]")
            performSegue(withIdentifier: Constants.Segues.MathTest, sender: targetModel)
        } else {
            print("[Math]")
            performSegue(withIdentifier: Constants.Segues.MathTest, sender: targetModel)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mathTestVC = segue.destination as? MathTestParentVC {
            if let targetModel = sender as? TargetModelProtocol {
                mathTestVC.testTypeString = targetModel.test_data
                mathTestVC.parentTestData = targetModel.stk_data
                mathTestVC.lastSolvedIndex = Int(targetModel.target_index)
            }
        }
    }
    
}

protocol TargetCellDelegate: TargetsVC {
    func goToTest(indexOfModel: Int)
}
