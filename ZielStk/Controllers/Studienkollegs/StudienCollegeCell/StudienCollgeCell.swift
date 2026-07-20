//
//  StudienCollgeCell.swift
//  ZielStk
//
//  Created by Roman Voinitchi on 9/17/19.
//  Copyright © 2019 Roman Voinitchi. All rights reserved.
//

import UIKit
import SDWebImage

protocol StudienCollgeCellProtocol: UITableViewCell {
    func setCellData(cellIndex: Int, stk: StkModelProtocol, tapsDelegate: StudienCellDelegateProtocol)
}

class StudienCollgeCell: UITableViewCell, StudienCollgeCellProtocol {
    
    private let LabelSpace: CGFloat = 25
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var studienNameLabel: UILabel!
    @IBOutlet weak var studienImage: UIImageView!
    
    private var indexOfCell = 0
    private unowned var mainTapDelegate: StudienCellDelegateProtocol!
    private var stkOfCell: StkModelProtocol?
    
    func setCellData(cellIndex: Int, stk: StkModelProtocol, tapsDelegate: StudienCellDelegateProtocol) {
        studienImage.image = nil
        stkOfCell = stk
        indexOfCell = cellIndex
        mainTapDelegate = tapsDelegate
        setTapableDescriptionLabel()
        studienNameLabel.text = stk.stk_name
        if let imgUrl = URL(string: stk.picture) {
            studienImage.sd_setImage(with: imgUrl, completed: nil)
        }
        
    }
    
    private func setTapableDescriptionLabel() {
        let locDesc = stkOfCell!.localizedDescription
        let labelRanges = locDesc.allRanges(of: "*")
        let attributed = NSMutableAttributedString.init(string: locDesc)
        for oneRange in labelRanges {
            attributed.addAttribute(.foregroundColor, value: UIColor.systemGreen, range: NSRange(oneRange, in: locDesc))
        }
        descriptionLabel.attributedText = attributed
        
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(self.onTapInfoLabel(gesture:)))
        descriptionLabel.addGestureRecognizer(tapAction)
    }
    
    @objc
    private func onTapInfoLabel(gesture: UITapGestureRecognizer) {
        let labelRanges = stkOfCell!.localizedDescription.allRanges(of: "*")
        for index in 0 ..< labelRanges.count {
            if gesture.didTapAttributedTextInLabel(label: descriptionLabel, inRange: NSRange(labelRanges[index], in: stkOfCell!.localizedDescription)) {
                mainTapDelegate!.showStarAlert(stringToShow: stkOfCell!.localizedStarDescription)
                return
            }
        }
    }
    
    @IBAction func onStudinBtnTap(_ sender: Any) {
        mainTapDelegate.selectRowAt(index: indexOfCell)
    }
    
    @IBAction func onInfoTap(_ sender: Any) {
        mainTapDelegate.showLabelRowAt(index: indexOfCell, labelHeight: descriptionLabel.frame.height + LabelSpace)
    }
    
    @IBAction func onCoursesTap(_ sender: Any) {
        mainTapDelegate.gotToStudienCourses(rowIndex: indexOfCell)
    }
    
}
