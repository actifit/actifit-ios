//
//  SettingsVC.swift
//  Actifit
//
//  Created by Hitender kumar on 20/08/18.
//  Copyright © 2018 actifit.io. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {

    @IBOutlet weak var backBtn : UIButton!
    @IBOutlet weak var metricMeasurementSystemBtn : UIButton!
    @IBOutlet weak var USMeasurementSystemBtn : UIButton!
    @IBOutlet weak var deviceSensortSystemBtn : UIButton!
    @IBOutlet weak var fitBitSystemBtn : UIButton!
    @IBOutlet weak var fullPaySystemBtn : UIButton!
    @IBOutlet weak var sbdSPPaySystemBtn : UIButton!
    
    @IBOutlet weak var donateTopCharityBtn : UIButton!
    @IBOutlet weak var metricDotView : UIView!
    @IBOutlet weak var usDotView : UIView!
    
    @IBOutlet weak var deviceSensorDotView : UIView!
    @IBOutlet weak var fitBitDotView : UIView!
    
    @IBOutlet weak var fullPayDotView : UIView!
    @IBOutlet weak var sbdSPPayDotView : UIView!
    
    @IBOutlet weak var charityLinkTextView : UITextView!
    @IBOutlet weak var saveSettingsBtn : UIButton!
    @IBOutlet weak var showCharityBtn : UIButton!
    
    @IBOutlet weak var metricMeasurementSystemBtnDotViewWidthConstraint : NSLayoutConstraint!
    @IBOutlet weak var metricMeasurementSystemBtnDotViewHeightConstraint : NSLayoutConstraint!
    @IBOutlet weak var USMeasurementSystemBtnDotViewWidthConstraint  : NSLayoutConstraint!
    @IBOutlet weak var USMeasurementSystemBtnDotViewHeightConstraint  : NSLayoutConstraint!

    @IBOutlet weak var deviceSensorSystemBtnDotViewWidthConstraint : NSLayoutConstraint!
    @IBOutlet weak var deviceSensorSystemBtnDotViewHeightConstraint : NSLayoutConstraint!
    @IBOutlet weak var fitBitSystemBtnDotViewWidthConstraint  : NSLayoutConstraint!
    @IBOutlet weak var fitBitSystemBtnDotViewHeightConstraint  : NSLayoutConstraint!
    
    @IBOutlet weak var fullPaySystemBtnDotViewWidthConstraint : NSLayoutConstraint!
    @IBOutlet weak var fullPaySystemBtnDotViewHeightConstraint : NSLayoutConstraint!
    @IBOutlet weak var sbdSPPaySystemBtnDotViewWidthConstraint  : NSLayoutConstraint!
    @IBOutlet weak var sbdSPPaySystemBtnDotViewHeightConstraint  : NSLayoutConstraint!
    
    @IBOutlet weak var fitBitSettingView: UIView!
    @IBOutlet weak var fitBitSettingHeightCons: NSLayoutConstraint!
    
    @IBOutlet weak var fetchMeasurements: UIButton!
    @IBOutlet weak var fetchSteps: UIButton!
    
    @IBOutlet weak var remindBtn : UIButton!
    @IBOutlet weak var timePicker : UIDatePicker!
    var isMetricSystemSelected = true
    var isDonateToCharitySelected = false
    var isDeviceSensorSystemSelected = true
    var fitBitMeasurement = false
    var isSbdSPPaySystemSelected = true
    var isReminderSelected = false
    var charities = [Charity]()
    var charityName = ""
    var charityDisplayName = ""

    //MARK: VIEW LIFE CYCLE
    
    lazy var settings = {
        return Settings.current()
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadCharities()
        
        isReminderSelected = UserDefaults.standard.bool(forKey: "isReminderSelected")
        if let settings = self.settings {
            self.isMetricSystemSelected = settings.measurementSystem == MeasurementSystem.metric.rawValue
            self.isDonateToCharitySelected = settings.isDonatingCharity
            self.isDeviceSensorSystemSelected = settings.isDeviceSensorSystemSelected
            self.fitBitMeasurement = settings.fitBitMeasurement
            self.isReminderSelected = settings.isReminderSelected
            self.isSbdSPPaySystemSelected = settings.isSbdSPPaySystemSelected
            self.charityName = settings.charityName
            self.charityDisplayName = settings.charityDisplayName
            if !self.charityName.isEmpty {
               self.setTextViewLinkString()
            }
            self.showCharityBtn.setTitle(self.charityDisplayName, for: .normal)
        }
        self.applyFinihingTouchToUIElements()
    }
    
    //MARK: INTERFACE BUILDER ACTIONS
    
    @IBAction func backBtnAction(_ sender : UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func metricMeasurementSystemBtnAction(_ sender : UIButton) {
        self.isMetricSystemSelected = true
        self.selectMetricSystem(select: true)
        self.selectUSSystem(select: false)
    }
    
    @IBAction func usMeasurementSystemBtnAction(_ sender : UIButton) {
        self.isMetricSystemSelected = false
        self.selectUSSystem(select: true)
        self.selectMetricSystem(select: false)
    }
    
    @IBAction func deviceSensorSystemBtnAction(_ sender : UIButton) {
        self.isDeviceSensorSystemSelected = true
        self.selectDeviceSensorSystem(select: true)
        self.selectFitBitSystem(select: false)
        applyFinihingTouchToUIElements()
    }
    
    @IBAction func fitBitSystemBtnAction(_ sender : UIButton) {
        self.isDeviceSensorSystemSelected = false
        self.selectDeviceSensorSystem(select: false)
        self.selectFitBitSystem(select: true)
        applyFinihingTouchToUIElements()
    }
    
    @IBAction func sbdSPPaySystemBtnAction(_ sender : UIButton) {
        self.isSbdSPPaySystemSelected = true
        self.selectsbdSPPaySystem(select: true)
        self.selectfullPaySystem(select: false)
    }
    
    @IBAction func fullSPaySystemBtnAction(_ sender : UIButton) {
        self.isSbdSPPaySystemSelected = false
        self.selectsbdSPPaySystem(select: false)
        self.selectfullPaySystem(select: true)
    }
    
    @IBAction func donateTopCharityBtnAction(_ sender : UIButton) {
        sender.isSelected = !sender.isSelected
        self.isDonateToCharitySelected = sender.isSelected
        self.donateTopCharityBtn.layer.borderColor = sender.isSelected ? UIColor.clear.cgColor :  UIColor.darkGray.cgColor
        self.donateTopCharityBtn.layer.borderWidth = sender.isSelected ? 0.0 : 2.0
        if sender.isSelected {
            self.donateTopCharityBtn.setImage(#imageLiteral(resourceName: "check").withRenderingMode(.alwaysTemplate), for: .normal)
            self.donateTopCharityBtn.tintColor = ColorTheme
        } else {
            self.donateTopCharityBtn.setImage(nil, for: .normal)
        }
    }
    
    @IBAction func fetchMeasuremtnsBtn(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.fitBitMeasurement = sender.isSelected
        self.fetchMeasurements.layer.borderColor = sender.isSelected ? UIColor.clear.cgColor :  UIColor.darkGray.cgColor
        self.fetchMeasurements.layer.borderWidth = sender.isSelected ? 0.0 : 2.0
        if sender.isSelected {
            self.fetchMeasurements.setImage(#imageLiteral(resourceName: "check").withRenderingMode(.alwaysTemplate), for: .normal)
            self.fetchMeasurements.tintColor = ColorTheme
        } else {
            self.fetchMeasurements.setImage(nil, for: .normal)
        }
    }
    @IBAction func fetchStepsAction(_ sender: Any) {
    }
    @IBAction func reminderBtnAction(_ sender : UIButton) {
        sender.isSelected = !sender.isSelected
        self.isReminderSelected = sender.isSelected
        UserDefaults.standard.set(self.isReminderSelected, forKey: "isReminderSelected")
        self.remindBtn.layer.borderColor = sender.isSelected ? UIColor.clear.cgColor :  UIColor.darkGray.cgColor
        self.remindBtn.layer.borderWidth = sender.isSelected ? 0.0 : 2.0
        if sender.isSelected {
            self.remindBtn.setImage(#imageLiteral(resourceName: "check").withRenderingMode(.alwaysTemplate), for: .normal)
            self.remindBtn.tintColor = ColorTheme
        } else {
            self.remindBtn.setImage(nil, for: .normal)
        }
    }
    
    @IBAction func showCharitiesBtnAction(_ sender : UIButton) {
        if self.charities.count == 0 {
            self.showAlertWith(title: nil, message: "No Charity available")
            return
        }
        
        if let nib = Bundle.main.loadNibNamed("ActivityTypesView", owner: self, options: nil) {
            var objActivityTypesView : ActivityTypesView? = nib[0] as? ActivityTypesView
            objActivityTypesView?.activityTypesOrCharities = self.charities.map({$0.display_name})
            objActivityTypesView?.selectedActivities = (self.charityDisplayName).components(separatedBy: CharacterSet.init(charactersIn: ","))
            objActivityTypesView?.isForCharity = true
            objActivityTypesView?.activitiesTableView.reloadData()
            self.view.addSubview(objActivityTypesView!)
            objActivityTypesView?.prepareForNewConstraints { (v) in
                v?.setLeadingSpaceFromSuperView(leadingSpace: 0)
                v?.setTrailingSpaceFromSuperView(trailingSpace: 0)
                v?.setTopSpaceFromSuperView(topSpace: 0)
                v?.setBottomSpaceFromSuperView(bottomSpace: 0)
            }
            objActivityTypesView?.SelectedActivityTypesCompletion = { selectedActivities in
                if selectedActivities.count > 0 {
                    self.charityDisplayName = selectedActivities[0]
                    self.charityName = self.charities.first(where: {$0.display_name == self.charityDisplayName})?.charity_name ?? ""
                    self.showCharityBtn.setTitle(self.charityDisplayName, for: .normal)
                    self.setTextViewLinkString()
                }
                objActivityTypesView?.selectedActivities.removeAll()
                objActivityTypesView?.removeFromSuperview()
                objActivityTypesView = nil
            }
        }
    }
    
    @IBAction func saveSettingsBtnAction(_ sender : UIButton) {
        //metric system
        UserDefaults.standard.set(!isDeviceSensorSystemSelected, forKey: "isFitSystemSelected")
        if let settings = self.settings {
            settings.update(measurementSystem: self.isMetricSystemSelected ? .metric : .us, isDonatingCharity: self.isDonateToCharitySelected, charityName: charityName, charityDisplayName: charityDisplayName, isDeviceSensorSystemSelected: self.isDeviceSensorSystemSelected,isSbdSPPaySystemSelected: self.isSbdSPPaySystemSelected,isReminderSelected: self.isReminderSelected, fitBitMeasurement: self.fitBitMeasurement)
        } else {
            Settings.saveWith(info: [SettingsKeys.measurementSystem : (self.isMetricSystemSelected ? MeasurementSystem.metric.rawValue : MeasurementSystem.us.rawValue), SettingsKeys.isDonatingCharity : false, SettingsKeys.charityName :  charityName, SettingsKeys.charityDisplayName : charityDisplayName, SettingsKeys.datasource: isDeviceSensorSystemSelected, SettingsKeys.postpayout : isSbdSPPaySystemSelected, SettingsKeys.reminder : isReminderSelected, SettingsKeys.fitBitMeasurement : fitBitMeasurement])
        }
        
        self.showAlertWithOkCompletion(title: nil, message: "Settings has been saved") { (cl) in
            self.navigationController?.popViewController(animated: true)
        }

        UIApplication.shared.cancelAllLocalNotifications()
        if isReminderSelected{
            setNotification()
        }
    }
    
    func setNotification(){
        let notification = UILocalNotification()
        
        /* Time and timezone settings */
        let date:Date = timePicker.date;
        UserDefaults.standard.set(date.toString(dateFormat: "HH:mm"), forKey: "ReminderDate")
        notification.fireDate = date
        notification.repeatInterval = NSCalendar.Unit.day
        notification.timeZone = NSCalendar.current.timeZone
        notification.alertTitle = "Actifit Reminder"
        notification.alertBody = "You haven't posted today's activity report!"
        
        /* Action settings */
        notification.hasAction = true
        notification.alertAction = "View"
        
        /* Badge settings */
        notification.applicationIconBadgeNumber =
            UIApplication.shared.applicationIconBadgeNumber + 1
        /* Additional information, user info */

        
        /* Schedule the notification */
        UIApplication.shared.scheduleLocalNotification(notification)
    
    }
    
    //MARK: HELPERS
    
    
    func applyFinihingTouchToUIElements() {
        self.saveSettingsBtn.layer.cornerRadius = 2.0
        self.showCharityBtn.layer.cornerRadius = 2.0
        self.backBtn.setImage(#imageLiteral(resourceName: "back_black").withRenderingMode(.alwaysTemplate), for: .normal)
        self.backBtn.tintColor = UIColor.white
        
        self.metricDotView.backgroundColor = ColorTheme
        self.usDotView.backgroundColor = ColorTheme
        
        self.deviceSensorDotView.backgroundColor = ColorTheme
        self.fitBitDotView.backgroundColor = ColorTheme
        
        self.fullPayDotView.backgroundColor = ColorTheme
        self.sbdSPPayDotView.backgroundColor = ColorTheme
        
        metricMeasurementSystemBtn.layer.cornerRadius = metricMeasurementSystemBtn.frame.size.width / 2
        USMeasurementSystemBtn.layer.cornerRadius = USMeasurementSystemBtn.frame.size.width / 2
        
        deviceSensortSystemBtn.layer.cornerRadius = deviceSensortSystemBtn.frame.size.width / 2
        fitBitSystemBtn.layer.cornerRadius = fitBitSystemBtn.frame.size.width / 2
        
        fullPaySystemBtn.layer.cornerRadius = fullPaySystemBtn.frame.size.width / 2
        sbdSPPaySystemBtn.layer.cornerRadius = sbdSPPaySystemBtn.frame.size.width / 2
        
        metricDotView.layer.cornerRadius = metricDotView.frame.size.width / 2
        usDotView.layer.cornerRadius = usDotView.frame.size.width / 2
        
        deviceSensorDotView.layer.cornerRadius = deviceSensorDotView.frame.size.width / 2
        fitBitDotView.layer.cornerRadius = fitBitDotView.frame.size.width / 2
        
        fullPayDotView.layer.cornerRadius = fullPayDotView.frame.size.width / 2
        sbdSPPayDotView.layer.cornerRadius = sbdSPPayDotView.frame.size.width / 2
        
        self.donateTopCharityBtn.layer.borderColor = UIColor.darkGray.cgColor
        self.donateTopCharityBtn.layer.borderWidth = 2.0
        self.donateTopCharityBtn.layer.cornerRadius = 2.0
        
        self.remindBtn.layer.borderColor = UIColor.darkGray.cgColor
        self.remindBtn.layer.borderWidth = 2.0
        self.remindBtn.layer.cornerRadius = 2.0
        
        self.fetchMeasurements.layer.borderColor = UIColor.darkGray.cgColor
        self.fetchMeasurements.layer.borderWidth = 2.0
        self.fetchMeasurements.layer.cornerRadius = 2.0
        
        self.fetchSteps.layer.borderColor = UIColor.darkGray.cgColor
        self.fetchSteps.layer.borderWidth = 0.0
        self.fetchSteps.layer.cornerRadius = 2.0
        self.fetchSteps.isEnabled = true
        self.fetchSteps.setImage(#imageLiteral(resourceName: "check").withRenderingMode(.alwaysTemplate), for: .normal)
        self.fetchSteps.tintColor = UIColor.darkGray
        
        //update UI
        selectMetricSystem(select: self.isMetricSystemSelected)
        selectUSSystem(select: !self.isMetricSystemSelected)
        
        selectfullPaySystem(select: !isSbdSPPaySystemSelected)
        selectsbdSPPaySystem(select: isSbdSPPaySystemSelected)
        
        selectDeviceSensorSystem(select: isDeviceSensorSystemSelected)
        selectFitBitSystem(select: !isDeviceSensorSystemSelected)
        if self.isDonateToCharitySelected {
            self.donateTopCharityBtn.isSelected = true
            self.donateTopCharityBtn.layer.borderWidth = 0.0
            self.donateTopCharityBtn.setImage(#imageLiteral(resourceName: "check").withRenderingMode(.alwaysTemplate), for: .normal)
            self.donateTopCharityBtn.tintColor = ColorTheme
        }
        
        if self.fitBitMeasurement{
            self.fetchMeasurements.isSelected = true
            self.fetchMeasurements.layer.borderWidth = 0.0
            self.fetchMeasurements.setImage(#imageLiteral(resourceName: "check").withRenderingMode(.alwaysTemplate), for: .normal)
            self.fetchMeasurements.tintColor = ColorTheme
        }
        if self.isReminderSelected {
            self.remindBtn.isSelected = true
            self.remindBtn.layer.borderWidth = 0.0
            self.remindBtn.setImage(#imageLiteral(resourceName: "check").withRenderingMode(.alwaysTemplate), for: .normal)
            self.remindBtn.tintColor = ColorTheme
            let reminderTime = UserDefaults.standard.string(forKey: "ReminderDate")
            if reminderTime == nil{
                return
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat =  "HH:mm"
            let date = dateFormatter.date(from: reminderTime!)
            timePicker.date = date!

        }
        
        if !self.isDeviceSensorSystemSelected{
            fitBitSettingView.isHidden = false
            fitBitSettingHeightCons.constant = 100
            updateViewConstraints()
        }else{
            fitBitSettingView.isHidden = true
            fitBitSettingHeightCons.constant = 0
            updateViewConstraints()
        }
    }
    
    func setTextViewLinkString() {
        self.charityLinkTextView.attributedText = self.charitySteemitUrl().attributedString(font: UIFont.systemFont(ofSize: 14), textColor: ColorTheme)
        self.charityLinkTextView.linkTextAttributes = [NSAttributedStringKey.link.rawValue : ColorTheme]
    }
    
    func selectMetricSystem(select : Bool) {
        self.metricMeasurementSystemBtn.layer.borderColor = select ? ColorTheme.cgColor : UIColor.darkGray.cgColor
        self.metricMeasurementSystemBtn.layer.borderWidth = 2.0
        self.metricMeasurementSystemBtnDotViewWidthConstraint.constant = select ? 10 : 0.0
        self.metricMeasurementSystemBtnDotViewHeightConstraint.constant = select ? 10 : 0.0
        self.view.layoutIfNeeded()
    }
    
    func selectUSSystem(select : Bool) {
        self.USMeasurementSystemBtn.layer.borderColor = select ? ColorTheme.cgColor : UIColor.darkGray.cgColor
        self.USMeasurementSystemBtn.layer.borderWidth = 2.0
        self.USMeasurementSystemBtnDotViewWidthConstraint.constant = select ? 10 : 0.0
        self.USMeasurementSystemBtnDotViewHeightConstraint.constant = select ? 10 : 0.0
        self.view.layoutIfNeeded()
    }
    
    func selectDeviceSensorSystem(select : Bool) {
        self.deviceSensortSystemBtn.layer.borderColor = select ? ColorTheme.cgColor : UIColor.darkGray.cgColor
        self.deviceSensortSystemBtn.layer.borderWidth = 2.0
        self.deviceSensorSystemBtnDotViewWidthConstraint.constant = select ? 10 : 0.0
        self.deviceSensorSystemBtnDotViewHeightConstraint.constant = select ? 10 : 0.0
        self.view.layoutIfNeeded()
    }
    
    func selectFitBitSystem(select : Bool) {
        self.fitBitSystemBtn.layer.borderColor = select ? ColorTheme.cgColor : UIColor.darkGray.cgColor
        self.fitBitSystemBtn.layer.borderWidth = 2.0
        self.fitBitSystemBtnDotViewHeightConstraint.constant = select ? 10 : 0.0
        self.fitBitSystemBtnDotViewWidthConstraint.constant = select ? 10 : 0.0
        self.view.layoutIfNeeded()
    }
    
    func selectsbdSPPaySystem(select : Bool) {
        self.sbdSPPaySystemBtn.layer.borderColor = select ? ColorTheme.cgColor : UIColor.darkGray.cgColor
        self.sbdSPPaySystemBtn.layer.borderWidth = 2.0
        self.sbdSPPaySystemBtnDotViewWidthConstraint.constant = select ? 10 : 0.0
        self.sbdSPPaySystemBtnDotViewHeightConstraint.constant = select ? 10 : 0.0
        self.view.layoutIfNeeded()
    }
    
    func selectfullPaySystem(select : Bool) {
        self.fullPaySystemBtn.layer.borderColor = select ? ColorTheme.cgColor : UIColor.darkGray.cgColor
        self.fullPaySystemBtn.layer.borderWidth = 2.0
        self.fullPaySystemBtnDotViewHeightConstraint.constant = select ? 10 : 0.0
        self.fullPaySystemBtnDotViewWidthConstraint.constant = select ? 10 : 0.0
        self.view.layoutIfNeeded()
    }
    
    func charitySteemitUrl() -> String {
        return "https://steemit.com/@" + self.charityName
    }
    
    //MARK: WEB SERVICES
    
    func loadCharities() {
        ActifitLoader.show(title: Messages.loading_charities, animated: true)
        APIMaster.getCharities(completion: { [weak self] (jsonString) in
            DispatchQueue.main.async(execute: {
                ActifitLoader.hide()
            })
            if let jsonString = jsonString as? String {
                let data = jsonString.utf8Data()
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if let jsonArray = (json as? [[String : Any]]){
                        self?.charities = jsonArray.map({Charity.init(info: $0)})
                    }
                } catch {
                    print("unable to fetch charities")
                }
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

extension SettingsVC : UITextViewDelegate {
    
    //MARK : UITextViewDelegate
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return true
    }
}

extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
}
