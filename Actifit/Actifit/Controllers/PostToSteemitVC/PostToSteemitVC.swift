//
//  PostToSteemitVC.swift
//  Actifit
//
//  Created by Hitender kumar on 12/08/18.
//  Copyright © 2018 actifit.io. All rights reserved.
//

import UIKit
import AWSS3
import AWSMobileClient
import SnapKit
import SafariServices
import HealthKit
import CryptoKit
import Down
class PostToSteemitVC: UIViewController,UINavigationControllerDelegate,UIActionSheetDelegate {
    @IBOutlet weak var tableView: UITableView!
    

    @IBOutlet weak var backBtn : UIButton!
    var randomHints = ["Describe your day's activity using original content in as little as a few sentences. The more the merrier!","What did you do today?", "Got some cool content to share?", "The more original content you write, the better the potential rewards!", "Did you cross some milestones today? tell the world about it!", "How's your fitness journey going? share it with other actifitters", "You got cool pics from your walk/jog/workout/...? Let's go"]
    @IBOutlet weak var sendPostBtn: UIButton!
    var postPayout = ""
    var updatedpostContent: String? = nil
   // @IBOutlet weak var previewTextView: UITextView!
    var tagsFromCell = ""
    var activityTypes: String = ""
    var measurmentKeys: [String: String] = [:]
    var authenticationController: AuthenticationController?
    var stepCount = 0
    var encyptedFitBit = ""
    var isFitBitCount = false
    var isTodaySelected = true
    var fitBitStepCount = 0
    var reportView: ReportPreView!
    var isMaxiToken = false
    var ishealthStoreCount = false
    var healthStore = HKHealthStore()
    lazy var currentUser = {
        return User.current()
    }()
    
    lazy var settings = {
           return Settings.current()
    }()
    var testText = ""
    var defaultPostTitle = ""
    var activityDate = ""
    var activityDateToSave = Date()
    var detailedActivityStepsDataString = ""
    var randomIndex : Int? {
        return Int.random(in: 0..<randomHints.count)
    }
    
    //MARK: VIEW LIFE CYCLE
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        
        
        sendPostBtn.layer.cornerRadius = 10
        sendPostBtn.layer.borderColor = UIColor.white.cgColor
        sendPostBtn.layer.borderWidth = 2
        

        AWSMobileClient.initialize()
       // self.activityTypeLabel.text = ""
        self.defaultPostTitle = "\(Messages.default_post_title)\(todayDateStringWithFormat(format: "MMMM d yyyy"))"
      //  let dd = Date().dayAfter()
        
        for _ in 0..<Activity.allWithoutCountZero().count{
            
            
            if let activity = Activity.allWithoutCountZero().first(where: {resetTime(date: $0.date)  ==  resetTime(date: AppDelegate.todayStartDate())}) {
                self.stepCount = activity.steps
            //    self.activityCountValueLabel.text = "\(activity.steps)"
                self.activityDate = AppDelegate.todayStartDate().dateString()
                self.activityDateToSave = AppDelegate.todayStartDate()
                self.makeTodayAllEnteriesAsDetailedActivityString()
            }
            
            
               }
        
