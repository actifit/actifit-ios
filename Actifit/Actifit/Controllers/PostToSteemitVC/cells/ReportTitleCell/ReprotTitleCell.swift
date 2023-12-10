//
//  ReprotTitleCell.swift
//  Actifit
//
//  Created by Ali Jaber on 17/10/2023.
//

import UIKit

protocol TitleChangeCellDelegate: AnyObject {
    func titleTextFieldDidChange(_ text: String?, in cell: ReprotTitleCell)
}

class ReprotTitleCell: UITableViewCell, UITextViewDelegate {
    weak var delegate: TitleChangeCellDelegate?
    var reportTitle: String? {
        didSet {
            updateUI(title: reportTitle ?? "")
        }
    }
    
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var numberView: UIView!
    @IBOutlet weak var titleTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleTextView: AFTextView!
    @IBOutlet weak var reportTitleLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        numberView.layer.cornerRadius = numberView.frame.width / 2
        numberView.layer.borderWidth = 3
        numberView.layer.borderColor = UIColor.primaryGreenColor().cgColor
        titleTextView.delegate = self
    
        // Initialization code
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == "" {
            numberView.layer.borderColor = UIColor.primaryRedColor().cgColor
            numberLabel.textColor = .primaryRedColor()
        } else {
            numberView.layer.borderColor = UIColor.primaryGreenColor().cgColor
            numberLabel.textColor = .primaryGreenColor()
        }
        delegate?.titleTextFieldDidChange(textView.text, in: self)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        underlineView.backgroundColor = .primaryRedColor()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        underlineView.backgroundColor = .black
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func updateUI(title: String) {
        titleTextView.text = title
    }
    
    
    
}
