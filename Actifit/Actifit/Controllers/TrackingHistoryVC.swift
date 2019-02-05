//
//  TrackingHistoryVC.swift
//  Actifit
//
//  Created by Hitender kumar on 09/08/18.
//  Copyright © 2018 actifit.io. All rights reserved.
//

import UIKit

class TrackingHistoryVC: UIViewController {

    @IBOutlet weak var trackingHistoryTableView : UITableView!
    @IBOutlet weak var backBtn : UIButton!

    var history = [Activity]()
    
    //MARK: VIEW LIFE CYCLE
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.history = Activity.allWithoutCountZero()
        
        self.trackingHistoryTableView.tableFooterView = UIView()

        self.backBtn.setImage(#imageLiteral(resourceName: "back_black").withRenderingMode(.alwaysTemplate), for: .normal)
        self.backBtn.tintColor = UIColor.white
    }
    
    //MARK: INTERFACE BUILDER ACTIONS
    @IBAction func chartBtnAction(_ sender: Any) {
        let historyChartVC : HistoryChartVC = HistoryChartVC.instantiateWithStoryboard(appStoryboard: .SB_Main) as! HistoryChartVC
        historyChartVC.history = history
        self.navigationController?.pushViewController(historyChartVC, animated: true)
    }
    
    @IBAction func backBtnAction(_ sender : UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension TrackingHistoryVC : UITableViewDataSource, UITableViewDelegate {
    
    //MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : ActivityHistoryCell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! ActivityHistoryCell
        cell.configureWith(activity: self.history[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    //MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Activity History"
    }
}
