//
//  ActivityTypesCell.swift
//  Actifit
//
//  Created by Ali Jaber on 20/10/2023.
//

import UIKit

class ActivityTypesCell: UITableViewCell {
    @IBOutlet weak var activitiesLabel: UILabel!
    @IBOutlet weak var numberView: UIView!
    var activityTypeSelected:(() -> ())?
    @IBOutlet weak var activityTypeSected: UILabel!
    var changeColorDetector: Bool? {
        didSet {
            changeColor()
        }
    }
    
    var activitiesSelected: String? {
        didSet {
            updateActivities()
        }
    }
    
    @IBOutlet weak var numberLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        numberView.layer.cornerRadius = numberView.frame.width / 2
        numberView.layer.borderWidth = 3
        numberView.layer.borderColor = UIColor.primaryGreenColor().cgColor
        // Initialization code
    }
    
    private func changeColor() {
        guard let changeColor = changeColorDetector else { return }
        if changeColor {
            numberView.layer.borderColor = UIColor.primaryRedColor().cgColor
            numberLabel.textColor = .primaryRedColor()
        } else {
            numberView.layer.borderColor = UIColor.primaryGreenColor().cgColor
            numberLabel.textColor = .primaryGreenColor()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func dropDownBtnTapped(_ sender: Any) {
        activityTypeSelected?()
    }
    
    private func updateActivities() {
        guard let activities = activitiesSelected else { return }
        activitiesLabel.text = activities
    }
    
    
}