        self.applyFinishingTouchToUIElements()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
       // let content = UserDefaults.standard.string(forKey: "postcontent") ?? ""
       // postContentTextView.text = content
        setUpMarkDownView()
        updateMarkDownView()
       // btnToday.setImage( UIImage.init(named: "radioSelected"), for: .normal)
        // activityDate = dateformat(date: Date())
        print(activityDate)
        setupInitials()
        setTableView()
    }
    
    
    private func setTableView() {
        tableView.register(UINib(nibName: "ReprotTitleCell", bundle: nil), forCellReuseIdentifier: "ReprotTitleCell")
        tableView.register(UINib(nibName: "ActivityDateCell", bundle: nil), forCellReuseIdentifier: "ActivityDateCell")
        tableView.register(UINib(nibName: "ActivityCountCell", bundle: nil), forCellReuseIdentifier: "ActivityCountCell")
        
        tableView.register(UINib(nibName: "ReportTagsCell", bundle: nil), forCellReuseIdentifier: "ReportTagsCell")
        tableView.register(UINib(nibName: "TrackMeasurementsCell", bundle: nil), forCellReuseIdentifier: "TrackMeasurementsCell")
        tableView.register(UINib(nibName: "ActivityTypesCell", bundle: nil), forCellReuseIdentifier: "ActivityTypesCell")
        tableView.register(UINib(nibName: "ReportContentCell", bundle:nil), forCellReuseIdentifier: "ReportContentCell")
        tableView.separatorStyle = .none
        
    }
    
    func setupInitials()
    {
    //    steemUserNameLabel.text              = "steem_username_lbl".localized()
    //    steemPrivateKeyLabel.text            = "steem_pvt_posting_key".localized()
       // helpmeFindPrivateKeyBtn.titleLabel!.text              = "steem_username_lbl".localized()
     //   reportTitleLabel.text                = "report_title".localized()
    //    fullReportCardLabel.text             = "full_report_AFIT_pay".localized()
    //    maxAFITTokenLabel.text               = "full_AFIT_checkbox".localized()
      //  activityCountLabel.text              = "activity_count_lbl".localized()
       // fitBitSyncBtn.titleLabel!.text       = "fitbit_sync_btn_lbl".localized()
      //  activityTypeLabel.text               = "activity_type_lbl".localized()
      //  trackMeasurementsLabel.text          = "track_measurements_lbl".localized()
    //    heightLabel.text                     = "height_lbl".localized()
     //   weightLabel.text                     = "weight_lbl".localized()
     //   bodyFatLabel.text                    = "body_fat_lbl".localized()
      //  waistLabel.text                      = "waist_size_lbl".localized()
       // thighsLabel.text                     = "thighs_size_lbl".localized()
       // chestLabel.text                      = "chest_size_lbl".localized()
       // reportTitleLabel.text                = "report_tags_lbl".localized()
       // reportImagesLabel.text               = "report_images_lbl".localized()
       // insertImageBtn.titleLabel!.text      = "insert_img_btn_lbl".localized()
       // postContentLabel.text                = "report_content_lbl".localized()
       // markdownContentLabel.text            = "markdown_content_note".localized()
        
        //self.fitBitSyncBtn.setTitle("fitbit_sync_btn_lbl".localized(), for: .normal)
       // self.insertImageBtn.setTitle("insert_img_btn_lbl".localized(), for: .normal)
       // self.postToSteemitBtn.setTitle("post_to_steem_btn_txt".localized(), for: .normal)

    }
    
    func setUpMarkDownView() {
//      //  markDownEditorHeight.constant = postContentTextView.text != "" ? 500 :  50
//        updateViewConstraints()
//        reportView =  ReportPreView()
//      //  markDOwnView.addSubview(reportView)
//        reportView.snp.makeConstraints { (make) in
//            make.top.equalToSuperview()
//            make.width.equalToSuperview()
//            make.height.equalToSuperview()
//        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        notificationCenter.removeObserver(self, name: NSNotification.Name.init(StepsUpdatedNotification), object: nil)
        
    }
    
    func uploadData(image:UIImage) {
        ActifitLoader.show(title: "Uploading", animated: true)
        let data: Data =  UIImageJPEGRepresentation(image, 0.7)! //Data() //UIImageJPEGRepresentation(image, 1)!
        if data.count > 5 * 1024 * 1024 * 1024 {
              showAlertWith(title: "Error", message: "File is too large to upload.")
               return
           }
        let deviceUUID: String = (UIDevice.current.identifierForVendor?.uuidString)!
        let filename = deviceUUID + String(Date().ticks)
        print("file -\(filename)")
        
        let expression = AWSS3TransferUtilityMultiPartUploadExpression()
        expression.progressBlock = {(task, progress) in
            print(progress)
            DispatchQueue.main.async(execute: {
                print(progress)
            })
        }
        
        var completionHandler: AWSS3TransferUtilityMultiPartUploadCompletionHandlerBlock
        completionHandler = { (task, error) -> Void in
            DispatchQueue.main.async(execute: {
                var imgUrl = "![](https://usermedia.actifit.io/\(filename))"
                imgUrl = imgUrl.replacingOccurrences(of: "io//", with: "io/")
            //    self.postContentTextView.text = self.postContentTextView.text + imgUrl
                if let data =  UserDefaults.standard.string(forKey: "postcontent") {
                    UserDefaults.standard.set(data + imgUrl, forKey: "postcontent")
                    self.updatedpostContent = data + imgUrl
                } else {
                    self.updatedpostContent = imgUrl
                    UserDefaults.standard.set(imgUrl, forKey: "postcontent")
                }
                  
                
               
             
                self.tableView.reloadRows(at: [IndexPath(row: 6, section: 0)], with: .automatic)
                self.updateMarkDownView()
                    ActifitLoader.hide()
            })
        }
        
        let transferUtility = AWSS3TransferUtility.default()
        transferUtility.uploadUsingMultiPart(data:data,
                                             bucket: "actifit",
                                             key:filename,
                                             contentType: "image/jpeg",
                                             expression: expression,
                                             completionHandler: completionHandler).continueWith {
                                                (task) -> AnyObject? in
                                                if let error = task.error {
                                                    print("Error: \(error.localizedDescription)")
                                                }
                                                
                                                if let _ = task.result {
                                                    print(task.result?.status as Any)
                                                    
                                                }
                                                return nil;
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateMarkDownView()
    }
    
    func updateMarkDownView(){
//        guard let markDownString = postContentTextView.text else {
//            return
//        }
//
//        if let downView = try? DownView(frame: self.markDOwnView.bounds, markdownString: markDownString) {
//            markDOwnView.addSubview(downView)
//            if markDownString != "" {
//                markDownEditorHeight.constant = 500
//            } else {
//                markDownEditorHeight.constant = 50
//            }
//            markDOwnView.layoutIfNeeded()
//
//        }
        
    }
    
    //Date format
    func dateformat(date:Date)  -> String  {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var tempLabel = dateFormatter.string(from: date)
        tempLabel   =  tempLabel.replacingOccurrences(of: "-", with: "")
        return tempLabel
    }
    
    
    func makeTodayAllEnteriesAsDetailedActivityString()
    {
        self.detailedActivityStepsDataString = ""
        let dataList = ActivityFifteenMinutesInterval.all().filter({$0.steps != 0})
        for activity in dataList{
            let timeSlot = activity.interval.replacingOccurrences(of: ":", with: "")
            let stepsInTimeSlot = String(activity.steps)
            self.detailedActivityStepsDataString += timeSlot + stepsInTimeSlot + "|"
        }
        print(detailedActivityStepsDataString)
    }
    
    
//    func makeYesterdayAllEntriesAsDetailedActivityString()
//    {
//        self.detailedActivityStepsDataString = ""
//        let date = resetTime(date: AppDelegate.todayStartDate().addingTimeInterval(-60*60*24))
//        let allsavedRecordsOfHistory = AllRecordsOfActivitiesNew.all()
//        let selectedDateHistory = allsavedRecordsOfHistory.filter({$0.date == date.dateString()})
//        var activitiesDataList : [ActivityFifteenMinutesInterval] = []
//        if selectedDateHistory.count > 0{
//            if let anArrayOfPersonsRetrieved = NSKeyedUnarchiver.unarchiveObject(with: selectedDateHistory[0].activitiesListData) as? [ActivityFifteenMinutesInterval] {
//                for activityObj in anArrayOfPersonsRetrieved{
//                    let activity = ActivityFifteenMinutesInterval()
//                    activity.id = Int(activityObj.idInString) ?? 0
//                    activity.date = activityObj.date
//                    activity.interval = activityObj.interval
//                    activity.steps = Int(activityObj.stepsInString) ?? 0
//                    if activity.steps > 0{
//                        activitiesDataList.append(activity)
//                    }
//                }
//                for activity in activitiesDataList{
//                    let timeSlot = activity.interval.replacingOccurrences(of: ":", with: "")
//                    let stepsInTimeSlot = String(activity.steps)
//                    self.detailedActivityStepsDataString += timeSlot + stepsInTimeSlot + "|"
//                }
//            }
//        }
//    }
    
    
    
    
    //MARK: INTERFACE BUILDER ACTIONS
    
    @IBAction func backBtnAction(_ sender : UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    //TODO: remove this
    @IBAction func btnToday(_ sender : UIButton)
    {
        isTodaySelected = true
       // btnToday.setImage( UIImage.init(named: "radioSelected"), for: .normal)
        //btnYesterday.setImage( UIImage.init(named: "radio"), for: .normal)
        activityDate = dateformat(date: Date())
      //  self.activityCountValueLabel.text = "0"
        self.stepCount = 0
        for _ in 0..<Activity.allWithoutCountZero().count {
            if let activity = Activity.allWithoutCountZero().first(where: {resetTime(date: $0.date)  ==  resetTime(date: AppDelegate.todayStartDate())}) {
                self.stepCount = activity.steps
          //      self.activityCountValueLabel.text = "\(activity.steps)"
                self.activityDate = AppDelegate.todayStartDate().dateString()
                self.activityDateToSave = AppDelegate.todayStartDate()
                self.makeTodayAllEnteriesAsDetailedActivityString()
            }
        }
        
    }
    
    func btnTodayTapped() {
        //TODO: reload steps in tableView
        isTodaySelected = true
        self.stepCount = 0
        for _ in 0..<Activity.allWithoutCountZero().count{
           

            
            if let activity = Activity.allWithoutCountZero().first(where: {resetTime(date: $0.date)  ==  resetTime(date: AppDelegate.todayStartDate())}) {
              //  self.activityCountValueLabel.text = "\(activity.steps)"
                self.stepCount = activity.steps
                self.activityDate = AppDelegate.todayStartDate().dateString()
                self.activityDateToSave = AppDelegate.todayStartDate()
                self.makeTodayAllEnteriesAsDetailedActivityString()
            }
        }
        tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
    }
    
    func btnYesterdayTapped() {
        isTodaySelected = false
      //  btnToday.setImage( UIImage.init(named: "radio"), for: .normal)
      //  btnYesterday.setImage( UIImage.init(named: "radioSelected"), for: .normal)

      //  self.activityCountValueLabel.text = "0"
        self.stepCount = 0
        
        for i in 0..<Activity.allWithoutCountZero().count{
            

            
            if(resetTime(date: Activity.allWithoutCountZero()[i].date) == resetTime(date: AppDelegate.todayStartDate().addingTimeInterval(-60*60*24)) ){
                self.stepCount = Activity.allWithoutCountZero()[i].steps
                self.activityDate = AppDelegate.todayStartDate().yesterday.dateString()
                self.activityDateToSave = AppDelegate.todayStartDate().yesterday
            }
            else{
                self.activityDate = AppDelegate.todayStartDate().yesterday.dateString()
                self.activityDateToSave = AppDelegate.todayStartDate().yesterday
            }
        }
        tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
    }
    
    //TODO: remove this when done
    @IBAction func btnYesterday(_ sender : UIButton) {
        isTodaySelected = false
       // btnToday.setImage( UIImage.init(named: "radio"), for: .normal)
       // btnYesterday.setImage( UIImage.init(named: "radioSelected"), for: .normal)
        self.stepCount = 0
      //  self.activityCountValueLabel.text = "0"

        
        for i in 0..<Activity.allWithoutCountZero().count{
            

            
            if(resetTime(date: Activity.allWithoutCountZero()[i].date) == resetTime(date: AppDelegate.todayStartDate().addingTimeInterval(-60*60*24)) ){
               // self.activityCountValueLabel.text = "\(Activity.allWithoutCountZero()[i].steps)"
                self.stepCount = Activity.allWithoutCountZero()[i].steps
                self.activityDate = AppDelegate.todayStartDate().yesterday.dateString()
                self.activityDateToSave = AppDelegate.todayStartDate().yesterday
                self.tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
              //  self.makeYesterdayAllEntriesAsDetailedActivityString()
            }
            else{
            
                self.activityDate = AppDelegate.todayStartDate().yesterday.dateString()
                self.activityDateToSave = AppDelegate.todayStartDate().yesterday
            
            }
        }
        
    }
    
    @IBAction func activityTypeBtnAction(_ sender : UIButton) {
        openActivityTypeForm()
    }
    
    func openActivityTypeForm() {
        if let nib = Bundle.main.loadNibNamed("ActivityTypesView", owner: self, options: nil) {
            var objActivityTypesView : ActivityTypesView? = nib[0] as? ActivityTypesView
            objActivityTypesView?.selectedActivities = (self.activityTypes).components(separatedBy: CharacterSet.init(charactersIn: ","))
            objActivityTypesView?.activitiesTableView.reloadData()
            self.view.addSubview(objActivityTypesView!)
            objActivityTypesView?.prepareForNewConstraints { (v) in
                v?.setLeadingSpaceFromSuperView(leadingSpace: 0)
                v?.setTrailingSpaceFromSuperView(trailingSpace: 0)
                v?.setTopSpaceFromSuperView(topSpace: 0)
                v?.setBottomSpaceFromSuperView(bottomSpace: 0)
            }
            objActivityTypesView?.SelectedActivityTypesCompletion = { selectedActivities in
                
                if let firstChar = selectedActivities.joined(separator: ",").first {
                    if firstChar == "," {
                        let trimmiedStr = selectedActivities.joined(separator: ",").dropFirst(1)
                        self.activityTypes = trimmiedStr.description
                    //    self.activityTypeLabel.text = trimmiedStr.description
                        self.tableView.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .automatic)
                    } else {
                        self.activityTypes = selectedActivities.joined(separator: ",")
                    //    self.activityTypeLabel.text = selectedActivities.joined(separator: ",")
                        self.tableView.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .automatic)
                    }
                } else {
                    self.activityTypes = ""
                  //  self.activityTypeLabel.text = ""
                    self.tableView.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .automatic)
                }
                objActivityTypesView?.selectedActivities.removeAll()
                objActivityTypesView?.removeFromSuperview()
                objActivityTypesView = nil
            }
        }
       
    }
    //TODO: remove this
    @IBAction func chooseFileBtnAction(_ sender: Any) {
        let imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
     func chooseFileBtnActionFromCell() {
        let imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func postToSteemitBtnAction(_ sender : UIButton) {
        //save user steemit credentials privately in local database
        self.saveOrUpdateUserCredentials()
        
        
        //settings default measurement system to metric
        var isDonatingToCharity = false
        var charityDisplayName = ""
        var charityName = ""
        
        var activityJson = [String : Any]()
        
        if let settings = self.settings {
            if settings.is100SPSelected {
                postPayout = "full_SP_Pay"
            } else if settings.isLiquidHBDSelected {
                postPayout = "liquid_Pay"
            } else if settings.isDeclinePayoutSelected {
                postPayout = "decline_Pay"
            } else if settings.isSbdSPPaySystemSelected {
                postPayout = "50_50_SBD_SP_Pay"
            } else {
                postPayout = "full_SP_Pay"
            }
            //send charity_name if is donating to charity and charity name is not empty
            if settings.isDonatingCharity {
                charityDisplayName = settings.charityDisplayName
                charityName = settings.charityName
            }
            if !(charityName.isEmpty) {
                activityJson[PostKeys.charity] = charityName
            }
            //updating from saved settings
            isDonatingToCharity = settings.isDonatingCharity && !(charityName.isEmpty)
        }
        
        if isDonatingToCharity {
            self.showAlertWith(title: nil, message: Messages.current_workout_going_charity + charityDisplayName + " based on your settings choice. Are you sure you want to proceed?", okActionTitle: "YES", cancelActionTitle: "NO", okClickedCompletion: { (okClicked) in
                self.proceeedPostingWith(json: activityJson)
            }) { (cancelClicked) in
                //do nothing
            }
        } else {
            self.proceeedPostingWith(json: activityJson)
        }
    }
    
    func resetTime(date: Date) -> Date{
        let currentDate = date.setTime(hour: 00, min: 00, sec: 00)!
       // let newDate = currentDate
       // let timezoneOffset =  TimeZone.current.secondsFromGMT()
       // let epochDate = newDate.timeIntervalSince1970
        //let timezoneEpochOffset = (epochDate + Double(timezoneOffset))
       // currentDate = Date(timeIntervalSince1970: timezoneEpochOffset)
        return currentDate
    }
    
    //TODO: replace 621 till 267
    func proceeedPostingWith(json : [String : Any]) {
        let content: String = UserDefaults.standard.value(forKey: "postcontent") as! String
        var activityJson = json
        
        
        // check minimum steps count required to post the activity
        var stepsCount: Int? = 0
        
        if isFitBitCount {
            stepsCount = fitBitStepCount
            activityJson[PostKeys.dataTrackingSource] = "Fitbit Tracking"
            ishealthStoreCount = false
            isFitBitCount = false
            
        }
        else if ishealthStoreCount{
            stepsCount = self.stepCount
            activityJson[PostKeys.dataTrackingSource] = "healthapp"
            isFitBitCount = false
            ishealthStoreCount = false
            
        }
        else if let activity = Activity.allWithoutCountZero().first(where: {resetTime(date: $0.date) == resetTime(date: AppDelegate.todayStartDate())}){//else if let activity = Activity.allWithoutCountZero().first(where: {$0.date == AppDelegate.todayStartDate()}) {
//            stepsCount = activity.steps
            ishealthStoreCount = false
            isFitBitCount = false
            stepsCount = self.stepCount
            activityJson[PostKeys.dataTrackingSource] = "Device Tracking"
            activityJson[PostKeys.fitbitUserId] = ""
        }
        
        if stepsCount! < PostMinActivityStepsCount {
            self.showAlertWith(title: nil, message: Messages.min_activity_steps_count_error + "\(PostMinActivityStepsCount) " + "activity yet.")
            return
        }
        
        let contentText = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if contentText.count < PostContentMinCharsCount {
            self.showAlertWith(title: nil, message: Messages.min_word_count_error + "\(PostContentMinCharsCount) " + Messages.characters_plural_label)
            return
        }
        
        //check is user has not selected any activity from the dropdown
        //
        var activityType = self.activityTypes.replacingOccurrences(of: "Activity Type,", with: "")
        activityType = activityType.replacingOccurrences(of: "Activity Type", with: "")
        
        if activityType == "" {
            self.showAlertWith(title: nil, message: Messages.error_need_select_one_activity )
            return
        }
        
        
        let userName = User.current()?.steemit_username.byTrimming(string: "@").lowercased()
        let privatePostingKey = User.current()?.private_posting_key
        activityJson[PostKeys.author] = userName
        activityJson[PostKeys.posting_key] = privatePostingKey
        activityJson[PostKeys.title] =  self.defaultPostTitle
        activityJson[PostKeys.content] = content
        activityJson[PostKeys.tags] = self.tagsString()
        activityJson[PostKeys.step_count] = stepsCount
        activityJson[PostKeys.activity_type] = activityType
        //
        activityJson[PostKeys.height] = measurmentKeys[PostKeys.height] ?? "" // self.heightTextField.text ?? ""
        activityJson[PostKeys.weight] = measurmentKeys[PostKeys.weight] ?? ""//self.weightTextField.text ?? ""
        activityJson[PostKeys.chest] =  measurmentKeys[PostKeys.chest] ?? ""//self.chestTextField.text ?? ""
        activityJson[PostKeys.waist] =  measurmentKeys[PostKeys.waist] ?? ""//self.waistTextField.text ?? ""
        activityJson[PostKeys.thigs] =  measurmentKeys[PostKeys.thigs] ?? ""//self.thighTextField.text ?? ""
        activityJson[PostKeys.bodyfat] = measurmentKeys[PostKeys.bodyfat] ?? ""//self.bodyFatTextField.text ?? ""
        //
        activityJson[PostKeys.activityDate] = self.activityDate.replacingOccurrences(of: "-", with: "")
        activityJson[PostKeys.detailedActivity] = self.detailedActivityStepsDataString
        if authenticationController?.fitBitUserId != "" && authenticationController?.fitBitUserId != nil{
            SHA512Conversion(fitbitId: (authenticationController?.fitBitUserId)!)
            activityJson[PostKeys.fitbitUserId] = encyptedFitBit
        }
        else{
            activityJson[PostKeys.fitbitUserId] = ""
        }
        
        if isMaxiToken{
            activityJson[PostKeys.fullafitpay] = "on"
        }
        //var isSBDPayment = false
        
        
            //let status = UserDefaults.standard.bool(forKey: "isSbdSPPaySystemSelected")
            //if status{
               // activityJson[PostKeys.reportSTEEMPayMode] = "full_SP_Pay"
            //}else{
        activityJson[PostKeys.reportSTEEMPayMode] = postPayout
            //}
        
        
//        if !isSBDPayment{
//            activityJson[PostKeys.reportSTEEMPayMode] = "half_SP_Pay"
//        }else{
//            activityJson[PostKeys.reportSTEEMPayMode] = "full_SP_Pay"
//        }
        
        activityJson[PostKeys.actifitUserID] = UserDefaults.standard.string(forKey: "actifitUserID") ?? ""
        var measurementSystem = MeasurementSystem.metric.rawValue
        if let settings = self.settings {
            measurementSystem = settings.measurementSystem
        }
        activityJson[PostKeys.weightUnit] = measurementSystem == MeasurementSystem.metric.rawValue ? MeasurementUnit.metric.kg : MeasurementUnit.us.lb
        activityJson[PostKeys.heightUnit] = measurementSystem == MeasurementSystem.metric.rawValue ? MeasurementUnit.metric.kg : MeasurementUnit.us.lb
        activityJson[PostKeys.chestUnit] = measurementSystem == MeasurementSystem.metric.rawValue ? MeasurementUnit.metric.cm : MeasurementUnit.us.inch
        activityJson[PostKeys.waistUnit] = measurementSystem == MeasurementSystem.metric.rawValue ? MeasurementUnit.metric.cm : MeasurementUnit.us.inch
        activityJson[PostKeys.thighsUnit] = measurementSystem == MeasurementSystem.metric.rawValue ? MeasurementUnit.metric.cm : MeasurementUnit.us.inch
        
//        self.weightUnitLabel.text = measurementSystem == MeasurementSystem.metric.rawValue ? MeasurementUnit.metric.kg : MeasurementUnit.us.lb
//
//        self.heightUnitLabel.text = measurementSystem == MeasurementSystem.metric.rawValue ? MeasurementUnit.metric.cm : MeasurementUnit.us.ft
//
//        self.chestUnitLabel.text = measurementSystem == MeasurementSystem.metric.rawValue ? MeasurementUnit.metric.cm : MeasurementUnit.us.inch
//
//        self.waistUnitLabel.text = measurementSystem == MeasurementSystem.metric.rawValue ? MeasurementUnit.metric.cm : MeasurementUnit.us.inch
//
//        self.thighsUnitLabel.text = measurementSystem == MeasurementSystem.metric.rawValue ? MeasurementUnit.metric.cm : MeasurementUnit.us.inch
        activityJson[PostKeys.appType] = AppType
        activityJson[PostKeys.appVersion] = UIApplication.appVersion
        self.postActvityWith(json: activityJson)
    }
    
    @IBAction func maxiTokenBtnAction(_ sender : UIButton) {
        sender.isSelected = !sender.isSelected
        self.isMaxiToken = sender.isSelected
       // self.maxiToken.layer.borderColor = sender.isSelected ? UIColor.clear.cgColor :  UIColor.darkGray.cgColor
        //self.maxiToken.layer.borderWidth = sender.isSelected ? 0.0 : 2.0
        if sender.isSelected {
          //  self.maxiToken.setImage(#imageLiteral(resourceName: "check").withRenderingMode(.alwaysTemplate), for: .normal)
            //self.maxiToken.tintColor = ColorTheme
        } else {
            //self.maxiToken.setImage(nil, for: .normal)
        }
    }
    //TODO: delete this
    @IBAction func fitBitBtnAction(_ sender: Any) {
    
         let alert = UIAlertController(title: "Sync your data from", message: "Please Select an Option", preferredStyle: .actionSheet)

           alert.addAction(UIAlertAction(title: "Fitbit", style: .default , handler:{ (UIAlertAction)in
               print("User click Fitbit button")
            self.authenticationController = AuthenticationController(delegate: self)
            self.authenticationController?.login(fromParentViewController: self)
           }))

           alert.addAction(UIAlertAction(title: "Watch/Health App", style: .default , handler:{ (UIAlertAction)in
               print("User click Watch button")
            self.getHealthKitPermission()
           }))

           alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{ (UIAlertAction)in
               print("User click Dismiss button")
           }))

           self.present(alert, animated: true, completion: {
               print("completion block")
           })
    }
    
    func fitBitAction() {
        let alert = UIAlertController(title: "Sync your data from", message: "Please Select an Option", preferredStyle: .actionSheet)

          alert.addAction(UIAlertAction(title: "Fitbit", style: .default , handler:{ (UIAlertAction)in
             
           self.authenticationController = AuthenticationController(delegate: self)
           self.authenticationController?.login(fromParentViewController: self)
          }))

          alert.addAction(UIAlertAction(title: "Watch/Health App", style: .default , handler:{ (UIAlertAction)in
            
           self.getHealthKitPermission()
          }))

          alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{ (UIAlertAction)in
            
          }))

          self.present(alert, animated: true, completion: {
             
          })
    }
    
    @IBAction func watchBtnAction(_ sender: Any) {
        print("Watch button pressed")
        
    }
    
    @IBAction func videoBtn(_ sender: Any) {
        let url = URL(string: "https://d.tube/#!/v/raserrano/h7rze7he")!
        let controller = SFSafariViewController(url: url)
        self.present(controller, animated: true, completion: nil)
        controller.delegate = self
    }
    //MARK: HELPERS
    
    func getHealthKitPermission() {

            guard HKHealthStore.isHealthDataAvailable() else {
                print("Health kit is unavailable")
                return
            }

            let stepsCount = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
            
            self.healthStore.requestAuthorization(toShare: [], read: [stepsCount]) { (success, error) in
                if success {
                    print("Permission accept.")
                    self.retrieveStepCount { (steps) in
                        print("Steps Retrived :", steps)
                        DispatchQueue.main.async{
                            self.ishealthStoreCount = true
                            self.stepCount = Int(steps)
                            self.tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
                         //   self.activityCountValueLabel.text =  String(describing: Int(steps))//String(describing: steps)
                        }
                    }
                }
                else {
                    if error != nil {
                        print(error ?? "")
                    }
                    print("Permission denied.")
                }
            }
    }
    
    func retrieveStepCount(completion: @escaping (_ stepRetrieved: Double) -> Void) {
        var startFrom = Date()
        var endUpto = Date()
        
        if isTodaySelected{
            startFrom = Calendar.current.startOfDay(for: Date())
            endUpto = Date()
        }else{
            startFrom = self.resetTime(date: AppDelegate.todayStartDate().addingTimeInterval(-60*60*24))
            endUpto = Calendar.current.startOfDay(for: Date())
        }
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let predicate = HKQuery.predicateForSamples(withStart: startFrom, end: endUpto, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()))
        }
        healthStore.execute(query)
    }
    
    
    func applyFinishingTouchToUIElements() {
        self.showMeasurementUnits()
      //  postContentTextView.layer.borderColor = UIColor.lightGray.cgColor
      //  postContentTextView.layer.borderWidth = 1.0
       // postContentTextView.layer.cornerRadius = 4.0
        
       // self.postContentTextView.clipsToBounds = true
      //  self.postTagsTextView.text = ""
       // self.postTitleTextView.text = defaultPostTitle
       // self.postToSteemitBtn.layer.cornerRadius = 4.0
       // self.postTitleTextView.delegate = self
       // self.postTagsTextView.delegate = self
      //  self.postContentTextView.delegate = self
        
        self.backBtn.setImage(#imageLiteral(resourceName: "back_black").withRenderingMode(.alwaysTemplate), for: .normal)
        self.backBtn.tintColor = UIColor.white
        //self.postTitleTextView.heightConstraint = self.postTitleTextViewHeightConstraint
       // self.postTagsTextView.heightConstraint = self.postTagsTextViewHeightConstraint
        
       // self.maxiToken.layer.borderColor = UIColor.darkGray.cgColor
       // self.maxiToken.layer.borderWidth = 2.0
       // self.maxiToken.layer.cornerRadius = 2.0
    }
    
    func showMeasurementUnits() {
        var measurementSystem = MeasurementSystem.metric.rawValue
        if let settings = self.settings {
            measurementSystem = settings.measurementSystem
        }
//        self.weightUnitLabel.text = measurementSystem == MeasurementSystem.metric.rawValue ? MeasurementUnit.metric.kg : MeasurementUnit.us.lb
//
//        self.heightUnitLabel.text = measurementSystem == MeasurementSystem.metric.rawValue ? MeasurementUnit.metric.cm : MeasurementUnit.us.ft
//
//        self.chestUnitLabel.text = measurementSystem == MeasurementSystem.metric.rawValue ? MeasurementUnit.metric.cm : MeasurementUnit.us.inch
//
//        self.waistUnitLabel.text = measurementSystem == MeasurementSystem.metric.rawValue ? MeasurementUnit.metric.cm : MeasurementUnit.us.inch
//
//        self.thighsUnitLabel.text = measurementSystem == MeasurementSystem.metric.rawValue ? MeasurementUnit.metric.cm : MeasurementUnit.us.inch
    }
    
    //TODO: get access to tag string
    func tagsString() -> String {
        let tagsString = tagsFromCell.trimmingCharacters(in: .whitespacesAndNewlines)
        // self.postTagsTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var tagComponents = [String]()
        
        if !tagsString.isEmpty {
            if tagsString.contains(find: ",") {
                tagComponents = tagsString.components(separatedBy: ",")
            } else {
                tagComponents = tagsString.components(separatedBy: " ")
            }
            if tagComponents.contains("actifit") {
                tagComponents = tagComponents.filter({$0 == "actifit"})
            }
            if tagComponents.contains("Actifit") {
                tagComponents = tagComponents.filter({$0 == "Actifit"})
            }
            let string = tagComponents.joined(separator: " ")
            var trimmedString = NSString.init(string: string).replacingOccurrences(of: "Actifit", with: "")
            trimmedString = trimmedString.replacingOccurrences(of: "actifit", with: "")
            tagComponents = trimmedString.components(separatedBy: CharacterSet.init(charactersIn: " "))
        }
        tagComponents.insert(("actifit"), at: 0)
        let newTagString = tagComponents.joined(separator: " ")
        return newTagString
    }
    
    func saveOrUpdateUserCredentials() {
       // let userName = (self.steemitUsernameTextField.text ?? "").byTrimming(string: "@").lowercased()
        //let privatePostingKey = self.steemitPostingPrivateKeyTextField.text ?? ""
        
     //   UserDefaults.standard.set(userName, forKey: "currentUserName")
       // UserDefaults.standard.set(privatePostingKey, forKey: "currentUserPrivateKey")
        UserDefaults.standard.synchronize()
        
      //  if let currentUser = self.currentUser {
            //update user saved username and private posting key
//            if let user = self.currentUser, user.steemit_username != userName {
//                UserDefaults.standard.set(nil, forKey:"rank")
//            }
//            currentUser.updateUser(steemit_username: currentUser.steemit_username, private_posting_key: currentUser.private_posting_key, last_post_date : currentUser.last_post_date)
//        } else {
//            //save user username and private posting key
//            User.saveWith(info: [UserKeys.steemit_username : self.currentUser?.steemit_username, UserKeys.private_posting_key : self.currentUser?.steemit_username, UserKeys.last_post_date : Date().yesterday]) //save user last post date atleat before today because if the post fails, the user can atlease post next time today.
//        }
       // self.currentUser = User.current()
      //  UserDefaults.standard.set(self.steemitUsernameTextField.text, forKey: "username")
    }
    
    func todayDateStringWithFormat(format : String) -> String {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = NSTimeZone.local
        return dateFormatter.string(from: Date())
    }
    
    
    // SHA 512 for fitbit ID encryption
    func SHA512Conversion(fitbitId:String) {
        guard let data = fitbitId.data(using: .utf8) else { return }
     
            let digest = SHA512.hash(data: data)
            print(digest.data) 
            print(digest.hexStr) 
            encyptedFitBit = digest.hexStr
       
       
    }
   

    
    @objc func appMovedToForeground() {
        if let activity = Activity.allWithoutCountZero().first(where: {$0.date == AppDelegate.todayStartDate()}) {
            self.stepCount = activity.steps
         //   self.activityCountValueLabel.text = "\(activity.steps)"
        }
        self.defaultPostTitle = "\(Messages.default_post_title)\(todayDateStringWithFormat(format: "MMMM d yyyy"))"
    }
    
    @objc func toDayStepsUpdated(notification : NSNotification) {
        if let userInfo = notification.userInfo {
            if let steps = userInfo["steps"] as? Int {
                self.stepCount = steps
               // self.activityCountValueLabel.text = "\(steps)"
                self.tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
            }
        }
    }
    
    //MARK: WEB SERVICES
    
    func postActvityWith(json : [String : Any]) {
        ActifitLoader.show(title: Messages.sending_post, animated: true)
        APIMaster.postActvityWith(info: json, completion: { [weak self] (json, status ) in
//            DispatchQueue.main.async(execute: {
//                ActifitLoader.hide()
//            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                if let jsonString = json as? String {
                    if jsonString == "success" {
                        DispatchQueue.main.async(execute: {
                            ActifitLoader.showLoaderStatusImage(sourceVC: self, navigateBack: true , success: true, status: Messages.success_post)
                            ActifitLoader.delegate = self
                        })
                        //update user last post time interval
                        UserDefaults.standard.set("", forKey: "postcontent")
                        if let currentUser =  User.current() {
                            currentUser.updateUser(steemit_username: currentUser.steemit_username, private_posting_key: currentUser.private_posting_key, last_post_date: self?.activityDateToSave ?? Date())
                            
                        }
//                        self?.showAlertWithOkCompletion(title: nil, message: Messages.success_post, okClickedCompletion: { (COM) in
//                            self?.navigationController?.popViewController(animated: true)
//                        })
                    } else {
                        //if post fails then jsonString will contain error message to show to user
//                        self?.showAlertWith(title: nil, message: jsonString)
                        ActifitLoader.showLoaderStatusImage(sourceVC: self, success: false, status: jsonString)
                    }
                } else {
                    ActifitLoader.showLoaderStatusImage(sourceVC: self, success: false, status: Messages.failed_post)
//                    self?.showAlertWith(title: nil, message: Messages.failed_post)
                }
            })
        }) { (error) in
            DispatchQueue.main.async(execute: {
                ActifitLoader.showLoaderStatusImage(sourceVC: self, success: false, status: error.localizedDescription)
//                ActifitLoader.hide()
            })
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
//                self.showAlertWith(title: nil, message: error.localizedDescription)
//            })
        }
    }
    
}


