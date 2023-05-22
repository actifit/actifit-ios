//
//  ActivityTrackingVC.swift
//  Actifit
//
//  Created by Hitender kumar on 03/08/18.
//  Copyright © 2018 actifit.io. All rights reserved.
//

import UIKit
import CoreMotion
import EFCountingLabel
import AVFoundation
import Charts
//import FirebaseCrashlytics
import RealmSwift
import UserNotifications


let StepsUpdatedNotification = "StepsUpdatedNotification"

class ActivityTrackingVC: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate,ChartViewDelegate {
    
    //MARK: OUTLETS
    
    let notifications = ["Local Notification",
                         "Local Notification with Action",
                         "Local Notification with Content",
                         "Push Notification with  APNs",
                         "Push Notification with Firebase",
                         "Push Notification with Content"]
    
    var appDelegate = UIApplication.shared.delegate as? AFAppDelegate
    
    
    @IBOutlet weak var stepsCountLabel : EFCountingLabel!
    @IBOutlet weak var postToSteemitBtn : UIButton!
    @IBOutlet weak var snapBtn : UIButton!
    @IBOutlet weak var viewTrackingHistoryBtn : UIButton!
    @IBOutlet weak var viewDailyLeaderboardBtn : UIButton!
    @IBOutlet weak var viewWalletBtn : UIButton!
    @IBOutlet weak var settingsBtn : UIButton!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var rank: UILabel!
    @IBOutlet weak var todayDate: UILabel!
    @IBOutlet weak var piechartView: PieChartView!
    @IBOutlet weak var dailybarChart: BarChartView!
    @IBOutlet weak var datebarChart: BarChartView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBAction func profileBtnAction(_ sender: Any) {

        if let username: String = UserDefaults.standard.value(forKey: "username") as? String, username != ""
        {
            guard let url = URL(string: "https://actifit.io/" + username) else { return }
            UIApplication.shared.open(url)
        }

       
    }
    
    @IBAction func rankBtnAction(_ sender: Any) {
        if rank.text ?? "" != ""{
            guard let url = URL(string: "https://actifit.io/userrank") else { return }
            UIApplication.shared.open(url)
        }
    }
    
    
    //MARK: INSTANCE VARIABLES
    
    let activityManager = CMMotionActivityManager()
    private let pedometer = CMPedometer()
    
    var startDate = Date()
    var timer : Timer?
    var timerAfterFifteen : Timer?
    let album = ActifitAlbum()
    
    //MARK: View Life Cycle
    //History of every day
    var history = [Activity]()
    var historyFifteenMinute = [ActivityFifteenMinutesInterval]()
    
    var stepsArray = [Double]()
    var timeIntervel = [String]()
    var timeArray: [String] = []
    var labels = [String]()
    var dailyLabels = [String]()
    var unitsSold = [Double]()
    var entries = [BarChartDataEntry]()
    var entriesFifteenMinuteIntervel = [BarChartDataEntry]()
    var TimeSlot = [String]()
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // [[Crashlytics, sharedInstance], crash];
      
      //  tempTime()
        
        self.historyFifteenMinute = ActivityFifteenMinutesInterval.all()
        print("History Count" + "\(historyFifteenMinute.count)")
        self.history = Activity.allWithoutCountZero()
        print("History Count" + "\(history.count)")
        stepsCountLabel.format = "%d"
        self.postToSteemitBtn.layer.cornerRadius = 4.0
        self.viewTrackingHistoryBtn.layer.cornerRadius = 4.0
        self.viewDailyLeaderboardBtn.layer.cornerRadius = 4.0
        self.viewWalletBtn.layer.cornerRadius = 4.0
        self.settingsBtn.layer.cornerRadius = 4.0
        self.snapBtn.layer.cornerRadius = 4.0
       
        
        self.userImage.layer.cornerRadius = 16
        self.userImage.clipsToBounds = true
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        checkActifitUserID()
        
        barEntry()
        UserImage()
        //self.checkPermissionForlocalNotification()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //setupInitials()
    }
    
    func setBtnFontSize(button: UIButton) -> UIButton{
        button.titleLabel?.minimumScaleFactor = 0.5
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        return button
    }
    
    func setupInitials()
    {
        self.postToSteemitBtn = setBtnFontSize(button: self.postToSteemitBtn)
        self.snapBtn = setBtnFontSize(button: self.snapBtn)
        self.viewTrackingHistoryBtn = setBtnFontSize(button: self.viewTrackingHistoryBtn)
        self.viewDailyLeaderboardBtn = setBtnFontSize(button: self.viewDailyLeaderboardBtn)
        self.viewWalletBtn = setBtnFontSize(button: self.viewWalletBtn)
        self.settingsBtn = setBtnFontSize(button: self.settingsBtn)
       // todayDate.text                          = "activity_source_lbl".localized()
//        stepsCountLabel.text                          = "fitbit_tracking_mode_active".localized()
        
        self.postToSteemitBtn.setTitle("post_to_steem_btn_txt".localized(), for: .normal)
        self.snapBtn.setTitle("snap_picture_btn_txt".localized(), for: .normal)
        self.viewTrackingHistoryBtn.setTitle("view_history_btn_txt".localized(), for: .normal)
        self.viewDailyLeaderboardBtn.setTitle("daily_leaderboard_btn_txt".localized(), for: .normal)
        self.viewWalletBtn.setTitle("view_wallet_btn_txt".localized(), for: .normal)
        self.settingsBtn.setTitle("settings_btn_txt".localized(), for: .normal)
    }
    
