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

class PostToSteemitVC: UIViewController,UINavigationControllerDelegate {
    
    @IBOutlet weak var markdownContentLabel: UILabel!
    @IBOutlet weak var postContentLabel: UILabel!
    @IBOutlet weak var insertImageBtn: UIButton!
    @IBOutlet weak var reportImagesLabel: UILabel!
    @IBOutlet weak var reportTagsLabel: UILabel!
    @IBOutlet weak var chestLabel: UILabel!
    @IBOutlet weak var thighsLabel: UILabel!
    @IBOutlet weak var waistLabel: UILabel!
    @IBOutlet weak var bodyFatLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var trackMeasurementsLabel: UILabel!
    @IBOutlet weak var aerobicsBtn: UIButton!
    @IBOutlet weak var fitBitSyncBtn: UIButton!
    @IBOutlet weak var activityDateLabel: UILabel!
    @IBOutlet weak var maxAFITTokenLabel: UILabel!
    @IBOutlet weak var fullReportCardLabel: UILabel!
    @IBOutlet weak var reportTitleLabel: UILabel!
    @IBOutlet weak var helpmeFindPrivateKeyBtn: UIButton!
    @IBOutlet weak var steemPrivateKeyLabel: UILabel!
    @IBOutlet weak var steemUserNameLabel: UILabel!
    @IBOutlet weak var backBtn : UIButton!
    @IBOutlet weak var steemitUsernameTextField : AFTextField!
    @IBOutlet weak var steemitPostingPrivateKeyTextField : AFTextField!
    @IBOutlet weak var postTitleTextView : AFTextView!
    @IBOutlet weak var postTitleTextViewHeightConstraint : NSLayoutConstraint!
    @IBOutlet weak var activityCountLabel : UILabel!
    @IBOutlet weak var activityCountValueLabel: UILabel!
    @IBOutlet weak var activityTypeLabel : UILabel!
    @IBOutlet weak var heightTextField : AFTextField!
    @IBOutlet weak var weightTextField : AFTextField!
    @IBOutlet weak var bodyFatTextField : AFTextField!
    @IBOutlet weak var waistTextField : AFTextField!
    @IBOutlet weak var thighTextField : AFTextField!
    @IBOutlet weak var chestTextField : AFTextField!
    @IBOutlet weak var postTagsTextView : AFTextView!
    @IBOutlet weak var postTagsTextViewHeightConstraint : NSLayoutConstraint!
    @IBOutlet weak var postContentTextView : UITextView!
    @IBOutlet weak var postToSteemitBtn : UIButton!
    @IBOutlet weak var maxiToken : UIButton!
    @IBOutlet weak var postTitleTextViewLineLabel : UIView!
    @IBOutlet weak var postTagsTextViewLineLabel  : UIView!
    @IBOutlet weak var postContentTextViewLineLabel  : UIView!
    
    @IBOutlet weak var heightUnitLabel  : UILabel!
    @IBOutlet weak var weightUnitLabel  : UILabel!
    @IBOutlet weak var waistUnitLabel  : UILabel!
    @IBOutlet weak var thighsUnitLabel  : UILabel!
    @IBOutlet weak var chestUnitLabel  : UILabel!
    @IBOutlet weak var markDownEditorHeight: NSLayoutConstraint!
    @IBOutlet weak var markDOwnView: UIView!
    @IBOutlet weak var btnToday: UIButton!
    @IBOutlet weak var btnYesterday: UIButton!
    
    
    var authenticationController: AuthenticationController?
    var isFitBitCount = false
    var fitBitStepCount = 0
    var reportView: ReportPreView!
    var isMaxiToken = false
    lazy var currentUser = {
        return User.current()
    }()
    
    lazy var settings = {
           return Settings.current()
    }()
    
    var defaultPostTitle = ""
    var activityDate = ""
    var activityDateToSave = Date()
    var detailedActivityStepsDataString = ""
    
