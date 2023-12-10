//
//  ActivityDateCell.swift
//  Actifit
//
//  Created by Ali Jaber on 20/10/2023.
//

import UIKit

class ActivityDateCell: UITableViewCell {
    @IBOutlet weak var numberView: UIView!
    
    @IBOutlet weak var activityDateTitleLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    @IBOutlet weak var todayView: UIView!
    
    @IBOutlet weak var yesterdayBtn: UIButton!
    @IBOutlet weak var todayBtn: UIButton!
    @IBOutlet weak var yesterdayView: UIView!
    var onTodayTapped:(() -> ())?
    var onYesterdayTapped:(() -> ())?
    override func awakeFromNib() {
        super.awakeFromNib()
        numberView.layer.cornerRadius = numberView.frame.width / 2
        numberView.layer.borderWidth = 3
        numberView.layer.borderColor = UIColor.primaryGreenColor().cgColor
        
        todayView.layer.cornerRadius = todayView.frame.width / 2
        todayView.layer.borderColor = UIColor.gray.cgColor
        todayView.clipsToBounds = true
        todayView.layer.borderWidth = 2.5
        
        yesterdayView.layer.borderWidth = 2.5
        yesterdayView.layer.borderColor = UIColor.gray.cgColor
        yesterdayView.layer.cornerRadius = yesterdayView.frame.width / 2
        yesterdayView.clipsToBounds = true
        
        todayBtn.layer.cornerRadius = todayBtn.frame.width / 2
        yesterdayBtn.layer.cornerRadius = yesterdayBtn.frame.width / 2
        todayBtn.clipsToBounds = true
        yesterdayBtn.clipsToBounds = true
        todayBtn.backgroundColor = .primaryRedColor()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func todayTapped(_ sender: Any) {
        onTodayTapped?()
        todayBtn.backgroundColor = .primaryRedColor()
        todayView.layer.borderColor = UIColor.primaryRedColor().cgColor
        yesterdayView.layer.borderColor = UIColor.gray.cgColor
        yesterdayBtn.backgroundColor = .white
    }
    
    @IBAction func yesterdayTapped(_ sender: Any) {
        onYesterdayTapped?()
        yesterdayBtn.backgroundColor = .primaryRedColor()
        todayBtn.backgroundColor = .white
        todayView.layer.borderColor = UIColor.gray.cgColor
        yesterdayView.layer.borderColor = UIColor.primaryRedColor().cgColor
    }
    
}
