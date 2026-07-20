//Created on 10/11/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import UIKit
import SDWebImage

protocol MathTestCellProtocol: UITableViewCell {
    func setData(taskModel: OneTaskModel, index: Int, delegate: TestCellDelegate)
}

class MathTestCell: UITableViewCell, MathTestCellProtocol {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var solvedImageView: UIImageView!
    @IBOutlet weak var pageWhiteCircle1: UIView!
    @IBOutlet weak var pageWhiteCircle2: UIView!
    @IBOutlet weak var cellScroll: UIScrollView!
    @IBOutlet weak var taskImage: UIImageView!
    @IBOutlet weak var answerIMage: UIImageView!
    @IBOutlet weak var testNumberLabel: UILabel!
    
    private unowned var testCellDelegate: TestCellDelegate!
    private unowned var taskModel: OneTaskModel!
    private var indexOfCell = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellScroll.delegate = self
    }
    
    func setData(taskModel: OneTaskModel, index: Int, delegate: TestCellDelegate) {
        testCellDelegate = delegate
        self.taskModel = taskModel
        indexOfCell = index
        descriptionLabel.text = nil
        taskImage.image = nil
        answerIMage.image = nil
        cellScroll.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        testNumberLabel.text = "\(taskModel.dbIndex + 1)."
        
        descriptionLabel.text = taskModel.description
        taskImage.sd_setImage(with: URL(string: taskModel.task), completed: nil)
        answerIMage.sd_setImage(with: URL(string: taskModel.answer), completed: nil)
        solvedImageView.isHidden = !taskModel.isSolved
        
        setPageCircleViews()
        setTapGestures()
    }
    
    private func setTapGestures() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.onSingleTap))
        singleTap.numberOfTapsRequired = 1
        contentView.addGestureRecognizer(singleTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.onDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        contentView.addGestureRecognizer(doubleTap)
        
        singleTap.require(toFail: doubleTap)
    }
    
    @objc
    private func onSingleTap() {
        if cellScroll.contentOffset.x == 0 {
            if let img = taskImage.image {
                testCellDelegate.showBigImage(image: img)
            }
        } else {
            if let img = answerIMage.image {
                testCellDelegate.showBigImage(image: img)
            }
        }
    }
    
    @objc
    private func onDoubleTap() {
        taskModel.isSolved = !taskModel.isSolved
        solvedImageView.isHidden = !taskModel.isSolved
        if taskModel.isSolved {
            testCellDelegate.setLastSolved(index: self.taskModel.dbIndex)
        }
    }

}

extension MathTestCell: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setPageCircleViews()
    }
    
    private func setPageCircleViews() {
        pageWhiteCircle1.isHidden = cellScroll.contentOffset.x == 0
        pageWhiteCircle2.isHidden = cellScroll.contentOffset.x != 0
    }
}
