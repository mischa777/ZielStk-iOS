// Created by Roman Voinitchi on 10/20/20
// Copyright © 2020 Roman Voinitchi. All rights reserved.


import UIKit

class TextSelectorVC: UIViewController, AlertOpennerProtocol, PreloaderOpennerProtocol {
    
    private let OneCellHeight: CGFloat = 50
    
    @IBOutlet weak var cancelBtn: RoundedButton!
    @IBOutlet weak var okBtn: RoundedButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textsPickerView: UIPickerView!
    
    private var viewModel: TextSelectorVMProtocol! {
        didSet {
            self.viewModel.onTextsLoaded = { [weak self] in
                self?.hidePreloader()
                self?.textsPickerView.reloadAllComponents()
            }
            self.viewModel.onLoadError = { [weak self] in
                self?.hidePreloader()
                self?.setLoadTextsError()
            }
        }
    }
    
    unowned var moduleDelegate: TextSelectorModuleDelegate!

    override func viewDidLoad() {
        viewModel = TextSelectorVM()
        super.viewDidLoad()
        
        setTranslations()
        
        self.showPreloader()
        viewModel.loadTexts()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textsPickerView.subviews.forEach { subview in
            if subview.frame.height < 60 {
                subview.isHidden = true
            }
        }
    }
    
    @IBAction func onOkTap(_ sender: Any) {
        let text = viewModel.currentTexts[textsPickerView.selectedRow(inComponent: 1)].text.replacingOccurrences(of: "\\n", with: "\n")
        moduleDelegate.setNewText(text: text)
        onCancelTap(cancelBtn as Any)
    }
    
    @IBAction func onCancelTap(_ sender: Any) {
        if let nc = navigationController {
            nc.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
}

private extension TextSelectorVC {
    func setTranslations() {
        okBtn.setTitle(NSLocalizedString("OkBtnText", comment: "").uppercased(), for: .normal)
        cancelBtn.setTitle(NSLocalizedString("CancelBtnText", comment: "").uppercased(), for: .normal)
        titleLabel.text = NSLocalizedString("SelectTextsTitle", comment: "")
    }
    
    func setLoadTextsError() {
        let title = NSLocalizedString("ErrorTitle", comment: "")
        let message = NSLocalizedString("CantLoadTextsError", comment: "  ")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("OkBtnText", comment: ""), style: .default) { [weak self] action in
            guard let self = self else { return }
            self.onCancelTap(self.cancelBtn as Any)
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}

extension TextSelectorVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return viewModel.textLevels.count
        }
        return viewModel.currentTexts.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return OneCellHeight
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        let pickerWidth = pickerView.bounds.width
        let letterWidth = pickerWidth / 4
        if component == 0 {
            return letterWidth
        }
        return pickerWidth - letterWidth
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return viewModel.textLevels[row]
        }
        return viewModel.currentTexts[row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            viewModel.switchToKey(newKeyIndex: row)
            pickerView.reloadComponent(1)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if component == 0 {
            return getIndexView(indexText: viewModel.textLevels[row])
        }
        return getTitleView(titleText: viewModel.currentTexts[row].title)
    }
    
    private func getIndexView(indexText: String) -> UIView {
        let viewWidth = textsPickerView.bounds.width / 4
        let cellView = UIView(frame: CGRect(x: 0, y: 0, width: viewWidth, height: OneCellHeight))
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: viewWidth, height: OneCellHeight))
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.text = indexText
        cellView.addSubview(label)
        
        return cellView
    }
    
    private func getTitleView(titleText: String) -> UIView {
        let viewWidth = textsPickerView.bounds.width - (textsPickerView.bounds.width / 4)
        let cellView = UIView(frame: CGRect(x: 0, y: 0, width: viewWidth, height: OneCellHeight))
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: viewWidth, height: OneCellHeight))
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17)
        label.text = titleText
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.minimumScaleFactor = 0.5
        cellView.addSubview(label)
        
        return cellView
    }
}