extension Digest {
    var bytes: [UInt8] { Array(makeIterator()) }
    var data: Data { Data(bytes) }

    var hexStr: String {
        bytes.map { String(format: "%02X", $0) }.joined()
    }
}

extension Date {
    var ticks: UInt64 {
        return UInt64((self.timeIntervalSince1970 + 62_135_596_800) * 10_000_000)
    }
}

extension PostToSteemitVC: AuthenticationProtocol {
    func authorizationDidFinish(_ success: Bool) {
        print("Hello World with \(success)!")
        guard let authToken = authenticationController?.authenticationToken else {
            return
        }
        FitbitAPI.sharedInstance.authorize(with: authToken)
        let _ = StepStat.fetchTodaysStepStat(forDate: self.activityDateToSave) { [weak self] stepStat, error in
            let steps = stepStat?.steps ?? 0
            print(steps)
            self?.isFitBitCount = true
            self?.fitBitStepCount = Int(steps)
          //  self?.activityCountValueLabel.text = "\(steps)"
            self?.stepCount = Int(steps)
            self?.tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
            
        }
        var fetchMeasurments = false
        
        if let settings = self.settings {
            fetchMeasurments = settings.fitBitMeasurement
            print(settings.fitBitMeasurement)
        }
     
        if fetchMeasurments {
            let _ = StepStat.fetchUser() { [weak self] userStat, error in
                
               // self?.heightTextField.text =
                self?.measurmentKeys.updateValue("\(userStat!["height"] as! NSNumber)", forKey: PostKeys.height)
                self?.measurmentKeys.updateValue("\(userStat!["weight"] as! NSNumber)", forKey: PostKeys.weight)
                self?.tableView.reloadRows(at: [IndexPath(row: 4, section: 0)], with: .automatic)
               // self?.weightTextField.text = "\(userStat!["weight"] as! NSNumber)"
            }
        }
    }
    private func openInfoScreen() {
        let vc = TransparentPopupViewController.create(title: NSLocalizedString("minimum_characters_required_title", comment: ""), description:  NSLocalizedString("minimum_characters_required_description", comment: ""), cancelButtonText: NSLocalizedString("close_upper", comment: ""), noteSize: .small)
        present(vc, animated: true)
    }
}

