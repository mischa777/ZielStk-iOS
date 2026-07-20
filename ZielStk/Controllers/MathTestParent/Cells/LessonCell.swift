//Created on 10/11/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import UIKit

protocol LessonCellProtocol: UICollectionViewCell {
    func setCellData(desc: String, youtubeLink: String, delegate: LessonCellDelegate)
}

class LessonCell: UICollectionViewCell, LessonCellProtocol {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private unowned var lessonCellDelegate: LessonCellDelegate!
    private var linkDescription: String = ""
    private var link: String = ""
    
    func setCellData(desc: String, youtubeLink: String, delegate: LessonCellDelegate) {
        linkDescription = desc
        descriptionLabel.text = linkDescription
        self.link = youtubeLink
        lessonCellDelegate = delegate
    }
    
    @IBAction func onCellBtnTap(_ sender: Any) {
        lessonCellDelegate.onLecconCellTap(link: link)
    }
}
