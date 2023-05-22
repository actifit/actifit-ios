//
//  DailyLeaderBoardBVC.swift
//  Actifit
//
//  Created by Hitender kumar on 16/08/18.
//  Copyright © 2018 actifit.io. All rights reserved.
//

import UIKit

class DailyLeaderBoardBVC: UIViewController {
    
    @IBOutlet weak var backBtn : UIButton!
    @IBOutlet weak var dailyLeaderboardTableView : UITableView!
    
    var dailyTopActifitters = "Daily Top Actifitters"
    
    lazy var leaderboardArray = {
        return [NSDictionary]()
    }()
    
    //MARK: VIEW LIFE CYCLE
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.backBtn.setImage(#imageLiteral(resourceName: "back_black").withRenderingMode(.alwaysTemplate), for: .normal)
        self.backBtn.tintColor = UIColor.white
        self.dailyLeaderboardTableView.tableFooterView = UIView()
        
        //get all daily leaderboard users list
        self.getDailyLeaderboard()
        setupInitials()
    }
    
    func setupInitials()
    {
        
        dailyTopActifitters    = "activity_leaderboard_title".localized()
        
        
        
    }
    
    //MARK: INTERFACE BUILDER ACTIONS
    
    @IBAction func backBtnAction(_ sender : UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func postDetailsAction(_ sender : UIButton) {
        print(sender.tag)
     let   obj  = self.leaderboardArray[sender.tag]
    let url =  obj["url"] as? String
        let Url = "https://actifit.io" + url!
        if let URL = URL(string: Url) {
            UIApplication.shared.open(URL)
        }
    }
    
    //MARK: WEB SERVICES
    
  /*  func getDailyLeaderboard() {
        ActifitLoader.show(title: Messages.fetching_leaderboard, animated: true)
        APIMaster.getDailyLeaderboard(completion: { [weak self] (jsonString) in
            DispatchQueue.main.async(execute: {
                ActifitLoader.hide()
            })
            var noLeaderboardUsers = true
            if let jsonString = jsonString as? String {
                //set varialbe to false if string is empty/true otherwise
                noLeaderboardUsers = jsonString.isEmpty || (jsonString == "{}")
                //show leaderboard user score
                if noLeaderboardUsers == false {
                    self?.leaderboardArray = jsonString.components(separatedBy: CharacterSet.init(charactersIn: ";"))

                    //remove last element if an empty string
                    if let lastElement = self?.leaderboardArray.last {
                        if lastElement.isEmpty {
                            if let arraySlice = self?.leaderboardArray.dropLast() {
                                self?.leaderboardArray = Array(arraySlice)
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self?.dailyLeaderboardTableView.reloadData()
                    }
                }
            }
          
            
            
            //show no users on leaderboard is api fails
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                if noLeaderboardUsers {
                    self?.showAlertWith(title: nil, message: Messages.leader_no_results)
                }
            })
        }) { (error) in
            DispatchQueue.main.async(execute: {
                ActifitLoader.hide()
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.showAlertWith(title: nil, message: error.localizedDescription)
            })
        }
    } */
    
   func getDailyLeaderboard() {
                 ActifitLoader.show(title: Messages.fetching_leaderboard, animated: true)
                APIMaster.getDailyLeaderboard(completion: { [weak self] (jsonString) in
                    DispatchQueue.main.async(execute: {
                        ActifitLoader.hide()
                    })
                    if let jsonString = jsonString as? String {
                        let data = jsonString.utf8Data()
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                            if let jsonArray = (json as? [NSDictionary]){
                               self?.leaderboardArray  = jsonArray
                            }
                        } catch {
                           
                            print("unable to fetch transactions")
                        }
                        DispatchQueue.main.async(execute: {
                             self?.dailyLeaderboardTableView.reloadData()
                        })
                    }
                }) { (error) in
                    DispatchQueue.main.async(execute: {
                        ActifitLoader.hide()
                    })
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        self.showAlertWith(title: nil, message: error.localizedDescription)
                    })
                }
    }
}

extension DailyLeaderBoardBVC : UITableViewDataSource, UITableViewDelegate {
    
    //MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.leaderboardArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : DailyLeaderboardTableCell = tableView.dequeueReusableCell(withIdentifier: "DailyLeaderboardTableCell", for: indexPath) as! DailyLeaderboardTableCell
        let obj = self.leaderboardArray[indexPath.row]
        let strCount = obj["activityCount"] as? [String] ?? []
        let strciunt2 = strCount[0]
       
        let strName = obj["author"] as? String
        let strRank = obj["leaderRank"] as? Int
        let strImage = obj["userProfilePic"] as? String
        
        URLSession.shared.dataTask( with: NSURL(string:strImage!)! as URL, completionHandler: {
            (data, response, error) -> Void in
            DispatchQueue.main.async {
                if let data = data {
                     cell.leaderboardImage.image = UIImage(data: data)
                }
            }
        }).resume()
        
        cell.leaderboardRank.text = "\(strRank ?? 0)"
        cell.leaderboardName.text = strName
        cell.leaderboardCount.text = strciunt2
        cell.leaderboardImage.layer.cornerRadius = 16
        cell.leaderboardImage.clipsToBounds =  true
        cell.btnDetails.tag = indexPath.row
        
        return cell
    }
    func setImageFromUrl(ImageURL :String) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    //MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dailyTopActifitters
    }
    
    
}

