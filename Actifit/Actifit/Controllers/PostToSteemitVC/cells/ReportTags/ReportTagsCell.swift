//
//  ReportTagsCell.swift
//  Actifit
//
//  Created by Ali Jaber on 20/10/2023.
//

import UIKit

protocol ReportTagCellDelegate: AnyObject {
    func tagsChanged(_ text: String?, in cell: ReportTagsCell)
}


class ReportTagsCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var numberView: UIView!
    
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var tagsTextfield: UITextField!
    @IBOutlet weak var reportTagLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    weak var tagsChangedDelegate: ReportTagCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        tagsTextfield.delegate = self
        numberView.layer.cornerRadius = numberView.frame.width / 2
        numberView.layer.borderWidth = 3
        numberView.layer.borderColor = tagsTextfield.text == "" ? UIColor.primaryRedColor().cgColor :  UIColor.primaryGreenColor().cgColor
        underlineView.backgroundColor = .black
        
        numberLabel.textColor = tagsTextfield.text == "" ? UIColor.primaryRedColor() :  UIColor.primaryGreenColor()
        tagsTextfield.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        // Initialization code
    }
    
    @objc func textFieldDidChange() {
        if tagsTextfield.text == "" {
           
            numberView.layer.borderColor = UIColor.primaryRedColor().cgColor
            numberLabel.textColor = UIColor.primaryRedColor()
        } else {
            underlineView.backgroundColor = .primaryRedColor()
            numberView.layer.borderColor = UIColor.primaryGreenColor().cgColor
            numberLabel.textColor = UIColor.primaryGreenColor()
        }
        tagsChangedDelegate?.tagsChanged(tagsTextfield.text, in: self)
      }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        underlineView.backgroundColor = .red
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        underlineView.backgroundColor = .black
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