//    func checkPermissionForlocalNotification()
//       {
//           UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) {
//               (granted, error) in
//               if granted {
//                   print("yes")
//               } else {
//                   print("No")
//               }
//           }
//       }
//
//    func sendNotification(steps: Int)
//    {
//        let content = UNMutableNotificationContent()
//        content.title = "Actifit"
//        content.subtitle = "Reward"
//        content.body = "You have reached on \(steps) count Activity."
//        content.sound = UNNotificationSound.default()
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)
//        let request = UNNotificationRequest(identifier: "userReachedOnActivityLimit", content: content, trigger: trigger)
//        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
//
//    }
//
    
    
    func UserImage() {
        var  strImageUrl  = ""
        if let strUserName =  UserDefaults.standard.string(forKey: "username"), strUserName != "" {
          //  usernameLabel.isHidden = false
          //  usernameLabel.text = strUserName
            strImageUrl = "https://steemitimages.com/u/" + strUserName + "/avatar"
            guard let imageFinalURL = URL(string: strImageUrl) else { return }
            URLSession.shared.dataTask( with: imageFinalURL, completionHandler: {
                (data, response, error) -> Void in
                DispatchQueue.main.async {
                    if let data = data {
                        self.userImage.isHidden = false
                        self.userImage.image = UIImage(data: data)
                    }
                    else{
                        self.userImage.isHidden = true
                    }
                }
            }).resume()
            
        }else{
            usernameLabel.isHidden = true
            
        }
    }
    
    
    func dataTimeFormat()  {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd"
    }
    
    
    func pieChart(stepsCount:Int)  {
        
       var  unitsSold = [Double]()
        var  months = [String]()
        let textColor = #colorLiteral(red: 1, green: 0.2509803922, blue: 0.5058823529, alpha: 1)
        let dayString = String(describing: stepsCount)
        let centerText = NSAttributedString(string: dayString , attributes: [
            NSAttributedStringKey.foregroundColor:textColor,NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14)])
        piechartView.centerAttributedText = centerText
        piechartView.centerTextRadiusPercent = 1.0
        unitsSold.append(Double(stepsCount))
        months.append("a")
        if (Double(stepsCount) < 5000.0) {
             unitsSold.append(Double(5000.0 - Double(stepsCount)))
             unitsSold.append(Double(5000.0))
             months.append("a")
             months.append("a")
        } else if (Double(stepsCount) < 10000.0) {
            unitsSold.append(Double(10000.0 - Double(stepsCount)))
             months.append("a")
        }
        
       // let months = ["Jan", "Feb", "Mar"]
      
        setChart(dataPoints: months, values: unitsSold)
        piechartView.chartDescription.text = ""
        
        piechartView.drawEntryLabelsEnabled = false
        piechartView.legend.formToTextSpace = 20
        piechartView.legend.enabled = false
        piechartView.holeRadiusPercent = 0.5
        piechartView.transparentCircleColor = UIColor.clear
        piechartView.drawSlicesUnderHoleEnabled = true
        
       
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            print("Count" + "\(i)")
//            print(values[i])
//            let dataEntry = ChartDataEntry(x: Double(i), y: Double(values[i]))
//            dataEntries.append(dataEntry)
            
            let dataEntry = ChartDataEntry(x: Double(i), y:Double(values[i]))
            dataEntries.append(dataEntry)
            
        }
        
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: "Units Sold")
    
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        piechartView.data = pieChartData
        pieChartDataSet.drawValuesEnabled = false
        pieChartDataSet.sliceSpace =  1.0
        pieChartDataSet.highlightEnabled = true
       
        
        var colors: [UIColor] = []
      
            let color1 = #colorLiteral(red: 1, green: 0.1857388616, blue: 0.5733950138, alpha: 1)
            let color2 = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
            colors.append(color1)
            colors.append(color2)
            colors.append(color2)
        pieChartDataSet.colors = colors
    }
    
 

    func displayUserAndRank(){
        let today = Date().dateString()
        todayDate.text = today
        let lastRankRequest = UserDefaults.standard.string(forKey: "rankLastRequest")?.date()
        var fetchNewRankVal = false
        if lastRankRequest == nil || UserDefaults.standard.string(forKey: "rank") == nil{
            fetchNewRankVal = true
        }else if today.date()! > lastRankRequest! {
            fetchNewRankVal = true
        }
        if fetchNewRankVal == false{
            self.rank.text = UserDefaults.standard.string(forKey: "rank")
            self.username.text = UserDefaults.standard.string(forKey: "username")
            
            return
        }
        if let currentUser =  User.current() {
            if currentUser.steemit_username == "" {
                return
            }
            UserDefaults.standard.set(today, forKey: "rankLastRequest")
            APIMaster.getRank(username: currentUser.steemit_username,completion: { (response) in
                if let response = response as? String {
                    let data = response.utf8Data()
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        if let jsonInfo = (json as? NSDictionary){
                            if let rank =  jsonInfo["user_rank"] {
                                DispatchQueue.main.async(execute: {
                                   // let totalRanks = "/100";
                                    self.rank.text = "\(rank)"
                                    self.username.text = "@\(currentUser.steemit_username)"
                                    UserDefaults.standard.set(self.rank.text, forKey: "rank")
                                    UserDefaults.standard.set(self.username.text, forKey: "username")
                               })
                            }
                        }
                    } catch {
                        print("unable to fetch tokens")
                    }
                }
            }, failure: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.checkAuthorizationStatusAndStartTracking()
        displayUserAndRank()
        everyDayChart()
        UserImage()
       // TimeInterval()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      // self.showStepsEveryFifttenMinutes()
            self.setupInitials()
        }
    }
    
    func everyDayChart()  {
        self.entries.removeAll()
        self.labels.removeAll()
        var i:Int = history.count - 1
        var j:Int = historyFifteenMinute.count
        for item in historyFifteenMinute {
            print( "step" + "\(item.steps)")
           // print( "" + "\(item.id)")
        }
        for tempData in history{
            
            
            
//            var currentDate = Date()
//            let timezoneOffset =  TimeZone.current.secondsFromGMT()
//
//            let dateFormatter = DateFormatter()
//            dateFormatter.timeZone = NSTimeZone.local
//            dateFormatter.dateFormat = "yyyy-MM-dd"
            var tempLabel = ""
//            let newDatee = tempData.date.addingTimeInterval(Double(-timezoneOffset))
//            tempLabel = dateFormatter.string(from: newDatee)
          
            tempLabel = tempData.date.dateString()
            
//            if tempData == history.first{
//                 tempLabel = dateFormatter.string(from: tempData.date.yesterday)
//            }else{
//                 tempLabel = dateFormatter.string(from: tempData.date)
//            }
            
            
            
            if labels.contains(tempLabel){
                print("already exist")
            }
            labels.append(tempLabel)
            
            entries.append(BarChartDataEntry(x: Double(i), y: Double(tempData.steps)))
            i -= 1
        }
        labels.reverse()
        entries.reverse()
        print(labels)
        print(entries)
        let xAxis = datebarChart.xAxis
        xAxis.labelPosition = .top
        xAxis.labelFont = .systemFont(ofSize: 8)
        xAxis.granularity = 1
        xAxis.labelCount = 7
        xAxis.valueFormatter = DayAxisValueFormatter(chart: datebarChart, labels: labels) as! AxisValueFormatter
        

        
        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.minimumFractionDigits = 0
        leftAxisFormatter.maximumFractionDigits = 1
        leftAxisFormatter.negativeSuffix = ""
        leftAxisFormatter.positiveSuffix = ""
        
        
        let line = ChartLimitLine(limit: 5000, label: "Min Reward - 5K Activity")
        line.lineColor = .red
        line.valueTextColor = .black
        line.valueFont = .systemFont(ofSize: 10)
        line.lineWidth = 1
       
        let line2 = ChartLimitLine(limit: 10000, label: "Min Reward - 10K Activity")
        line2.lineColor = .green
        line2.valueTextColor = .black
        line2.valueFont = .systemFont(ofSize: 10)
        line2.lineWidth = 1
        
        
        let leftAxis = datebarChart.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 8)
        leftAxis.labelCount = 8
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        leftAxis.labelPosition = .outsideChart
        leftAxis.spaceTop = 0.15
        leftAxis.axisMinimum = 0
        leftAxis.addLimitLine(line)
        leftAxis.addLimitLine(line2)
        
        let rightAxis = datebarChart.rightAxis
        rightAxis.enabled = true
        rightAxis.labelFont = .systemFont(ofSize: 8)
        rightAxis.labelCount = 8
        rightAxis.valueFormatter = leftAxis.valueFormatter
        rightAxis.spaceTop = 0.15
        rightAxis.axisMinimum = 0
        
        datebarChart.delegate = self
        let set1 = BarChartDataSet(entries: entries, label: "This month")
        let data = BarChartData(dataSet: set1)
        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 8)!)
        data.barWidth = 0.5
        datebarChart.data = data
    }
    // Show every 15 minute intervel steps
    func showStepsEveryFifttenMinutes() {

        var i:Int =  self.stepsArray.count - 1
       
        for tempData in  self.stepsArray{
            let dateFormatter = DateFormatter()
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "hh:mm"
            
           
         
            entriesFifteenMinuteIntervel.append(BarChartDataEntry(x: Double(i), y: stepsArray[i]))
            i -= 1
           
        }
        labels.reverse()
        entriesFifteenMinuteIntervel.reverse()
        print(labels)
        print(entriesFifteenMinuteIntervel)
        let xAxis = dailybarChart.xAxis
        xAxis.labelPosition = .top
        xAxis.labelFont = .systemFont(ofSize: 8)
        xAxis.granularityEnabled = true
        xAxis.granularity = 0.5
        xAxis.labelCount = 96
        xAxis.spaceMax = 73.0
        xAxis.valueFormatter = IndexAxisValueFormatter(values: labels)
        
        
        
        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.minimumFractionDigits = 0
        leftAxisFormatter.maximumFractionDigits = 1
        leftAxisFormatter.negativeSuffix = ""
        leftAxisFormatter.positiveSuffix = ""
        
        let leftAxis = dailybarChart.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 8)
        leftAxis.labelCount = 8
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        leftAxis.labelPosition = .outsideChart
        leftAxis.spaceTop = 0.15
        leftAxis.axisMinimum = 0
        // leftAxis.addLimitLine(line)
        
        let rightAxis = dailybarChart.rightAxis
        rightAxis.enabled = true
        rightAxis.labelFont = .systemFont(ofSize: 8)
        rightAxis.labelCount = 8
        rightAxis.valueFormatter = leftAxis.valueFormatter
        rightAxis.spaceTop = 0.15
        rightAxis.axisMinimum = 0
        
        dailybarChart.delegate = self
        let set1 = BarChartDataSet(entries: entriesFifteenMinuteIntervel, label: "Today Activity Details")
        let data = BarChartData(dataSet: set1)
        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 8)!)
        data.barWidth = 0.1
        dailybarChart.data = data
        dailybarChart.zoom(scaleX: 0, scaleY: 0, x: 0, y: 0)
        dailybarChart.zoom(scaleX: 10, scaleY: 0, x: 0, y: 0)
