//
//  ActivityTypesView.swift
//  Actifit
//
//  Created by Hitender kumar on 15/08/18.
//  Copyright © 2018 actifit.io. All rights reserved.
//

import UIKit

class ActivityTypesView: UIView {

    @IBOutlet weak var activitiesTableView : UITableView!
    @IBOutlet weak var doneBtn : UIButton!

    var activityTypesOrCharities = ["Aerobics", "BasketBall","Badminton", "Boxing", "Bootcamp", "Chasing Pokemons", "Cricket", "Cycling", "Daily Activity", "Dancing", "Elliptical", "Football", "Gardening", "Geocaching", "Golf", "Gym", "Hiking", "Hockey", "House Chores", "Jogging", "Kettlebell Training", "Martial Arts", "Moving Around Office", "Photowalking","Pickle Ball", "Rollerblading", "Rope Skipping", "Running", "Scootering", "Shopping", "Shoveling", "Skating", "Skiing", "Stair Mill", "Swimming", "Table Tennis", "Tennis", "Treadmill", "Volleyball", "Walking", "Weight Lifting"]
    
    var selectedActivities = [String]()
    var isForCharity = false
    
    var SelectedActivityTypesCompletion : ((_ selectedActivityTypes : [String]) -> ())?

    override func awakeFromNib() {
        super.awakeFromNib()
        activitiesTableView.layer.cornerRadius = 4.0
        self.doneBtn.layer.cornerRadius = 4.0
        self.activitiesTableView.register(UINib.init(nibName: "ActivityTypeTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "ActivityTypeTableViewCell")
    }
    
    //MARK : INTERFACE BUILDER ACTIONS
    
    @IBAction func doneBtnAction(_ sender : UIButton) {
        if let selectedActivityTypesCompletion = SelectedActivityTypesCompletion {
            selectedActivityTypesCompletion(self.selectedActivities)
        }
    }
}

extension ActivityTypesView : UITableViewDelegate, UITableViewDataSource {
    
    //MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activityTypesOrCharities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : ActivityTypeTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ActivityTypeTableViewCell", for: indexPath) as! ActivityTypeTableViewCell
        cell.selectionStyle = .none
        let activityType = self.activityTypesOrCharities[indexPath.row]
        cell.activityTypeLabel.text = activityType
       
        let contains = self.selectedActivities.contains(activityType)
        cell.selectedActivityImageview.backgroundColor = contains ? ColorTheme : UIColor.clear
       // cell.selectedActivityImageview.isHidden = !contains
        cell.selectedActivityImageview.layer.cornerRadius = 2.0

         cell.selectedActivityImageview.layer.borderWidth = contains ? 0.0 : 1.0
        
        cell.selectedActivityImageview.layer.borderColor = contains ? UIColor.clear.cgColor : UIColor.lightGray.cgColor
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = self.activityTypesOrCharities[indexPath.row]
        if self.isForCharity {
            self.selectedActivities.removeAll()
            self.selectedActivities.append(type)
        } else {
            if !self.selectedActivities.contains(type) {
                self.selectedActivities.append(self.activityTypesOrCharities[indexPath.row])
            } else {
                self.selectedActivities = self.selectedActivities.filter({$0 != type})
            }
        }
       
        self.activitiesTableView.reloadData()
    }
    
    //MARK: UITableViewDelegate

    
}