// MARK: Safari Delegate
extension PostToSteemitVC : SFSafariViewControllerDelegate{
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
// MARK: UIImagePickerControllerDelegate
extension PostToSteemitVC : UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            uploadData(image: image)
        }
    }
}


extension PostToSteemitVC : SwiftLoaderDismissDelegate{
    func loaderSetToHidden(goBack: Bool) {
        print("Go Back Called")
        if goBack{
            self.navigationController?.popViewController(animated: true)
        }
    }
}


extension PostToSteemitVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reportTitleCell = tableView.dequeueReusableCell(withIdentifier: "ReprotTitleCell") as? ReprotTitleCell
        let actvityDateCell = tableView.dequeueReusableCell(withIdentifier: "ActivityDateCell") as? ActivityDateCell
       
        let activityCountCell = tableView.dequeueReusableCell(withIdentifier: "ActivityCountCell") as? ActivityCountCell
        
        let activityTypeCell =  tableView.dequeueReusableCell(withIdentifier: "ActivityTypesCell") as? ActivityTypesCell
        let measurementCell = tableView.dequeueReusableCell(withIdentifier: "TrackMeasurementsCell") as? TrackMeasurementsCell
        measurementCell?.measurementDelegate = self
        let reportTagCell =  tableView.dequeueReusableCell(withIdentifier: "ReportTagsCell") as? ReportTagsCell
        reportTagCell?.tagsChangedDelegate = self
        let reportPreviewCell = tableView.dequeueReusableCell(withIdentifier: "ReportContentCell") as? ReportContentCell
        
        reportTitleCell?.selectionStyle = .none
        actvityDateCell?.selectionStyle = .none
        activityCountCell?.selectionStyle = .none
        activityTypeCell?.selectionStyle = .none
        measurementCell?.selectionStyle = .none
        reportTagCell?.selectionStyle = .none
        reportPreviewCell?.selectionStyle = .none
        switch indexPath.row {
        case 0:
          
            reportTitleCell?.reportTitle = defaultPostTitle
            reportTitleCell?.delegate = self
            return reportTitleCell!
            
        case 1:
            
            actvityDateCell?.onTodayTapped = {[weak self] in
                self?.btnTodayTapped()
            }
            
            actvityDateCell?.onYesterdayTapped = { [weak self] in
                self?.btnYesterdayTapped()
            }
            return actvityDateCell!
        case 2:
            activityCountCell?.numberOfSteps = stepCount
            activityCountCell?.onFitbitTapped = {[weak self] in
                self?.fitBitAction()
            }
            return activityCountCell!
        case 3:
            activityTypeCell?.changeColorDetector = (self.activityTypes == "" || self.activityTypes == "Activity Type")
            activityTypeCell?.activityTypeSelected = {[weak self] in
                self?.openActivityTypeForm()
                
            }
            activityTypeCell?.activitiesSelected =  self.activityTypes == "" ? "Aerobic" : self.activityTypes
            return activityTypeCell!
        case 4:
            measurementCell?.measurementDelegate = self
            if !measurmentKeys.isEmpty {
                measurementCell?.measurements = self.measurmentKeys
            }
            return measurementCell!
        case 5: return reportTagCell!
        case 6:
            let content = UserDefaults.standard.string(forKey: "postcontent")
            if content == "" || content == nil {
               // reportPreviewCell?.previewContentTextField.text = randomHints[randomIndex ?? 0]
            } else {
                reportPreviewCell?.imageUpdates = self.updatedpostContent
            }
            reportPreviewCell?.onInfoBtnTapped = {[weak self] in
                self?.openInfoScreen()
            }
            reportPreviewCell?.onOpenAlbumTapped =  { [weak self] in
                self?.chooseFileBtnActionFromCell()
            }
            return reportPreviewCell!
//
        default: return UITableViewCell()
        }
    }
}

extension PostToSteemitVC: ReportTagCellDelegate {
    func tagsChanged(_ text: String?, in cell: ReportTagsCell) {
        tagsFromCell = text ?? "" //  print(text)
    }
    
    
}

extension PostToSteemitVC: TrackMeasurementCellDelegate {
    func measurementsDidChange(_ text: [String : String?]?, in cell: TrackMeasurementsCell) {
        if let key = text?.keys.first, let value = text?.values.first {
            measurmentKeys.updateValue(value!, forKey: key)
        }
    }
    
    
}
extension PostToSteemitVC: TitleChangeCellDelegate {
    func titleTextFieldDidChange(_ text: String?, in cell: ReprotTitleCell) {
        defaultPostTitle = text ?? ""
    }
    
    
}
