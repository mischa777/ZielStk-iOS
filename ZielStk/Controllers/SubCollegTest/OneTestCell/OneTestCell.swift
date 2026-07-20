//
//  OneTestCell.swift
//  ZielStk
//
//  Created by Roman Voinitchi on 9/17/19.
//  Copyright © 2019 Roman Voinitchi. All rights reserved.
//

import UIKit

protocol OneTestCellProtocol: UITableViewCell {
    func setCellData(cellIndex: Int, nameOfTest: String, needImage: Bool, tasksCount: Int?, selectDelegate: SelectTestCellDelegateProtocol)
}

class OneTestCell: UITableViewCell, OneTestCellProtocol {
    
    private let CounterRadius: CGFloat = 24
    
    @IBOutlet weak var mainBtn: RoundedButton!
    @IBOutlet weak var testNameLabel: UILabel!
    @IBOutlet weak var imageOfTest: UIImageView!
    
    private unowned var selectCellDelegate: SelectTestCellDelegateProtocol!
    private var indexOfCell = 0
    
    func setCellData(cellIndex: Int, nameOfTest: String, needImage: Bool, tasksCount: Int?, selectDelegate: SelectTestCellDelegateProtocol) {
        indexOfCell = cellIndex
        testNameLabel.text = nameOfTest
        selectCellDelegate = selectDelegate
        imageOfTest.isHidden = !needImage
        if let tasksCount = tasksCount {
            setCountView(tasksCount: tasksCount)
        }
    }
    
    private func setCountView(tasksCount: Int) {
        let countView = UIView()
        countView.backgroundColor = UIColor.lightGray
        countView.layer.masksToBounds = true
        countView.layer.cornerRadius = CounterRadius / 2
        self.addSubview(countView)
        
        countView.translatesAutoresizingMaskIntoConstraints = false
        countView.widthAnchor.constraint(equalToConstant: CounterRadius).isActive = true
        countView.heightAnchor.constraint(equalToConstant: CounterRadius).isActive = true
        countView.topAnchor.constraint(equalTo: mainBtn.topAnchor, constant: 5).isActive = true
        countView.trailingAnchor.constraint(equalTo: mainBtn.trailingAnchor, constant: -5).isActive = true
        
        let countLabel = UILabel()
        countLabel.textColor = .white
        countLabel.font = UIFont.systemFont(ofSize: 10)
        countLabel.text = "\(tasksCount)"
        countLabel.textAlignment = .center
        countView.addSubview(countLabel)
        
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.topAnchor.constraint(equalTo: countView.topAnchor).isActive = true
        countLabel.bottomAnchor.constraint(equalTo: countView.bottomAnchor).isActive = true
        countLabel.leadingAnchor.constraint(equalTo: countView.leadingAnchor).isActive = true
        countLabel.trailingAnchor.constraint(equalTo: countView.trailingAnchor).isActive = true
    }
    
    @IBAction func onSelectTestTap(_ sender: Any) {
        selectCellDelegate.selectTestAt(index: indexOfCell)
    }

}