//      dailybarChart.setScaleMinima(10.0, scaleY: 0.0)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //resetting total steps count(of global variable) from midnight to 0
        //self.upToPreviousSessionStepsfromTodayMidnight = 0
        //self.onStop()
    }
    
    //MARK: INTERFACE BUILDER ACTIONS
    
    @IBAction func postToSteemitBtnAction(_ sender : UIButton) {
        var userCanPost = true
        if let currentUser =  User.current() {
            // userCanPost = abs(currentUser.last_post_date_time_interval) > abs(AppDelegate.todayStartDate().timeIntervalSinceNow)
            let calender = Calendar.autoupdatingCurrent
            userCanPost = !(calender.isDateInToday(currentUser.last_post_date))
        }
        if userCanPost {
            let postToSteemitVC : PostToSteemitVC = PostToSteemitVC.instantiateWithStoryboard(appStoryboard: .SB_Main) as! PostToSteemitVC
            self.navigationController?.pushViewController(postToSteemitVC, animated: true)
        } else {
            self.showAlertWith(title: nil, message: Messages.one_post_per_day_error)
        }
    }
    @IBAction func snapPicBtnAction(_ sender: Any) {
        checkCameraAuthorizationStatus()
    }
    
    @IBAction func viewTrackingHistoryBtnAction(_ sender : UIButton) {
        self.navigationController?.pushViewController(TrackingHistoryVC.instantiateWithStoryboard(appStoryboard: .SB_Main), animated: true)
    }
    
    @IBAction func viewDailyLeaderboardBtnAction(_ sender : UIButton) {
        self.navigationController?.pushViewController(DailyLeaderBoardBVC.instantiateWithStoryboard(appStoryboard: .SB_Main), animated: true)
        
    }
    
    @IBAction func viewWalletBtnAction(_ sender : UIButton) {
        self.navigationController?.pushViewController(WalletVC.instantiateWithStoryboard(appStoryboard: .SB_Main), animated: true)
        
    }
    
    @IBAction func settingsBtnAction(_ sender : UIButton) {
       
       // TimeInterval()

    self.navigationController?.pushViewController(SettingsVC.instantiateWithStoryboard(appStoryboard: .SB_Main), animated: true)
        
        
        
    }
    
    func TimeInterval()  {
        
        self.timeArray.removeAll()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm" //Your date format
       
        
        //Get current hours minutes
        let calendar = Calendar.current
        let comp = calendar.dateComponents([.hour, .minute], from: Date())
        let hour = comp.hour ?? 0
        let minute = comp.minute ?? 0
        print(hour)
        let finalMinut:Int = (hour * 60) + minute
        print(finalMinut)
        
        //Get time intervel between two time
       
       
        let lastTime: Double = Double(24) // 10pm
        var currentTime: Double = 0
        var incrementMinutes: Double = 15 // increment by 15 minutes
        
        while currentTime <= lastTime {
            currentTime += (incrementMinutes/60)
            let hours = Int(floor(currentTime))
            let minutes = Int(currentTime.truncatingRemainder(dividingBy: 1)*60)
            let date12 = Date().dateString()
            if minutes == 0 {
                let  combindDate = date12 + " \(hours):00"
                timeArray.append("\(combindDate)")
                //timeArray.append("\(hours):00")
            } else {
                let combindDate = date12 + " \(hours):\(minutes)"
                //timeArray.append("\(hours):\(minutes)")
                timeArray.append("\(combindDate)")
            }
        }
        print(timeArray.count)
       // print(timeArray[51])
        for i in 0..<timeArray.count - 1 {
            let date1 = dateFormatter.date(from: timeArray[i])
            if let date2 = dateFormatter.date(from: timeArray[i + 1]) {
            self.pedometer.queryPedometerData(from: date1!, to:date2) { (data : CMPedometerData!, error) -> Void in
            
                if let pedData = data {
                    print("Steps:\(pedData.numberOfSteps)" + "\(String(describing: date1))"  +  "\(date2)")
                    self.stepsArray.append(Double(truncating: pedData.numberOfSteps))
                } else {
                    print("Steps:0")
                   // self.stepsArray.append(Double("0")!)
                   // print("Steps:" + "\(String(describing: date1))"  +  "\(date2)")
                }
                //
                            }
            }}
        
        
    }
    
    func tempTime(){
        //Get current hours minutes""
        let calendar = Calendar.current
        let comp = calendar.dateComponents([.hour, .minute], from: Date())
        let hour = comp.hour ?? 0
        let minute = comp.minute ?? 0
        print(hour)
        let finalMinut:Int = (hour * 60) + minute
        print(finalMinut)
        
        //Get time intervel between two time
        
       // let firstTime: Double = 5
        let lastTime: Double = Double(hour) // 10pm
        var currentTime: Double = 0
        let incrementMinutes: Double = 15 // increment by 15 minutes
        
        while currentTime <= lastTime {
            currentTime += (incrementMinutes/60)
            let hours = Int(floor(currentTime))
            let minutes = Int(currentTime.truncatingRemainder(dividingBy: 1)*60)
           // let date12 = Date().dateString()
            if minutes == 0 {
            
                timeIntervel.append("\(hours):00")
            } else {
              
                timeIntervel.append("\(hours):\(minutes)")
               
            }
        }
    }
    
    func addtimeIntoDate(minutes:Int)  -> Date {
        var timeInterval = DateComponents()
        timeInterval.month = 0
        timeInterval.day = 0
        timeInterval.hour = minutes/60
        timeInterval.minute =  minutes%60
        timeInterval.second = 0
        
        return  Calendar.current.date(byAdding: timeInterval, to: Date())!
    }
    //MARK: HELPERS
    
    
    
    func checkActifitUserID(){
        var actifitUserID = UserDefaults.standard.string(forKey: "actifitUserID") ?? ""
        if actifitUserID == ""{
            let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
            let uuid = NSUUID().uuidString
            actifitUserID = "\(uuid)\(appVersion)"
            UserDefaults.standard.set(actifitUserID, forKey: "actifitUserID")
        }
    }
    
    @objc func appMovedToBackground() {
        self.timer?.invalidate()
         self.timerAfterFifteen?.invalidate()
        
    }