    //MARK: VIEW LIFE CYCLE
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let userName = UserDefaults.standard.string(forKey: "currentUserName")
        if userName  != nil{
            self.steemitUsernameTextField.text = userName
        }else{
            self.steemitUsernameTextField.text = ""
        }
        let userPrivateKey = UserDefaults.standard.string(forKey: "currentUserPrivateKey")
        if userPrivateKey  != nil{
            self.steemitPostingPrivateKeyTextField.text = userPrivateKey
        }else{
            self.steemitPostingPrivateKeyTextField.text = ""
        }
        
        
        AWSMobileClient.initialize()
        self.activityTypeLabel.text = ""
        self.defaultPostTitle = "\(Messages.default_post_title)\(todayDateStringWithFormat(format: "MMMM d yyyy"))"
        //show today activity steps count
       // AppDelegate.todayStartDate()
        let dd = Date().dayAfter()
       /* if let activity = Activity.allWithoutCountZero().first(where: {$0.date ==  AppDelegate.todayStartDate()}) {
            self.activityCountValueLabel.text = "\(activity.steps)"
        }*/
        
        for i in 0..<Activity.allWithoutCountZero().count{
            
//            if(Activity.allWithoutCountZero()[i].date.addingTimeInterval(-18000).dateString() == AppDelegate.todayStartDate().addingTimeInterval(-18000).dateString() ){
//                       self.activityCountValueLabel.text = "\(Activity.allWithoutCountZero()[i].steps)"
//                        self.activityDate = AppDelegate.todayStartDate().addingTimeInterval(-18000).dateString()
//                   }
            
            if let activity = Activity.allWithoutCountZero().first(where: {resetTime(date: $0.date)  ==  resetTime(date: AppDelegate.todayStartDate())}) {
                self.activityCountValueLabel.text = "\(activity.steps)"
                self.activityDate = AppDelegate.todayStartDate().dateString()
                self.activityDateToSave = AppDelegate.todayStartDate()
                self.makeTodayAllEnteriesAsDetailedActivityString()
            }
            
            
               }
        
        
        self.applyFinishingTouchToUIElements()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
       // notificationCenter.addObserver(self, selector: #selector(self.toDayStepsUpdated(notification:)), name: NSNotification.Name.init(StepsUpdatedNotification), object: nil)
        let content = UserDefaults.standard.string(forKey: "postcontent") ?? ""
        postContentTextView.text = content
        //postContentTextView.text = "5JeAQvwUdeuvZvSbvHW24r5jQrQ1kLXHcyn3Echqg6b2LkJHhhe5JeAQvwUdeuvZvSbvHW24r5jQrQ1kLXHcyn3Echqg6b2LkJHhhe5JeAQvwUdeuvZvSbvHW24r5jQrQ1kLXHcyn3Echqg6b2LkJHhhe5JeAQvwUdeuvZvSbvHW24r5jQrQ1kLXHcyn3Echqg6b2LkJHhhe5JeAQvwUdeuvZvSbvHW24r5jQrQ1kLXHcyn3Echqg6b2LkJHhhe5JeAQvwUdeuvZvSbvHW24r5jQrQ1kLXHcyn3Echqg6b2LkJHhhe5JeAQvwUdeuvZvSbvHW24r5jQrQ1kLXHcyn3Echqg6b2LkJHhhe5JeAQvwUdeuvZvSbvHW24r5jQrQ1kLXHcyn3Echqg6b2LkJHhhe"
        
        
        
