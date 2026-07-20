//
//  CollegTestsVC.swift
//  ZielStk
//
//  Created by Roman Voinitchi on 9/17/19.
//  Copyright © 2019 Roman Voinitchi. All rights reserved.
//

import UIKit

class CollegTestsVC: UIViewController, PreloaderOpennerProtocol {
    
    @IBOutlet weak var nameCollegBtn: UIButton!
    @IBOutlet weak var testsTable: UITableView!
    
    private var viewModel: CollegTestsVMProtocol! {
        didSet {
            self.viewModel.onTestTypesLoaded = { [weak self] in
                self?.hidePreloader()
                self?.testsTable.reloadData()
            }
        }
    }
    
    var stkName = ""
    private var selectedSubTestIndex = 0
    
    override func viewDidLoad() {
        viewModel = CollegTestsVM()
        super.viewDidLoad()
        testsTable.tableFooterView = UIView(frame: .zero)
        nameCollegBtn.setTitle(stkName, for: .normal)
        
        showPreloader()
        viewModel.loadStksSelectedTestTypes(stkName: stkName)
    }
    
    @IBAction func onBackTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - Tablebiew delegate
extension CollegTestsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        goToSubShop(indexPath: indexPath)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].sectionsObjects.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(Constants.Cells.ShopHeaderHeight)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if viewModel.sections[indexPath.section].isExpanded {
            return CGFloat(Constants.Cells.ShopMainHeight)
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = ShopHeaderView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: CGFloat(Constants.Cells.ShopHeaderHeight))) as ShopHeaderViewProtocol
        headerView.setInactiveHeaderData(nameOfCollege: viewModel.sections[section].titleObject as! String, sectionNumber: section)
        return headerView.mainView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let commonCell = tableView.dequeueReusableCell(withIdentifier: "CourseSelectionCell", for: indexPath) as! CourseSelectionCellProtocol
        commonCell.setData(courseName: viewModel.sections[indexPath.section].sectionsObjects[indexPath.row] as! String, courseIndex: indexPath, delegate: self)
        return commonCell
    }

}

//MARK: - Protocols
extension CollegTestsVC: CourseSelectionDelegate {

    func goToSubShop(indexPath: IndexPath) {
        let selectionString = viewModel.getSelectedString(indexPath: indexPath)
        performSegue(withIdentifier: Constants.Segues.SubCollegsTest, sender: selectionString)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let subTestVC = segue.destination as? SubCollegTestVC {
            if let selectedDiscipline = sender as? String {
                subTestVC.selectedString = selectedDiscipline
            }
            subTestVC.stkName = stkName
        }
    }
}

protocol SelectTestCellDelegateProtocol: UIViewController {
    func selectTestAt(index: Int)
}
