//
//  SubCollegTestVC.swift
//  ZielStk
//
//  Created by Roman Voinitchi on 9/18/19.
//  Copyright © 2019 Roman Voinitchi. All rights reserved.
//

import UIKit

class SubCollegTestVC: UIViewController, PreloaderOpennerProtocol, AlertOpennerProtocol {
    
    @IBOutlet weak var nameTestBtn: UIButton!
    @IBOutlet weak var subTestsTable: UITableView!
    @IBOutlet weak var totalCountLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    
    var selectedString = ""
    var stkName = ""
    
    private var viewModel: SubCollegTestVMProtocol! {
        didSet {
            self.viewModel.onTestsLoaded = { [weak self] in
                self?.hidePreloader()
                self?.subTestsTable.reloadData()
                self?.totalCountLabel.text = self?.viewModel.structTotalText
            }
            self.viewModel.onDeutchPermitted = { [weak self] (testString) in
                self?.hidePreloader()
                self?.performSegue(withIdentifier: Constants.Segues.DeutchCompiler, sender: testString)
            }
            self.viewModel.onTestPermitted = { [weak self] (testString) in
                self?.hidePreloader()
                self?.performSegue(withIdentifier: Constants.Segues.MathTest, sender: testString)
            }
            self.viewModel.onTestRestricted = { [weak self] in
                self?.setTestRestrictionAlert()
            }
        }
    }

    override func viewDidLoad() {
        
        print("[VC] => SubCollegTestVC")
        
        viewModel = SubCollegTestVM()
        super.viewDidLoad()
        subTestsTable.tableFooterView = UIView(frame: .zero)
        bottomView.layer.masksToBounds = true
        bottomView.layer.cornerRadius = 10
//        totalCountLabel.text = nil
        
        showPreloader()
        viewModel.loadDisciplineTests(selectedCourseString: selectedString, stkName: stkName)
        nameTestBtn.setTitle(viewModel.courseType, for: .normal)
    }
    
    @IBAction func onBackTap(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    private func goToShopScreen() {
        performSegue(withIdentifier: Constants.Segues.ShopFromTests, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let shopVC = segue.destination as? ShopVC {
            shopVC.needBackBtn = true
        }
        if let mathTestVC = segue.destination as? MathTestParentVC {
            if let testName = sender as? String {
                mathTestVC.testTypeString = testName
            }
            mathTestVC.parentTestData = viewModel.parentString
        }
        if let deutchCompiler = segue.destination as? DeutchCompilerVC,
           let testName = sender as? String {
            deutchCompiler.testName = testName
        }
    }
    
    private func setTestRestrictionAlert() {
        hidePreloader()
        let title = NSLocalizedString("AttentionTitle", comment: "")
        let message = NSLocalizedString("NoPermissionsWarning", comment: "")
        let toShopTitle = NSLocalizedString("ToShopBtn", comment: "")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: toShopTitle, style: .destructive, handler: { (resul) in
            self.goToShopScreen()
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
//MARK: - TableView
extension SubCollegTestVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OneTestCell", for: indexPath) as! OneTestCellProtocol
        let name = viewModel.tests[indexPath.row]
        cell.setCellData(cellIndex: indexPath.row, nameOfTest: name, needImage: false, tasksCount: viewModel.totalExamsArray[name] ?? nil, selectDelegate: self)
        return cell
    }
    
}
//MARK: - Cell Protocol
extension SubCollegTestVC: SelectTestCellDelegateProtocol {
    func selectTestAt(index: Int) {
        if viewModel.opennedDiscipline == Constants.FirebaseTables.Deutch {
            showPreloader()
            let testType = viewModel.tests[index]
            if testType == "C-Test" || testType == "Lückentext" || testType == "C-Test, Lückentext" {
                viewModel.checkIfDeutchPurchased(testName: viewModel.tests[index])
            } else {
                viewModel.checkIfMathPurchased(disciplineName: viewModel.opennedDiscipline, testName: testType)
            }
        } else {
            showPreloader()
            viewModel.checkIfMathPurchased(disciplineName: viewModel.opennedDiscipline, testName: viewModel.tests[index])
        }
    }
}