//    - (IBAction)queryPedometer:(id)sender {
//
//    // retrieve data between dates
//    [self.pedometer queryPedometerDataFromDate:self.startDate toDate:self.endDate withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error) {
//
//    // historic pedometer data is provided here
//    [self presentPedometerData:pedometerData];
//
//    }];
//    }
    @objc func appMovedToForeground() {
        let calender = Calendar.autoupdatingCurrent
        if !(calender.isDateInToday(startDate)) {
            let yesterdayStartDate = AppDelegate.startDateFor(date: self.startDate)
            if let after24HoursAfteYyesterdayStartDate = Calendar.current.date(
                byAdding: .hour,
                value: 24,
                to: yesterdayStartDate) {
                
                var yesterdayStartDate = Date().yesterday.setTime(hour: 00, min: 00, sec: 00)!
                let currentDate = yesterdayStartDate
                let timezoneOffset =  TimeZone.current.secondsFromGMT()
                let epochDate = currentDate.timeIntervalSince1970
                let timezoneEpochOffset = (epochDate + Double(timezoneOffset))
                yesterdayStartDate = Date(timeIntervalSince1970: timezoneEpochOffset)
                
                var toDate = Date().setTime(hour: 00, min: 00, sec: 00)!
                let currentDate1 = toDate
                let timezoneOffset1 =  TimeZone.current.secondsFromGMT()
                let epochDate1 = currentDate1.timeIntervalSince1970
                let timezoneEpochOffset1 = (epochDate1 + Double(timezoneOffset1))
                toDate = Date(timeIntervalSince1970: timezoneEpochOffset1)
                
                self.pedometer.queryPedometerData(from: yesterdayStartDate, to: toDate) {
                    [weak self] pedometerData, error in
                    guard let pedometerData = pedometerData, error == nil else { return }
                    DispatchQueue.main.async {
                        print("yesterday total steps : \(pedometerData.numberOfSteps)")
                        self?.saveCurrentStepsCounts(steps: pedometerData.numberOfSteps.intValue, midnightStartDate: yesterdayStartDate)
                    }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.checkAuthorizationStatusAndStartTracking()
            }
        } else {
            self.checkAuthorizationStatusAndStartTracking()
        }
    }
    
//    @objc func queryAndUpdateDatafromMidnight() {
//        let calender = Calendar.autoupdatingCurrent
//
//        if !(calender.isDateInToday(startDate)) {
//            self.showStepsCount(count: 0)
//            self.checkAuthorizationStatusAndStartTracking()
//        } else {
//
//            let allActivities = Activity.all()
//            if allActivities.count == 0{
//                self.addDataForPreviousDate()
//            }
//
//            var todayStartDate = Date().setTime(hour: 00, min: 00, sec: 00)!
//            let currentDate1 = todayStartDate
//            let timezoneOffset1 =  TimeZone.current.secondsFromGMT()
//            let epochDate1 = currentDate1.timeIntervalSince1970
//            let timezoneEpochOffset1 = (epochDate1 + Double(timezoneOffset1))
//            todayStartDate = Date(timeIntervalSince1970: timezoneEpochOffset1)
//
//            self.pedometer.queryPedometerData(from: todayStartDate, to: AppDelegate.todayStartDate()) {
//                [weak self] pedometerData, error in
//                guard let pedometerData = pedometerData, error == nil else { return }
//                DispatchQueue.main.async {
//                    let totalSteps = pedometerData.numberOfSteps.intValue
//                    self?.showStepsCount(count: totalSteps)
//                    self?.saveCurrentStepsCounts(steps: totalSteps, midnightStartDate: AppDelegate.todayStartDate())
//                    NotificationCenter.default.post(name: Notification.Name.init(StepsUpdatedNotification), object: nil, userInfo: ["steps" : totalSteps])
//                }
//            }
//        }
//    }
    
    
    @objc func queryAndUpdateDatafromMidnight() {
        let calender = Calendar.autoupdatingCurrent
        if !(calender.isDateInToday(startDate)) {
            self.showStepsCount(count: 0)
            self.checkAuthorizationStatusAndStartTracking()
        } else {
            
            let allActivities = Activity.all()
            if allActivities.count == 0{
                self.addDataForPreviousDate()
            }
            
            self.pedometer.queryPedometerData(from: AppDelegate.todayStartDate(), to: Date()) {
                [weak self] pedometerData, error in
                guard let pedometerData = pedometerData, error == nil else { return }
                DispatchQueue.main.async {
                    let totalSteps = pedometerData.numberOfSteps.intValue
                    self?.showStepsCount(count: totalSteps)
                   
                    self?.saveCurrentStepsCounts(steps: totalSteps, midnightStartDate: AppDelegate.todayStartDate())
                    NotificationCenter.default.post(name: Notification.Name.init(StepsUpdatedNotification), object: nil, userInfo: ["steps" : totalSteps])
                }
            }
        }
    }
    
    
    @objc func addDataForPreviousDate() {
        var yesterdayStartDate = Date().yesterday.setTime(hour: 00, min: 00, sec: 00)!
        let currentDate = yesterdayStartDate
        let timezoneOffset =  TimeZone.current.secondsFromGMT()
        let epochDate = currentDate.timeIntervalSince1970
        let timezoneEpochOffset = (epochDate + Double(timezoneOffset))
        yesterdayStartDate = Date(timeIntervalSince1970: timezoneEpochOffset)
        
        var toDate = Date().setTime(hour: 00, min: 00, sec: 00)!
        let currentDate1 = toDate
        let timezoneOffset1 =  TimeZone.current.secondsFromGMT()
        let epochDate1 = currentDate1.timeIntervalSince1970
        let timezoneEpochOffset1 = (epochDate1 + Double(timezoneOffset1))
        toDate = Date(timeIntervalSince1970: timezoneEpochOffset1)
        
        
        let yest = AppDelegate.todayStartDate().yesterday
        
        self.pedometer.queryPedometerData(from: yest, to: AppDelegate.todayStartDate()) {
            [weak self] pedometerData, error in
            guard let pedometerData = pedometerData, error == nil else { return }
            let allActivities = Activity.all()
            DispatchQueue.main.sync {
                let totalSteps = pedometerData.numberOfSteps.intValue
                let activtyInfo = [ActivityKeys.id : allActivities.count, ActivityKeys.date : yesterdayStartDate, ActivityKeys.steps : totalSteps] as [String : Any] //11223344
                let activity = Activity()
                activity.upadteWith(info: activtyInfo)

            }
        }
    }
    
    @objc func queryAndUpdateDatafromMidnightFifteenMinute() {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let calender = Calendar.autoupdatingCurrent
        if !(calender.isDateInToday(startDate)) {
            self.showStepsCount(count: 0)
            self.checkAuthorizationStatusAndStartTracking()
        } else {
            
            for index in 0..<TimeSlot.count - 1 {
                
                let startdate  = TimeSlot[index]
                let endDate  = TimeSlot[index + 1]
                let date12 = Date().dateString()
                print("startDate " + startdate)
                print("endDate " + endDate)
                let sDate = date12 +  " \(startdate)"
                let eDate = date12 +  " \(endDate)"
                
                let date1  =  dateFormatter.date(from: sDate)
                let date2 =  dateFormatter.date(from: eDate)
                
                //  let today = Date().dateString()
                // self.saveAfterFifteenMinute(steps: 1, midnightStartDate: today, timeInterval:  endDate,id: index)
                
                if let date1New = date1 {
                    if let date2New = date2 {
                        self.pedometer.queryPedometerData(from: date1New, to: date2New) {
                            [weak self] pedometerData, error in
                            guard let pedometerData = pedometerData, error == nil else { return }
                            DispatchQueue.main.sync {
                                let totalSteps = pedometerData.numberOfSteps.intValue
                                print(totalSteps)
                                let today = Date().dateString()
                                
                                self?.saveAfterFifteenMinute(steps: totalSteps, midnightStartDate: today, timeInterval:  endDate, id: index)
                            }
                        }
                    }
                }
                
            }
            
            
        }
    }
}

