//Created on 10/1/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import UIKit
import SDWebImage

protocol CourseSelectionTitleViewProtocol {
    var mainView: UIView { get }
    
    func setStartData(section: Int, title: String, logoUrl: String, totalCoursesCount: Int, selectedCoursesCount: Int, delegate: StkHeaderExpandDelegate)
}

class CourseSelectionTitleView: UIView, CourseSelectionTitleViewProtocol {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectedLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!

    var mainView: UIView {
        return self
    }
    
    private unowned var delegate: StkHeaderExpandDelegate!
    private var sectionNumber = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("CourseSelectionTitleView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func setStartData(section: Int, title: String, logoUrl: String, totalCoursesCount: Int, selectedCoursesCount: Int, delegate: StkHeaderExpandDelegate) {
        logoImageView.image = nil
        self.delegate = delegate
        sectionNumber = section
        titleLabel.text = title
        logoImageView.sd_setImage(with: URL(string: logoUrl)!, completed: nil)
        selectedLabel.text = "\(selectedCoursesCount) / \(totalCoursesCount)"
    }
    
    @IBAction func onBtnTap(_ sender: Any) {
        delegate.expandSection(section: sectionNumber)
    }
}
