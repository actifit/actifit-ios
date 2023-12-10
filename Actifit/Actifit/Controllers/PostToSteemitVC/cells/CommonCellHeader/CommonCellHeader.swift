//
//  CommonCellHeader.swift
//  Actifit
//
//  Created by Ali Jaber on 20/10/2023.
//

import Foundation
import UIKit
class CustomItemView: UIView {
    private let subview = UIView()
    private let label1 = UILabel()
    private let label2 = UILabel()

    init(frame: CGRect, labelText1: String, labelText2: String) {
        super.init(frame: frame)
      //  setupUI()
        label1.text = labelText1
        label2.text = labelText2
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }

    private func setupSubviews() {
        self.backgroundColor = .red
        subview.backgroundColor = .white
        subview.translatesAutoresizingMaskIntoConstraints = false
      
        addSubview(subview)

        label1.translatesAutoresizingMaskIntoConstraints = false
        label1.textColor = .primaryGreenColor()
        label1.text = "Label 1"
        subview.addSubview(label1)

        label2.translatesAutoresizingMaskIntoConstraints = false
        label2.text = "Label 2"
        label2.textColor = .black
        addSubview(label2)

        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: topAnchor),
            subview.leadingAnchor.constraint(equalTo: leadingAnchor),
            subview.widthAnchor.constraint(equalToConstant: 50),
            subview.heightAnchor.constraint(equalTo: subview.widthAnchor),

            label1.centerXAnchor.constraint(equalTo: subview.centerXAnchor),
            label1.centerYAnchor.constraint(equalTo: subview.centerYAnchor),

            label2.topAnchor.constraint(equalTo: subview.bottomAnchor, constant: 8),
            label2.centerXAnchor.constraint(equalTo: centerXAnchor),

            heightAnchor.constraint(equalToConstant: 60)
        ])
        
        subview.layer.cornerRadius = subview.frame.width / 2
        subview.clipsToBounds = true
        subview.layer.borderWidth = 2
        subview.layer.borderColor = UIColor.primaryGreenColor().cgColor
    }

    func setLabel1Text(_ text: String) {
        label1.text = text
    }

    func setLabel2Text(_ text: String) {
        label2.text = text
    }
}