extension ActivityTrackingVC {
    
    //on start event handler
    private func checkAuthorizationStatusAndStartTracking() {
        //resetting the start date when wiew appears
        self.startDate = Date()
        checkAuthorizationStatus()
        startUpdating()
    }
    
    //on stop event handler
    private func onStop() {
        stopUpdating()
    }
    
    //stop updating user activity
    private func stopUpdating() {
        activityManager.stopActivityUpdates()
        pedometer.stopUpdates()
        if #available(iOS 10.0, *) {
            pedometer.stopEventUpdates()
        } else {
            pedometer.stopUpdates()
            // Fallback on earlier versions
        }
    }
    
    private func on(error: Error) {
        //handle error
    }
    
    //check for activity authorization Status
    
    private func checkCameraAuthorizationStatus() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            DispatchQueue.main.async {
                self.takePicture()
            }
            
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.takePicture()
                    }
                }
            }
            
        case .denied: // The user has previously denied access.
            self.showAlertWith(title: "Alert", message: "Please enable the camera usage under settings")
            return
        case .restricted: // The user can't grant access due to restrictions.
            self.showAlertWith(title: "Alert", message: "Please enable the camera usage under settings")
            return
        }
    }
    
    private func checkAuthorizationStatus() {
        if #available(iOS 11.0, *) {
            switch CMMotionActivityManager.authorizationStatus() {
            case CMAuthorizationStatus.denied:
                onStop()
                stepsCountLabel.text = "Not available"
            default:break
            }
        } else {
            //https://stackoverflow.com/questions/23360460/cmmotionactivitymanager-authorizationstatus?lq=1
            // Fallback on earlier versions
            
            /* self.activityManager.queryActivityStarting(from: Date(), to: Date(), to: OperationQueue.main, withHandler: { (activities: [CMMotionActivity]?, error: Error?) -> () in
             if error != nil {
             let errorCode = (error! as NSError).code
             if errorCode == Int(CMErrorMotionActivityNotAuthorized.rawValue) {
             self.onStop()
             self.stepsCountLabel.text = "Not available"
             }
             } else {
             print("Authorized")
             }
             })*/
        }
    }
    
    //track activity types if Motion activity is available on user device
    private func startUpdating() {
        if CMMotionActivityManager.isActivityAvailable() {
            startTrackingActivityType()
        } else {
            print("Not available")
        }
        
        if CMPedometer.isStepCountingAvailable() {
            self.startQueryingActivityEveryTwoSecond()
        } else {
            stepsCountLabel.text = "Not available"
        }
    }
    
    //save/update user current steps from today midnight
    private func saveCurrentStepsCounts(steps : Int, midnightStartDate : Date) {
        let allActivities = Activity.all()
        if let activity = allActivities.first(where: {$0.date == midnightStartDate}){
            // activity.update(date: AppDelegate.todayStartDate(), steps:steps)
            let activtyInfo = [ActivityKeys.id : activity.id, ActivityKeys.date : activity.date, ActivityKeys.steps : steps] as [String : Any]
            activity.upadteWith(info: activtyInfo)
        } else {
            //allActivities.count + 1 //1122
            let activtyInfo = [ActivityKeys.id : allActivities.count + 1, ActivityKeys.date : midnightStartDate, ActivityKeys.steps : steps] as [String : Any]
            //Activity.deleteAll()
            let activity = Activity()
            activity.upadteWith(info: activtyInfo)
//            Activity.saveWith(info: activtyInfo)
            
        }
    }
    
   //save/update user current steps from today midnight
    private func saveAfterFifteenMinute(steps : Int, midnightStartDate : String, timeInterval:String,id:Int) {
    
        do {
            let realm = try Realm()
            
            //        let realm = try! Realm()
            
            let allActivities = ActivityFifteenMinutesInterval()
            
            allActivities.date = midnightStartDate
            allActivities.interval = timeInterval
            allActivities.steps = steps
            allActivities.id = id
            allActivities.idInString = String(id)
            allActivities.stepsInString = String(steps)
            
            
//            try! realm.write {
//                realm.add(allActivities, update: .modified) //true  //1122
//            }
            
            do {
                try realm.write {
                    realm.add(allActivities, update: .modified) //true  //1122
                }
            } catch {
                // LOG ERROR
            }
            
            
            print("all data added..")
            
            let allsavedRecordsOfHistory = AllRecordsOfActivitiesNew.all()
            
            let arrayOfActivities = ActivityFifteenMinutesInterval.all()
            let allRecordsOfActivitiesNew = AllRecordsOfActivitiesNew()
            allRecordsOfActivitiesNew.date = midnightStartDate
            //allRecordsOfActivitiesNew.activities.append(objectsIn: arrayOfActivities)
//            let dataToSave = NSKeyedArchiver.archivedData(withRootObject: arrayOfActivities)
            
            
            let encoder = JSONEncoder()
            let encodedData: Data? = try? encoder.encode(arrayOfActivities)
           
            
            
            allRecordsOfActivitiesNew.activitiesListData = encodedData
            
            
            //        let dataToSave = NSKeyedArchiver.archivedData(withRootObject: arrayOfActivities)
            //        print(dataToSave)
            //        if let anArrayOfPersonsRetrieved = NSKeyedUnarchiver.unarchiveObject(with: dataToSave) as? [ActivityFifteenMinutesInterval] {
            //            print(anArrayOfPersonsRetrieved)
            //
            //        }
            
            
            
            
            //        try! realm.write {
            //            realm.add(allRecordsOfActivitiesNew, update: .all) //true  //1122
            //        }
            
            //TEST
            if let activityInHistory = allsavedRecordsOfHistory.first(where: {$0.date == midnightStartDate}){
                //            let activityToUpdate = ["id":activityInHistory.id, "date": midnightStartDate,  "activities" : allRecordsOfActivitiesNew.activities] as [String : Any]
                //            activityInHistory.upadteWith(info: activityToUpdate)
                
                try! realm.write {
                    activityInHistory.activitiesListData = allRecordsOfActivitiesNew.activitiesListData
                }
                
            } else {
                let activityToSave = ["id":allsavedRecordsOfHistory.count+1,"date": midnightStartDate, "activitiesListData":allRecordsOfActivitiesNew.activitiesListData] as [String : Any]
                allRecordsOfActivitiesNew.saveWith(info: activityToSave)
            }
            //TEST
            
            if id == TimeSlot.count - 2{
                self.barEntry()
                self.historyFifteenMinute = ActivityFifteenMinutesInterval.all()
                
                self.history = Activity.allWithoutCountZero()
                self.everyDayChart()
            }
        } catch let error as NSError {
              print("Error Occured")
            }
        
   }
    
    
    //tracks different types of user activity state
    private func startTrackingActivityType() {
        activityManager.startActivityUpdates(to: OperationQueue.main) {
            (activity: CMMotionActivity?) in
            guard let activity = activity else { return }
            DispatchQueue.main.async {
                if activity.walking {
                    print("Walking")
                } else if activity.stationary {
                    print("Stationary")
                } else if activity.running {
                    print("Running")
                } else if activity.automotive {
                    print("Automotive")
                }
            }
        }
    }
    
    //ask pedometer to start updating the user data on regular basis
    private func startQueryingActivityEveryTwoSecond() {
        if #available(iOS 10.0, *) {
            self.timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block: { (timer) in
                self.queryAndUpdateDatafromMidnight()
            })
            self.timerAfterFifteen = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { (timer) in
                self.queryAndUpdateDatafromMidnightFifteenMinute()
            })
        } else {
            // Fallback on earlier versions
            self.timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.queryAndUpdateDatafromMidnight), userInfo: nil, repeats: true)
             self.timerAfterFifteen = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.queryAndUpdateDatafromMidnightFifteenMinute), userInfo: nil, repeats: true)
        }
    }
    
    //show the user activity data on UI
    private func showStepsCount(count : Int) {
     self.pieChart(stepsCount: count)
        if UserDefaults.standard.bool(forKey: "isFitSystemSelected") == true{
                self.stepsCountLabel.text = "Fitbit Tracking Mode On"
            return
        }
     
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        self.stepsCountLabel.text = "Total Activity Today: " + (formatter.string(from: NSNumber(value: Int(count))) ?? "")
       
        self.checkAndPostNotification(count: count)
        
       
        
        
//        if count>=3125 && count<=3135{
//            self.sendNotification(steps: 5000)
//        }else if count == 10000{
            //self.sendNotification(steps: 10000)
//        }
        
        self.historyFifteenMinute = ActivityFifteenMinutesInterval.all()
        self.history = Activity.allWithoutCountZero()
        self.everyDayChart()
       
   
    }
    
    
    func checkAndPostNotification(count:Int)
    {
        let todayNewDate = Date().dateString(withFormat: "yyyy-MM-dd")
        
        if let todaySavedDate = UserDefaults.standard.value(forKey: "DateForToday") as? String{
            if todayNewDate == todaySavedDate{
                if let FiveKActivity = UserDefaults.standard.value(forKey: "5KActivityReached") as? Bool{
                    if !FiveKActivity && count>=5000{
                        UserDefaults.standard.set(true, forKey: "5KActivityReached")
                        self.appDelegate?.scheduleNotification(steps: 5)
                    }else{
                        if let TenKActivity = UserDefaults.standard.value(forKey: "10KActivityReached") as? Bool{
                            if !TenKActivity && count>=10000{
                                UserDefaults.standard.set(true, forKey: "10KActivityReached")
                                self.appDelegate?.scheduleNotification(steps: 10)
                            }
                        }
                    }
                }
            }else{
                UserDefaults.standard.set(todayNewDate, forKey: "DateForToday")
                UserDefaults.standard.set(false, forKey: "5KActivityReached")
                UserDefaults.standard.set(false, forKey: "10KActivityReached")
            }
        }else{
            UserDefaults.standard.set(todayNewDate, forKey: "DateForToday")
            UserDefaults.standard.set(false, forKey: "5KActivityReached")
            UserDefaults.standard.set(false, forKey: "10KActivityReached")
        }
    }
    
    // funtion to open the camera for taking picture
    func takePicture(){
        let imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    // MARK: Delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        album.save(image: image!)
    }
    
    func barEntry()  {
        var data_id = 0
        let indHr = Int()
        let indMin = Int()
        let hoursInDay = 24;
        let minInt = [0,15,30,45]
        let minSlots = minInt.count
        
        var labels = [String](repeating: String(), count: hoursInDay * minSlots)
        entriesFifteenMinuteIntervel    = []
        dailyLabels                     = []
        // String[] labels = new String[hoursInDay * minSlots];
        //loop through whole day as hours
        for indHr in 0..<hoursInDay
        {
            for indMin in indMin..<minSlots{
                var slotLabel = "" + "\(indHr)";
                if indHr < 10 {
                    slotLabel =  "0" + "\(indHr)";
                }
                labels[data_id] = slotLabel + ":";
                if (minInt[indMin] < 10) {
                    slotLabel +=  "\(minInt[indMin])";
                    labels[data_id] +=  "0" + "\(minInt[indMin])";
                } else {
                    slotLabel += "\(minInt[indMin])";
                    labels[data_id] += "\(minInt[indMin])";
                }
                print(labels[data_id])
                
                var  matchingSlot = -1;
//                entriesFifteenMinuteIntervel.append(BarChartDataEntry(x: Double(labels[data_id])!, y: Double(data_id)))
                
           data_id += 1;
        
            }
            TimeSlot = labels
        }
         var k:Int = TimeSlot.count - 1
        for i in  TimeSlot {
           
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "HH:mm"
            let tempLabel = dateFormatter.date(from: i)
            
            if tempLabel == nil{
                dailyLabels.append("00:00")
            }else{
                let temp  =  dateFormatter.string(from: tempLabel!)
                dailyLabels.append(temp)
            }
            
            var step = i
            var contents = [ActivityFifteenMinutesInterval]()
            let dataList = ActivityFifteenMinutesInterval.all()
            
            //print(dataList)
            step    = step.replacingOccurrences(of: ":", with: ".")
            
            let time = TimeSlot[k].replacingOccurrences(of: ":", with: ".")
            
            
             contents = dataList.filter({$0.interval == i})
            
            
            if !contents.isEmpty {
                if (contents[0].steps) > 0{
//                print(contents[0].steps)
                    let time2 = contents[0].interval.replacingOccurrences(of: ":", with: ".")
                    entriesFifteenMinuteIntervel.append(BarChartDataEntry(x: Double(time2)! * 4.02, y: Double(contents[0].steps)))
                }
                
            }
            else{
                //if(step > 0){
                /// entriesFifteenMinuteIntervel.append(BarChartDataEntry(x: Double(step)!, y: Double(0)))
                // }
            }
            
            k = k - 1
        }
//        dailyLabels.reverse()
//        entriesFifteenMinuteIntervel.reverse()
        
        print(dailyLabels)
        print(entriesFifteenMinuteIntervel)
        let xAxis = dailybarChart.xAxis
        xAxis.labelPosition = .top
        xAxis.labelFont = .systemFont(ofSize: 8)
        xAxis.granularityEnabled = true
        xAxis.granularity = 1.0
        xAxis.labelCount = 96
        xAxis.valueFormatter = IndexAxisValueFormatter(values: dailyLabels)
        
        
       
        
        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.minimumFractionDigits = 0
        leftAxisFormatter.maximumFractionDigits = 1
        leftAxisFormatter.negativeSuffix = ""
        leftAxisFormatter.positiveSuffix = ""
        
       
        
        let leftAxis = dailybarChart.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 8)
        leftAxis.labelCount = 8
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        leftAxis.labelPosition = .outsideChart
        leftAxis.spaceTop = 0.15
        leftAxis.axisMinimum = 0
        
        
        
        let rightAxis = dailybarChart.rightAxis
        rightAxis.enabled = true
        rightAxis.labelFont = .systemFont(ofSize: 8)
        rightAxis.labelCount = 8
        rightAxis.valueFormatter = leftAxis.valueFormatter
        rightAxis.spaceTop = 0.15
        
        rightAxis.axisMinimum = 0
        
        dailybarChart.delegate = self
        let set1 = BarChartDataSet(entries: entriesFifteenMinuteIntervel, label: "Today Activity Details")
        let data = BarChartData(dataSet: set1)
        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 8)!)
        data.barWidth = 0.1
    
       
        dailybarChart.data = data
        
        
