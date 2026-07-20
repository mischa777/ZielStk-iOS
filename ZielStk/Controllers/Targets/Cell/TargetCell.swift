//Created on 10/14/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import UIKit

protocol TargetCellProtocol: UITableViewCell {
    
    func setCellData(indexOfCell: Int, trgModel: TargetModelProtocol, delegate: TargetCellDelegate)
}

class TargetCell: UITableViewCell, TargetCellProtocol {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var desLabel: UILabel!
    @IBOutlet weak var indLabel: UILabel!
    
    private var index = 0
    private var targetModel: TargetModelProtocol?
    private unowned var targetCellDelegate: TargetCellDelegate!
    
    func setCellData(indexOfCell: Int, trgModel: TargetModelProtocol, delegate: TargetCellDelegate) {
        index = indexOfCell
        targetCellDelegate = delegate
        targetModel = trgModel
        print(trgModel.target_index)
        
        indLabel.text = "\(index + 1)"
        titleLabel.text = targetModel!.stk_data
        desLabel.text = targetModel!.test_data
    }

    @IBAction func onGoTap(_ sender: Any) {
        targetCellDelegate.goToTest(indexOfModel: index)
    }
    
}
