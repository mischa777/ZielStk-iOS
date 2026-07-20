//Created on 9/23/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import UIKit

protocol ShopHeaderViewProtocol {
    var mainView: UIView { get }
    
    func setHeaderData(nameOfCollege: String, sectionNumber: Int, delegate: HeaderExpandDelegate)
    func setInactiveHeaderData(nameOfCollege: String, sectionNumber: Int)
}

class ShopHeaderView: UIView, ShopHeaderViewProtocol {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mainBtn: UIButton!
    
    var mainView: UIView {
        get {
            return self
        }
    }
    
    private unowned var expandHeaderDelegate: HeaderExpandDelegate!
    private var expanded = false
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
        Bundle.main.loadNibNamed("ShopHeaderView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func setHeaderData(nameOfCollege: String, sectionNumber: Int, delegate: HeaderExpandDelegate) {
        nameLabel.text = nameOfCollege
        self.sectionNumber = sectionNumber
        expandHeaderDelegate = delegate
    }
    
    func setInactiveHeaderData(nameOfCollege: String, sectionNumber: Int) {
        nameLabel.text = nameOfCollege
        self.sectionNumber = sectionNumber
        arrowImage.isHidden = true
        mainBtn.isEnabled = false
        mainBtn.isHidden = true
    }
    
    @IBAction func onCommonBtnTap(_ sender: Any) {
        UIView.animate(withDuration: Constants.Timers.CommonAnimationSeconds, animations: {
            self.arrowImage.transform = CGAffineTransform(rotationAngle: self.expanded ? 0 : CGFloat.pi)
        })
        expanded = !expanded
        expandHeaderDelegate.expandSection(section: sectionNumber)
    }
    
}
