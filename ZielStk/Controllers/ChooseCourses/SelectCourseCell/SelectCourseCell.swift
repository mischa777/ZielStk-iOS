//Created on 10/1/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import UIKit

protocol SelectCourseCellProtocol: UITableViewCell {
    func setTempData(titleOfLabel: String, indexPath: IndexPath, isSelected: Bool, delegate: ChooseCourseDelegate)
}

class SelectCourseCell: UITableViewCell, SelectCourseCellProtocol {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cellSwitch: UISwitch!
    
    private unowned var delegate: ChooseCourseDelegate!
    private var section = 0
    private var row = 0
    private var isSetted = false
    
    func setTempData(titleOfLabel: String, indexPath: IndexPath, isSelected: Bool, delegate: ChooseCourseDelegate) {
        cellSwitch.isOn = isSelected
        isSetted = true
        self.delegate = delegate
        
        section = indexPath.section
        row = indexPath.row
        titleLabel.text = titleOfLabel
    }
    
    @IBAction func onSwitchTap(_ sender: Any) {
        if isSetted {
            delegate.onCourseStateChange(isSelected: cellSwitch.isOn, indexPath: IndexPath(row: row, section: section))
        }
    }
    
    
}