//        dailybarChart.zoom(scaleX: 0, scaleY: 0, x: 0, y: 0)
//        dailybarChart.zoom(scaleX: 7, scaleY: 0, x: 0, y: 0)
//        dailybarChart.setScaleMinima(6.0, scaleY: 0.0)
        
        
        if entriesFifteenMinuteIntervel.count > 20{
            dailybarChart.zoom(scaleX: 7.0, scaleY: 0, x: 0, y: 0)
                   dailybarChart.setScaleMinima(6.0, scaleY: 0.0)
               }else if entriesFifteenMinuteIntervel.count > 15{
            dailybarChart.zoom(scaleX: 5.0, scaleY: 0, x: 0, y: 0)
            // dailybarChart.setScaleMinima(4.0, scaleY: 0.0)
        }else if entriesFifteenMinuteIntervel.count >= 7{
                   dailybarChart.zoom(scaleX: 3.5, scaleY: 0, x: 0, y: 0)
              //      dailybarChart.setScaleMinima(3.0, scaleY: 0.0)
               }else if entriesFifteenMinuteIntervel.count > 5{
                   dailybarChart.zoom(scaleX: 1.5, scaleY: 0, x: 0, y: 0)
            //dailybarChart.setScaleMinima(1.5, scaleY: 0.0)
               }
        
       
        
    }
    
    
    
}






