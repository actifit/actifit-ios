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

class PostToSteemitVC: UIViewController,UINavigationControllerDelegate {
    
    @IBOutlet weak var backBtn : UIButton!
    @IBOutlet weak var steemitUsernameTextField : AFTextField!
    @IBOutlet weak var steemitPostingPrivateKeyTextField : AFTextField!
    @IBOutlet weak var postTitleTextView : AFTextView!
    @IBOutlet weak var postTitleTextViewHeightConstraint : NSLayoutConstraint!
    @IBOutlet weak var activityCountLabel : UILabel!
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
    
    var reportView: ReportPreView!
    
    lazy var currentUser = {
        return User.current()
    }()
    
    lazy var settings = {
        return Settings.current()
    }()
    
    var defaultPostTitle = ""
    //MARK: VIEW LIFE CYCLE
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AWSMobileClient.initialize()
        self.activityTypeLabel.text = ""
        self.defaultPostTitle = "\(Messages.default_post_title)\(todayDateStringWithFormat(format: "MMMM d yyyy"))"
        //show today activity steps count
        if let activity = Activity.allWithoutCountZero().first(where: {$0.date == AppDelegate.todayStartDate()}) {
            self.activityCountLabel.text = "\(activity.steps)"
        }
        
        //show current user steemit username and private posting key
        if let currentUser = self.currentUser {
            self.steemitUsernameTextField.text = currentUser.steemit_username
            self.steemitPostingPrivateKeyTextField.text = currentUser.private_posting_key
        }
        
        self.applyFinishingTouchToUIElements()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.toDayStepsUpdated(notification:)), name: NSNotification.Name.init(StepsUpdatedNotification), object: nil)
        setUpMarkDownView()
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
                self.postContentTextView.text = self.postContentTextView.text + " ![](https://usermedia.actifit.io/\(filename))"
                self.updateMarkDownView()
            })
        }
        
        let transferUtility = AWSS3TransferUtility.default()
        transferUtility.uploadUsingMultiPart(data:data,
                                             bucket: "actifit",
                                             key:filename,
                                             contentType: "image/jpeg",
                                             expression: expression,
                                             completionHandler: completionHandler).continueWith {
                                                (task) -> AnyObject! in
                                                if let error = task.error {
                                                    print("Error: \(error.localizedDescription)")
                                                }
                                                
                                                if let _ = task.result {
                                                    print(task.result?.status)
                                                    
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
    //MARK: INTERFACE BUILDER ACTIONS
    
    @IBAction func backBtnAction(_ sender : UIButton) {
        self.navigationController?.popViewController(animated: true)
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
    
    func proceeedPostingWith(json : [String : Any]) {
        var activityJson = json
        
        // check minimum steps count required to post the activity
        var stepsCount = 0
        if let activity = Activity.allWithoutCountZero().first(where: {$0.date == AppDelegate.todayStartDate()}) {
            stepsCount = activity.steps
        }
        if stepsCount < PostMinActivityStepsCount {
            self.showAlertWith(title: nil, message: Messages.min_activity_steps_count_error + "\(PostMinActivityStepsCount) " + "activity yet.")
            return
        }
        
        let contentText = (self.postContentTextView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if contentText.count < PostContentMinCharsCount {
            self.showAlertWith(title: nil, message: Messages.min_word_count_error + "\(PostContentMinCharsCount) " + Messages.characters_plural_label)
            return
        }
        
        //check is user has not selected any activity from the dropdown
        if let selectedActivityTypes = self.activityTypeLabel.text {
            if selectedActivityTypes.isEmpty {
                self.showAlertWith(title: nil, message: Messages.error_need_select_one_activity )
                return
            }
        }
        
        activityJson[PostKeys.author] = self.currentUser?.steemit_username ?? ""
        activityJson[PostKeys.posting_key] = self.currentUser?.private_posting_key ?? ""
        activityJson[PostKeys.title] = self.postTitleTextView.text.isEmpty ? self.defaultPostTitle : self.postTitleTextView.text
        activityJson[PostKeys.content] = self.postContentTextView.text
        activityJson[PostKeys.tags] = self.tagsString()
        activityJson[PostKeys.step_count] = stepsCount
        activityJson[PostKeys.activity_type] = self.activityTypeLabel.text ?? ""
        activityJson[PostKeys.height] = self.heightTextField.text ?? ""
        activityJson[PostKeys.weight] = self.weightTextField.text ?? ""
        activityJson[PostKeys.chest] = self.chestTextField.text ?? ""
        activityJson[PostKeys.waist] = self.waistTextField.text ?? ""
        activityJson[PostKeys.thigs] = self.thighTextField.text ?? ""
        activityJson[PostKeys.bodyfat] = self.bodyFatTextField.text ?? ""
        
        activityJson[PostKeys.weightUnit] = self.weightUnitLabel.text!
        activityJson[PostKeys.heightUnit] = self.heightUnitLabel.text!
        activityJson[PostKeys.chestUnit] = self.chestUnitLabel.text!
        activityJson[PostKeys.waistUnit] = self.waistUnitLabel.text!
        activityJson[PostKeys.thighsUnit] = self.thighsUnitLabel.text!
        
        activityJson[PostKeys.appType] = AppType
        activityJson[PostKeys.appVersion] = CurrentAppVersion
        self.postActvityWith(json: activityJson)
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
        
        if let currentUser = self.currentUser {
            //update user saved username and private posting key
            currentUser.updateUser(steemit_username: userName, private_posting_key: privatePostingKey, last_post_date : currentUser.last_post_date)
        } else {
            //save user username and private posting key
            User.saveWith(info: [UserKeys.steemit_username : userName, UserKeys.private_posting_key : privatePostingKey, UserKeys.last_post_date : Date().yesterday]) //save user last post date atleat before today because if the post fails, the user can atlease post next time today.
        }
        self.currentUser = User.current()
    }
    
    func todayDateStringWithFormat(format : String) -> String {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = NSTimeZone.local
        return dateFormatter.string(from: Date())
    }
    
    @objc func appMovedToForeground() {
        if let activity = Activity.allWithoutCountZero().first(where: {$0.date == AppDelegate.todayStartDate()}) {
            self.activityCountLabel.text = "\(activity.steps)"
        }
        self.defaultPostTitle = "\(Messages.default_post_title)\(todayDateStringWithFormat(format: "MMMM d yyyy"))"
    }
    
    @objc func toDayStepsUpdated(notification : NSNotification) {
        if let userInfo = notification.userInfo {
            if let steps = userInfo["steps"] as? Int {
                self.activityCountLabel.text = "\(steps)"
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
                        if let currentUser =  User.current() {
                            currentUser.updateUser(steemit_username: currentUser.steemit_username, private_posting_key: currentUser.private_posting_key, last_post_date: Date())
                            
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