        setUpMarkDownView()
        updateMarkDownView()
        btnToday.setImage( UIImage.init(named: "radioSelected"), for: .normal)
        // activityDate = dateformat(date: Date())
        print(activityDate)
        setupInitials()
    }
    
    func setupInitials()
    {
        steemUserNameLabel.text              = "steem_username_lbl".localized()
        steemPrivateKeyLabel.text            = "steem_pvt_posting_key".localized()
       // helpmeFindPrivateKeyBtn.titleLabel!.text              = "steem_username_lbl".localized()
        reportTitleLabel.text                = "report_title".localized()
        fullReportCardLabel.text             = "full_report_AFIT_pay".localized()
        maxAFITTokenLabel.text               = "full_AFIT_checkbox".localized()
        activityCountLabel.text              = "activity_count_lbl".localized()
       // fitBitSyncBtn.titleLabel!.text       = "fitbit_sync_btn_lbl".localized()
        activityTypeLabel.text               = "activity_type_lbl".localized()
        trackMeasurementsLabel.text          = "track_measurements_lbl".localized()
        heightLabel.text                     = "height_lbl".localized()
        weightLabel.text                     = "weight_lbl".localized()
        bodyFatLabel.text                    = "body_fat_lbl".localized()
        waistLabel.text                      = "waist_size_lbl".localized()
        thighsLabel.text                     = "thighs_size_lbl".localized()
        chestLabel.text                      = "chest_size_lbl".localized()
        reportTitleLabel.text                = "report_tags_lbl".localized()
        reportImagesLabel.text               = "report_images_lbl".localized()
       // insertImageBtn.titleLabel!.text      = "insert_img_btn_lbl".localized()
        postContentLabel.text                = "report_content_lbl".localized()
        markdownContentLabel.text            = "markdown_content_note".localized()
        
        self.fitBitSyncBtn.setTitle("fitbit_sync_btn_lbl".localized(), for: .normal)
        self.insertImageBtn.setTitle("insert_img_btn_lbl".localized(), for: .normal)
        self.postToSteemitBtn.setTitle("post_to_steem_btn_txt".localized(), for: .normal)

        
        
    }
    
    func setUpMarkDownView() {
        markDownEditorHeight.constant = 50
        updateViewConstraints()
        reportView =  ReportPreView()
        markDOwnView.addSubview(reportView)
        reportView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        notificationCenter.removeObserver(self, name: NSNotification.Name.init(StepsUpdatedNotification), object: nil)
        
    }
    
    func uploadData(image:UIImage) {
        ActifitLoader.show(title: "Uploading", animated: true)
        let data: Data =  UIImageJPEGRepresentation(image, 1)! //Data() //UIImageJPEGRepresentation(image, 1)!
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
                print(task)
                print("![](https://usermedia.actifit.io/\(filename))")
                var imgUrl = "![](https://usermedia.actifit.io/\(filename))"
                // double checking for correcting '//' in the imgurl
                imgUrl = imgUrl.replacingOccurrences(of: "io//", with: "io/")
                self.postContentTextView.text = self.postContentTextView.text + imgUrl
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
    
    func updateMarkDownView(){
        reportView.markView.load(markdown: postContentTextView.text)
        reportView.markView.onRendered = {
            [weak self] (height) in
            if let _ = self {
                print("onRendered height: \(height ?? 0)")
                self!.markDownEditorHeight.constant = height ?? 0
                self!.updateViewConstraints()
            }
        }
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
    
    
    func makeYesterdayAllEntriesAsDetailedActivityString()
    {
        self.detailedActivityStepsDataString = ""
        let date = resetTime(date: AppDelegate.todayStartDate().addingTimeInterval(-60*60*24))
        let allsavedRecordsOfHistory = AllRecordsOfActivitiesNew.all()
        let selectedDateHistory = allsavedRecordsOfHistory.filter({$0.date == date.dateString()})
        var activitiesDataList : [ActivityFifteenMinutesInterval] = []
        if selectedDateHistory.count > 0{
            if let anArrayOfPersonsRetrieved = NSKeyedUnarchiver.unarchiveObject(with: selectedDateHistory[0].activitiesListData) as? [ActivityFifteenMinutesInterval] {
                for activityObj in anArrayOfPersonsRetrieved{
                    let activity = ActivityFifteenMinutesInterval()
                    activity.id = Int(activityObj.idInString) ?? 0
                    activity.date = activityObj.date
                    activity.interval = activityObj.interval
                    activity.steps = Int(activityObj.stepsInString) ?? 0
                    if activity.steps > 0{
                        activitiesDataList.append(activity)
                    }
                }
                for activity in activitiesDataList{
                    let timeSlot = activity.interval.replacingOccurrences(of: ":", with: "")
                    let stepsInTimeSlot = String(activity.steps)
                    self.detailedActivityStepsDataString += timeSlot + stepsInTimeSlot + "|"
                }
            }
        }
    }
    
    
    
    //MARK: INTERFACE BUILDER ACTIONS
    
    @IBAction func backBtnAction(_ sender : UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnToday(_ sender : UIButton)
    {
        btnToday.setImage( UIImage.init(named: "radioSelected"), for: .normal)
        btnYesterday.setImage( UIImage.init(named: "radioOff"), for: .normal)
        //activityDate = dateformat(date: Date())
        self.activityCountValueLabel.text = "0"
        
        for i in 0..<Activity.allWithoutCountZero().count{
           
            //           if(Activity.allWithoutCountZero()[i].date.addingTimeInterval(-18000).dateString() == AppDelegate.todayStartDate().addingTimeInterval(-18000).dateString() ){
            //                    self.activityCountValueLabel.text = "\(Activity.allWithoutCountZero()[i].steps)"
            //                    self.activityDate = AppDelegate.todayStartDate().addingTimeInterval(-18000).dateString()
            //                }
            //        }
            
            if let activity = Activity.allWithoutCountZero().first(where: {resetTime(date: $0.date)  ==  resetTime(date: AppDelegate.todayStartDate())}) {
                self.activityCountValueLabel.text = "\(activity.steps)"
                self.activityDate = AppDelegate.todayStartDate().dateString()
                self.activityDateToSave = AppDelegate.todayStartDate()
                self.makeTodayAllEnteriesAsDetailedActivityString()
            }
        }
        
    }
    
    @IBAction func btnYesterday(_ sender : UIButton) {
        btnToday.setImage( UIImage.init(named: "radioOff"), for: .normal)
        btnYesterday.setImage( UIImage.init(named: "radioSelected"), for: .normal)
        //activityDate = dateformat(date: Date().dayBefor())
        
       // let date2 = Date().addingTimeInterval(-60*60*24)
        
      /*  if let activity = Activity.allWithoutCountZero().first(where: {resetTime(date: $0.date.addingTimeInterval(-60*60*24)) ==  resetTime(date: AppDelegate.todayStartDate().addingTimeInterval(-60*60*24))}) {
        self.activityCountValueLabel.text = "\(activity.steps)"
            
        }*/
        self.activityCountValueLabel.text = "0"

        
        for i in 0..<Activity.allWithoutCountZero().count{
            
//            if(Activity.allWithoutCountZero()[i].date.addingTimeInterval(-18000).dateString() == AppDelegate.todayStartDate().addingTimeInterval(-18000).addingTimeInterval(-60*60*24).dateString() ){
//                    self.activityCountValueLabel.text = "\(Activity.allWithoutCountZero()[i].steps)"
//                self.activityDate = AppDelegate.todayStartDate().addingTimeInterval(-18000).addingTimeInterval(-60*60*24).dateString()
//                }
//            }
            
            
            if(resetTime(date: Activity.allWithoutCountZero()[i].date) == resetTime(date: AppDelegate.todayStartDate().addingTimeInterval(-60*60*24)) ){
                self.activityCountValueLabel.text = "\(Activity.allWithoutCountZero()[i].steps)"
                self.activityDate = AppDelegate.todayStartDate().yesterday.dateString()
                self.activityDateToSave = AppDelegate.todayStartDate().yesterday
                self.makeYesterdayAllEntriesAsDetailedActivityString()
            }
        
        }
        
    }
    
    @IBAction func activityTypeBtnAction(_ sender : UIButton) {
        if let nib = Bundle.main.loadNibNamed("ActivityTypesView", owner: self, options: nil) {
            var objActivityTypesView : ActivityTypesView? = nib[0] as? ActivityTypesView
            objActivityTypesView?.selectedActivities = (self.activityTypeLabel.text ?? "").components(separatedBy: CharacterSet.init(charactersIn: ","))
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
                        self.activityTypeLabel.text = trimmiedStr.description
                    } else {
                        self.activityTypeLabel.text = selectedActivities.joined(separator: ",")
                    }
                } else {
                    self.activityTypeLabel.text = ""
                }
                objActivityTypesView?.selectedActivities.removeAll()
                objActivityTypesView?.removeFromSuperview()
                objActivityTypesView = nil
            }
        }
    }
    
    @IBAction func chooseFileBtnAction(_ sender: Any) {
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
    
    func proceeedPostingWith(json : [String : Any]) {
        var activityJson = json
        
        
        // check minimum steps count required to post the activity
        var stepsCount = 0
        if isFitBitCount {
            stepsCount = fitBitStepCount
            activityJson[PostKeys.dataTrackingSource] = "Fitbit Tracking"
            
        }else if let activity = Activity.allWithoutCountZero().first(where: {resetTime(date: $0.date) == resetTime(date: AppDelegate.todayStartDate())}){//else if let activity = Activity.allWithoutCountZero().first(where: {$0.date == AppDelegate.todayStartDate()}) {
//            stepsCount = activity.steps
            stepsCount = Int(self.activityCountValueLabel.text ?? "0") ?? 0
            activityJson[PostKeys.dataTrackingSource] = "Device Tracking"
        }
        
       /* if stepsCount < PostMinActivityStepsCount {
            self.showAlertWith(title: nil, message: Messages.min_activity_steps_count_error + "\(PostMinActivityStepsCount) " + "activity yet.")
            return
        }*/
        
        let contentText = (self.postContentTextView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if contentText.count < PostContentMinCharsCount {
            self.showAlertWith(title: nil, message: Messages.min_word_count_error + "\(PostContentMinCharsCount) " + Messages.characters_plural_label)
            return
        }
        
        //check is user has not selected any activity from the dropdown
        
        var activityType = self.activityTypeLabel.text?.replacingOccurrences(of: "Activity Type,", with: "") ?? ""
        activityType = activityType.replacingOccurrences(of: "Activity Type", with: "")
        
        if activityType == "" {
            self.showAlertWith(title: nil, message: Messages.error_need_select_one_activity )
            return
        }
        
        
        let userName = (self.steemitUsernameTextField.text ?? "").byTrimming(string: "@").lowercased()
        let privatePostingKey = self.steemitPostingPrivateKeyTextField.text ?? ""
        activityJson[PostKeys.author] = userName
        activityJson[PostKeys.posting_key] = privatePostingKey
        activityJson[PostKeys.title] = self.postTitleTextView.text.isEmpty ? self.defaultPostTitle : self.postTitleTextView.text
        activityJson[PostKeys.content] = self.postContentTextView.text
        activityJson[PostKeys.tags] = self.tagsString()
        activityJson[PostKeys.step_count] = stepsCount
        
        activityJson[PostKeys.activity_type] = activityType
        activityJson[PostKeys.height] = self.heightTextField.text ?? ""
        activityJson[PostKeys.weight] = self.weightTextField.text ?? ""
        activityJson[PostKeys.chest] =  self.chestTextField.text ?? ""
        activityJson[PostKeys.waist] =  self.waistTextField.text ?? ""
        activityJson[PostKeys.thigs] =  self.thighTextField.text ?? ""
        activityJson[PostKeys.bodyfat] = self.bodyFatTextField.text ?? ""
        activityJson[PostKeys.activityDate] = self.activityDate.replacingOccurrences(of: "-", with: "")
        activityJson[PostKeys.detailedActivity] = self.detailedActivityStepsDataString
        
        if isMaxiToken{
            activityJson[PostKeys.fullafitpay] = "on"
        }
        //var isSBDPayment = false
        
        
            let status = UserDefaults.standard.bool(forKey: "isSbdSPPaySystemSelected")
            if status{
                activityJson[PostKeys.reportSTEEMPayMode] = "full_SP_Pay"
            }else{
                activityJson[PostKeys.reportSTEEMPayMode] = "half_SP_Pay"
            }
        
        
//        if !isSBDPayment{
//            activityJson[PostKeys.reportSTEEMPayMode] = "half_SP_Pay"
//        }else{
//            activityJson[PostKeys.reportSTEEMPayMode] = "full_SP_Pay"
//        }
        
        activityJson[PostKeys.actifitUserID] = UserDefaults.standard.string(forKey: "actifitUserID") ?? ""
        activityJson[PostKeys.weightUnit] = self.weightUnitLabel.text!
        activityJson[PostKeys.heightUnit] = self.heightUnitLabel.text!
        activityJson[PostKeys.chestUnit] = self.chestUnitLabel.text!
        activityJson[PostKeys.waistUnit] = self.waistUnitLabel.text!
        activityJson[PostKeys.thighsUnit] = self.thighsUnitLabel.text!
        
        activityJson[PostKeys.appType] = AppType
        activityJson[PostKeys.appVersion] = UIApplication.appVersion
        self.postActvityWith(json: activityJson)
    }
    
    @IBAction func maxiTokenBtnAction(_ sender : UIButton) {
        sender.isSelected = !sender.isSelected
        self.isMaxiToken = sender.isSelected
        self.maxiToken.layer.borderColor = sender.isSelected ? UIColor.clear.cgColor :  UIColor.darkGray.cgColor
        self.maxiToken.layer.borderWidth = sender.isSelected ? 0.0 : 2.0
        if sender.isSelected {
            self.maxiToken.setImage(#imageLiteral(resourceName: "check").withRenderingMode(.alwaysTemplate), for: .normal)
            self.maxiToken.tintColor = ColorTheme
        } else {
            self.maxiToken.setImage(nil, for: .normal)
        }
    }
    
    @IBAction func fitBitBtnAction(_ sender: Any) {
        authenticationController = AuthenticationController(delegate: self)
        authenticationController?.login(fromParentViewController: self)
    }
    
    @IBAction func videoBtn(_ sender: Any) {
        let url = URL(string: "https://d.tube/#!/v/raserrano/h7rze7he")!
        let controller = SFSafariViewController(url: url)
        self.present(controller, animated: true, completion: nil)
        controller.delegate = self
    }
    //MARK: HELPERS
    
    func applyFinishingTouchToUIElements() {
        self.showMeasurementUnits()
        postContentTextView.layer.borderColor = UIColor.lightGray.cgColor
        postContentTextView.layer.borderWidth = 1.0
        postContentTextView.layer.cornerRadius = 4.0
        
        self.postContentTextView.clipsToBounds = true
        self.postTagsTextView.text = ""
        self.postTitleTextView.text = defaultPostTitle
        self.postToSteemitBtn.layer.cornerRadius = 4.0
        self.postTitleTextView.delegate = self
        self.postTagsTextView.delegate = self
        self.postContentTextView.delegate = self
        
        self.backBtn.setImage(#imageLiteral(resourceName: "back_black").withRenderingMode(.alwaysTemplate), for: .normal)
        self.backBtn.tintColor = UIColor.white
        self.postTitleTextView.heightConstraint = self.postTitleTextViewHeightConstraint
        self.postTagsTextView.heightConstraint = self.postTagsTextViewHeightConstraint
        
        self.maxiToken.layer.borderColor = UIColor.darkGray.cgColor
        self.maxiToken.layer.borderWidth = 2.0
        self.maxiToken.layer.cornerRadius = 2.0
    }
    
    func showMeasurementUnits() {
        var measurementSystem = MeasurementSystem.metric.rawValue
        if let settings = self.settings {
            measurementSystem = settings.measurementSystem
        }
        self.weightUnitLabel.text = measurementSystem == MeasurementSystem.metric.rawValue ? MeasurementUnit.metric.kg : MeasurementUnit.us.lb
        
        self.heightUnitLabel.text = measurementSystem == MeasurementSystem.metric.rawValue ? MeasurementUnit.metric.cm : MeasurementUnit.us.ft
        
        self.chestUnitLabel.text = measurementSystem == MeasurementSystem.metric.rawValue ? MeasurementUnit.metric.cm : MeasurementUnit.us.inch
        
        self.waistUnitLabel.text = measurementSystem == MeasurementSystem.metric.rawValue ? MeasurementUnit.metric.cm : MeasurementUnit.us.inch
        
        self.thighsUnitLabel.text = measurementSystem == MeasurementSystem.metric.rawValue ? MeasurementUnit.metric.cm : MeasurementUnit.us.inch
    }
    
    func tagsString() -> String {
        let tagsString = self.postTagsTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
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
        let userName = (self.steemitUsernameTextField.text ?? "").byTrimming(string: "@").lowercased()
        let privatePostingKey = self.steemitPostingPrivateKeyTextField.text ?? ""
        
        UserDefaults.standard.set(userName, forKey: "currentUserName")
        UserDefaults.standard.set(privatePostingKey, forKey: "currentUserPrivateKey")
        UserDefaults.standard.synchronize()
        
        if let currentUser = self.currentUser {
            //update user saved username and private posting key
            if let user = self.currentUser, user.steemit_username != userName{
                UserDefaults.standard.set(nil, forKey:"rank")
            }
            currentUser.updateUser(steemit_username: userName, private_posting_key: privatePostingKey, last_post_date : currentUser.last_post_date)
        } else {
            //save user username and private posting key
            User.saveWith(info: [UserKeys.steemit_username : userName, UserKeys.private_posting_key : privatePostingKey, UserKeys.last_post_date : Date().yesterday]) //save user last post date atleat before today because if the post fails, the user can atlease post next time today.
        }
        self.currentUser = User.current()
        UserDefaults.standard.set(self.steemitUsernameTextField.text, forKey: "username")
    }
    
    func todayDateStringWithFormat(format : String) -> String {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = NSTimeZone.local
        return dateFormatter.string(from: Date())
    }
    
    @objc func appMovedToForeground() {
        if let activity = Activity.allWithoutCountZero().first(where: {$0.date == AppDelegate.todayStartDate()}) {
            //self.activityCountValueLabel.text = "\(activity.steps)"
        }
        self.defaultPostTitle = "\(Messages.default_post_title)\(todayDateStringWithFormat(format: "MMMM d yyyy"))"
    }
    
    @objc func toDayStepsUpdated(notification : NSNotification) {
        if let userInfo = notification.userInfo {
            if let steps = userInfo["steps"] as? Int {
                self.activityCountValueLabel.text = "\(steps)"
            }
        }
    }
    
    //MARK: WEB SERVICES
    
    func postActvityWith(json : [String : Any]) {
        ActifitLoader.show(title: Messages.sending_post, animated: true)
        APIMaster.postActvityWith(info: json, completion: { [weak self] (json) in
            DispatchQueue.main.async(execute: {
                ActifitLoader.hide()
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                if let jsonString = json as? String {
                    if jsonString == "success" {
                        //update user last post time interval
                        UserDefaults.standard.set("", forKey: "postcontent")
                        if let currentUser =  User.current() {
                            currentUser.updateUser(steemit_username: currentUser.steemit_username, private_posting_key: currentUser.private_posting_key, last_post_date: self?.activityDateToSave ?? Date())
                            
                        }
                        self?.showAlertWithOkCompletion(title: nil, message: Messages.success_post, okClickedCompletion: { (COM) in
                            self?.navigationController?.popViewController(animated: true)
                        })
                    } else {
                        //if post fails then jsonString will contain error message to show to user
                        self?.showAlertWith(title: nil, message: jsonString)
                    }
                } else {
                    self?.showAlertWith(title: nil, message: Messages.failed_post)
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
    }
    
}

extension Date {
    var ticks: UInt64 {
        return UInt64((self.timeIntervalSince1970 + 62_135_596_800) * 10_000_000)
    }
}

extension PostToSteemitVC: AuthenticationProtocol{
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
            self?.activityCountValueLabel.text = "\(steps)"
            
        }
        var fetchMeasurments = false
        
        if let settings = self.settings {
            fetchMeasurments = settings.fitBitMeasurement
            print(settings.fitBitMeasurement)
        }
     
        if fetchMeasurments {
            let _ = StepStat.fetchUser() { [weak self] userStat, error in
                
                self?.heightTextField.text = "\(userStat!["height"] as! NSNumber)"
                self?.weightTextField.text = "\(userStat!["weight"] as! NSNumber)"
            }
        }
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
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        uploadData(image: image!)
    }
}
extension PostToSteemitVC : UITextViewDelegate {
    
    //MARK: UITextViewDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if let afTextView = (textView as? AFTextView) {
            if afTextView.isEqual(self.postTitleTextView) {
                self.postTitleTextViewLineLabel.backgroundColor = UIColor.red
            } else if afTextView.isEqual(self.postTagsTextView) {
                self.postTagsTextViewLineLabel.backgroundColor = UIColor.red
            } else if afTextView.isEqual(self.postContentTextView) {
                self.postContentTextViewLineLabel.backgroundColor = UIColor.red
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        UserDefaults.standard.set(textView.text, forKey: "postcontent")
        updateMarkDownView()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let afTextView = (textView as? AFTextView) {
            if afTextView.isEqual(self.postTitleTextView) {
                self.postTitleTextViewLineLabel.backgroundColor = UIColor.lightGray
            } else if afTextView.isEqual(self.postTagsTextView) {
                self.postTagsTextViewLineLabel.backgroundColor = UIColor.lightGray
            } else if afTextView.isEqual(self.postContentTextView) {
                self.postContentTextViewLineLabel.backgroundColor = UIColor.lightGray
            }
            updateMarkDownView()
        }
    }
}

extension PostToSteemitVC : UITextFieldDelegate {
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
}
