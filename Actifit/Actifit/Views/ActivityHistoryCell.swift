//
//  ActivityHistoryCell.swift
//  Actifit
//
//  Created by Hitender kumar on 09/08/18.
//  Copyright © 2018 actifit.io. All rights reserved.
//

import UIKit

class ActivityHistoryCell: UITableViewCell {

    @IBOutlet weak var dailyStepsLabel : UILabel!
    @IBOutlet weak var viewHistoryDayButton : UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureWith(activity : Activity) {
        self.dailyStepsLabel.text = activity.date.dateString() + " - " + "Total Activity: \(activity.steps)"
    }
    
    
    func formattedDAteStr(date : Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: date)
    }
}
