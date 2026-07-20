//
//  ChooseCoursesVC.swift
//  ZielStk
//
//  Created by Roman Voinitchi on 9/11/19.
//  Copyright © 2019 Roman Voinitchi. All rights reserved.
//

import UIKit

class ChooseCoursesVC: UIViewController, PreloaderOpennerProtocol, AlertOpennerProtocol {
    
    @IBOutlet weak var coursesTableView: UITableView!
    
    private var viewModel: ChooseCoursesVMProtocol! {
        didSet {
            self.viewModel.onStksError = { [weak self] in
                self?.hidePreloader()
                let title = NSLocalizedString("ErrorTitle", comment: "")
                let message = NSLocalizedString("NoStksError", comment: "")
                self?.showAlert(title: title, message: message)
            }
            self.viewModel.onStksLoaded = { [weak self] in
                self?.hidePreloader()
                self?.coursesTableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        viewModel = ChooseCoursesVM()
        super.viewDidLoad()
        
        coursesTableView.tableFooterView = UIView(frame: .zero)
        coursesTableView.reloadData()
        
        showPreloader()
        viewModel.loadStks()
    }
    
    @IBAction func onOkTap(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

//MARK: - Tableview
extension ChooseCoursesVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].sectionsObjects.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(Constants.Cells.CourseCellHeight)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if viewModel.sections[indexPath.section].isExpanded {
            return CGFloat(Constants.Cells.CourseCellSubHeight)
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView: CourseSelectionTitleViewProtocol = CourseSelectionTitleView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: CGFloat(Constants.Cells.CourseCellHeight)))
        let currentStk = viewModel.sections[section].titleObject as! StkModel
        let totalCount = currentStk.coursesCount
        let selectedCount = viewModel.selectionService.getSelectedCoursesCount(stkName: currentStk.stk_name)
        headerView.setStartData(section: section, title: currentStk.stk_name, logoUrl: currentStk.logo, totalCoursesCount: totalCount, selectedCoursesCount: selectedCount, delegate: self)
        return headerView.mainView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let courseSelectionCell = tableView.dequeueReusableCell(withIdentifier: "SelectCourseCell", for: indexPath) as! SelectCourseCellProtocol
        let currentStk = viewModel.sections[indexPath.section].titleObject as! StkModel
        let courseName = viewModel.sections[indexPath.section].sectionsObjects[indexPath.row] as! String
        let isSelected = viewModel.selectionService.courseIsSelected(stkName: currentStk.stk_name, courseName: courseName)
        courseSelectionCell.setTempData(titleOfLabel: courseName, indexPath: indexPath, isSelected: isSelected, delegate: self)
        return courseSelectionCell
    }
}

//MARK: - Protocols
extension ChooseCoursesVC: StkHeaderExpandDelegate, ChooseCourseDelegate {
    
    func onCourseStateChange(isSelected: Bool, indexPath: IndexPath) {
        let stkModel = viewModel.sections[indexPath.section].titleObject as! StkModel
        let title = stkModel.stk_name
        let courseName = stkModel.courses.courses[indexPath.row].courseName
        if isSelected {
            viewModel.selectionService.saveSelection(title: title, course: courseName)
        } else {
            viewModel.selectionService.removeSelection(title: title, course: courseName)
        }
        
        coursesTableView.beginUpdates()
        coursesTableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
        coursesTableView.endUpdates()
    }
    
    func expandSection(section: Int) {
        viewModel.changeSectionExpand(section: section)
        
        coursesTableView.beginUpdates()
        for i in 0 ..< viewModel.sections[section].sectionsObjects.count {
            coursesTableView.reloadRows(at: [IndexPath(row: i, section: section)], with: .automatic)
        }
        coursesTableView.endUpdates()
    }
}

protocol StkHeaderExpandDelegate: UIViewController {
    func expandSection(section: Int)
}

protocol ChooseCourseDelegate: UIViewController {
    func onCourseStateChange(isSelected: Bool, indexPath: IndexPath)
}
