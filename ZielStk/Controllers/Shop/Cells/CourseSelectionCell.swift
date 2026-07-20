//Created on 9/23/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import UIKit

protocol CourseSelectionCellProtocol: UITableViewCell {
    func setData(courseName: String, courseIndex: IndexPath, delegate: CourseSelectionDelegate)
}

class CourseSelectionCell: UITableViewCell, CourseSelectionCellProtocol {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    private unowned var courseSelectionDelegate: CourseSelectionDelegate!
    private var indexPath: IndexPath = IndexPath()
    
    func setData(courseName: String, courseIndex: IndexPath, delegate: CourseSelectionDelegate) {
        nameLabel.text = courseName
        indexPath = courseIndex
        courseSelectionDelegate = delegate
    }
    
    @IBAction func onCommonBtnTap(_ sender: Any) {
        courseSelectionDelegate.goToSubShop(indexPath: indexPath)
    }

}
