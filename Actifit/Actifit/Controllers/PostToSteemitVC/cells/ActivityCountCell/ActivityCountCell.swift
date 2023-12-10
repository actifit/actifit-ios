//
//  ActivityCountCell.swift
//  Actifit
//
//  Created by Ali Jaber on 20/10/2023.
//

import UIKit

class ActivityCountCell: UITableViewCell {
    @IBOutlet weak var topView: UIView!
    var numberOfSteps: Int? {
        didSet {
            updateLabelAndColors()
        }
    }
    @IBOutlet weak var numberView: UIView!
    @IBOutlet weak var activityCountLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var fitBitSyncBtn: UIButton!
    @IBOutlet weak var countLabel: UILabel!
    var onFitbitTapped:(() -> ())?
    override func awakeFromNib() {
        super.awakeFromNib()
        numberView.layer.cornerRadius = numberView.frame.width / 2
        numberView.layer.borderWidth = 3
        numberView.layer.borderColor = UIColor.primaryGreenColor().cgColor
        fitBitSyncBtn.layer.cornerRadius = 5
        fitBitSyncBtn.clipsToBounds = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func fitbitBtnTapped(_ sender: Any) {
        onFitbitTapped?()
        
    }
    
    private func updateLabelAndColors() {
        guard let steps = numberOfSteps else { return }
        countLabel.text = "\(steps)"
        if steps < 500 {
            numberView.layer.borderColor = UIColor.primaryRedColor().cgColor
            numberLabel.textColor = .primaryRedColor()
        } else {
            numberView.layer.borderColor = UIColor.primaryGreenColor().cgColor
            numberLabel.textColor = .primaryGreenColor()
        }
    }
    
}
