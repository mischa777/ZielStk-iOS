//Created on 10/13/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import UIKit

class BigImageVC: UIViewController {
    
    @IBOutlet weak var scrollForZoom: UIScrollView!
    @IBOutlet weak var imageScrollView: UIImageView!
    @IBOutlet weak var contentView: UIView!
    
    var imageToShow: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollForZoom.delegate = self
        scrollForZoom.minimumZoomScale = 1.0
        scrollForZoom.maximumZoomScale = 7.0
        
        
        if let img = imageToShow {
            imageScrollView.image = img
        }
    }
    
    @IBAction func onBackTap(_ sender: Any) {
        if let nc = navigationController {
            nc.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
}

extension BigImageVC: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
}
