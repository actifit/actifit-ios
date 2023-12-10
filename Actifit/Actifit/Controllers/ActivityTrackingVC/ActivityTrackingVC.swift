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
import Combine
import RealmSwift
import UserNotifications
import FontAwesome_swift
import SafariServices

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
    
    var  gadgetHorizontalStackView = UIStackView()
    
    @IBOutlet weak var redChatDot: UIView!
    @IBOutlet weak var exchangeListBtn: UIButton!
    @IBOutlet weak var noGadgetsLabel: UILabel!
    @IBOutlet weak var gadgetScrollView: UIScrollView!
    @IBOutlet weak var votingScrollVIiew: UIScrollView!
    @IBOutlet weak var stepsCountLabel : EFCountingLabel!
    @IBOutlet weak var postToSteemitBtn : UIButton!
    @IBOutlet weak var snapBtn : UIButton!
    @IBOutlet weak var viewTrackingHistoryBtn : UIButton!
    @IBOutlet weak var viewDailyLeaderboardBtn : UIButton!
    
    @IBOutlet weak var topGuestHeader: UIView!
    
    @IBOutlet weak var topUserHeaderView: UIStackView!
    @IBOutlet weak var gatgetTopView: UIView!
    
    
    @IBOutlet weak var afitImageView: UIImageView!
    
    @IBOutlet weak var hiveImageView: UIImageView!
    
    @IBOutlet weak var blurtImageView: UIImageView!
    
    @IBOutlet weak var sportImageView: UIImageView!
    
//    @IBOutlet weak var hiveButton: UIButton!
//
//    @IBOutlet weak var actifitButton: UIButton!
//
//    @IBOutlet weak var blurtButton: UIButton!
    
    @IBOutlet weak var bottomWalletButton: UIButton!
    
    @IBOutlet weak var afitBalanceLabel: UILabel!
   // @IBOutlet weak var sportButton: UIButton!
    
    @IBOutlet weak var exclamationButton: UIButton!
    
    @IBOutlet weak var graphsStackVIew: UIStackView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var rank: UILabel!
    @IBOutlet weak var todayDate: UILabel!
    @IBOutlet weak var piechartView: PieChartView!
    @IBOutlet weak var dailybarChart: BarChartView!
    @IBOutlet weak var datebarChart: BarChartView!
    @IBOutlet weak var userImage: UIImageView!
    private var activityTrackingViewModel = ActivityTrackingViewModel()
    private var cancellables = Set<AnyCancellable>()
    @IBOutlet weak var collectionVIew: UICollectionView!
    var swipteTimer: Timer?
    let autoScrollDuration: TimeInterval = 2.0 // Ad
    @IBOutlet weak var walletButton: UIButton!
    
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var notificationButton: UIButton!
    
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var giftButton: UIButton!
    @IBOutlet weak var topSettingsButton: UIButton!
    @IBOutlet weak var trophyButton: UIButton!
    var pageControl: UIPageControl!
    @IBOutlet weak var gaugeButton: UIButton!
    var  bannerImages: [BannerImageModel] = []
    
    @IBOutlet weak var swipeGraphsButton: UIButton!
    
    @IBOutlet weak var votingLabel: UILabel!
    @IBOutlet weak var votingButton: UIButton!
    
    @IBOutlet weak var marketBtn: UIButton!
    
    @IBOutlet weak var postAndEarnButton: UIButton!
    
    @IBOutlet weak var referralsBtn: UIButton!
    
    @IBOutlet weak var socialBtn: UIButton!
    
    @IBOutlet weak var pictureBtn: UIButton!
    
    @IBOutlet weak var historyBtn: UIButton!
    
    @IBOutlet weak var socialsBtn: UIButton!
    @IBOutlet weak var listBtn: UIButton!
    
    @IBOutlet weak var marketMenuBtn: UIButton!
    
    @IBOutlet weak var videoTutorialBtn: UIButton!
    
    @IBOutlet weak var chatBtn: UIButton!
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
    var timeSlot = [String]()
    var initialStepCount = 0
    
    
    
    private var activityUpdateTimer: Timer?
    private var isQueryingActivity = false
    
    let serialQueue = DispatchQueue(label: "com.actifit.serialQueue")

    
    @IBAction func postAndEarnTapped(_ sender: Any) {
        if User.current() != nil {
        if checkIfCanPost() {
            let postToSteemitVC : PostToSteemitVC = PostToSteemitVC.instantiateWithStoryboard(appStoryboard: .SB_Main) as! PostToSteemitVC
            self.navigationController?.pushViewController(postToSteemitVC, animated: true)
        } else {
            self.showAlertWith(title: nil, message: Messages.one_post_per_day_error)
        }
    } else {
        showToast(message: "Please login first")
        return
    }
        
    }
    
    @IBAction func bottomMenuBtnTapped(_ sender: UIButton ) {
        switch sender.tag {
       
        case 1: break;
        case 2: snapPicBtnAction()
        case 3: viewTrackingHistoryAction()
        case 4: viewDailyLeaderboardAction()
        case 5: openSocialMediaPopup()
        case 6:  break;
        case 7:  openVideoTutorial()
        case 8:
            blinkChatIcon(blink: false)
            openChat();
        default: break
        }
    }
    
    
    private func openChat() {
        let vc = ChatViewController()
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
    
    private func openVideoTutorial() {
        self.present(TutorialVideoViewController.create(), animated: true)
    }
    
    
    @IBAction func exchangeBtnTapped(_ sender: Any) {
        self.present(MarketExchangeViewController.create(), animated: true)
    }
    
    @IBAction func rankBtnAction(_ sender: Any) {
        if rank.text ?? "" != ""{
            guard let url = URL(string: "https://actifit.io/userrank") else { return }
            UIApplication.shared.open(url)
        }
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        
    }
    
    
    private func setUI() {
        blinkChatIcon(blink: false)
        redChatDot.layer.cornerRadius = redChatDot.frame.width / 2
        redChatDot.clipsToBounds = true
        self.historyFifteenMinute = ActivityFifteenMinutesInterval.all()
        self.history = Activity.allWithoutCountZero()
   
        
        
        if User.current() != nil {
                self.topUserHeaderView.isHidden = false
                self.topGuestHeader.isHidden = true
            } else {
                self.topUserHeaderView.isHidden = true
                self.topGuestHeader.isHidden = false
            }
    
           
        postAndEarnButton.layer.cornerRadius = 5
        postAndEarnButton.clipsToBounds = true
        getPRPercentage()
        collectionVIew.register(UINib(nibName: "BannerImageCell", bundle: nil), forCellWithReuseIdentifier: "BannerImageCell")
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionVIew.collectionViewLayout = layout
        
        self.historyFifteenMinute = ActivityFifteenMinutesInterval.all()
        print("History Count" + "\(historyFifteenMinute.count)")
        self.history = Activity.allWithoutCountZero()
        print("History Count" + "\(history.count)")
        stepsCountLabel.format = "%d"
       // self.postToSteemitBtn.layer.cornerRadius = 4.0
        //self.viewTrackingHistoryBtn.layer.cornerRadius = 4.0
       // self.viewDailyLeaderboardBtn.layer.cornerRadius = 4.0
       // self.snapBtn.layer.cornerRadius = 4.0
        let gesture = UITapGestureRecognizer(target: self, action: #selector(profileBtnAction))
        userImage.isUserInteractionEnabled = true
        userImage.addGestureRecognizer(gesture)
        
        self.userImage.layer.cornerRadius = 16
        self.userImage.clipsToBounds = true
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        checkActifitUserID()
        
        barEntry()
        UserImage()
        setButtonIcons()
        setBindings()
        dailybarChart.isHidden = true
        swipeGraphsButton.setTitle(NSLocalizedString("hourly", comment: ""), for: .normal)
        swipeGraphsButton.backgroundColor = .primaryRedColor()
        swipeGraphsButton.tintColor = .white
        swipeGraphsButton.layer.cornerRadius = 5
        swipeGraphsButton.layer.masksToBounds = true
        votingLabel.translatesAutoresizingMaskIntoConstraints = false
        votingScrollVIiew.translatesAutoresizingMaskIntoConstraints = false
        votingLabel.numberOfLines = 1
        votingLabel.lineBreakMode = .byTruncatingTail
        votingScrollVIiew.addSubview(votingLabel)
        
        NSLayoutConstraint.activate([
            votingLabel.leadingAnchor.constraint(equalTo: votingScrollVIiew.leadingAnchor),
            votingLabel.topAnchor.constraint(equalTo: votingScrollVIiew.topAnchor),
            votingLabel.bottomAnchor.constraint(equalTo: votingScrollVIiew.bottomAnchor),
            // Ensure the UILabel width is greater than the width of the UIScrollView for horizontal scrolling
            votingLabel.widthAnchor.constraint(greaterThanOrEqualTo: votingScrollVIiew.widthAnchor)
        ])
        setGadgetScrolling()

    }
    
    @IBAction func referralsBtnTapped(_ sender: Any) {
        if let user =  User.current() {
            self.present(ReferralsPopupViewController.create(), animated: true)
        } else {
            showToast(message: "Please login first")
        }
    }
    
    
    
    private func setGadgetScrolling() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        gadgetScrollView.addGestureRecognizer(tapGesture)
        
        gadgetScrollView.contentInset = UIEdgeInsets.zero
        gadgetScrollView.contentOffset = CGPoint(x: 0, y: 0)
        gadgetHorizontalStackView.alignment = .leading
        gadgetHorizontalStackView.axis = .horizontal
        gadgetHorizontalStackView.spacing = 5
        gadgetScrollView.addSubview(gadgetHorizontalStackView)
        gadgetHorizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            gadgetHorizontalStackView.leadingAnchor.constraint(equalTo: gadgetScrollView.leadingAnchor),
            gadgetHorizontalStackView.topAnchor.constraint(equalTo: gadgetScrollView.topAnchor),
            gadgetHorizontalStackView.trailingAnchor.constraint(equalTo: gadgetScrollView.trailingAnchor),
            gadgetHorizontalStackView.bottomAnchor.constraint(equalTo: gadgetScrollView.bottomAnchor),
        ])
    }
    
    @objc func profileBtnAction(_ sender: UITapGestureRecognizer) {
        if let username = User.current()?.steemit_username {
            if username != "" {
                let url = URL(string: "https://actifit.io/" + username)
                UIApplication.shared.open(url!)
            }
        }
    }
    
    
    private func scaleEarnButton() {
        if checkIfCanPost() && User.current() != nil && self.initialStepCount >= 5000 {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.repeat, .allowUserInteraction, .autoreverse]) {
                self.postAndEarnButton.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            }
            
        }
    }
    
    private func blinkChatIcon(blink: Bool) {
        if blink == false {
            redChatDot.isHidden = true
        } else {
            redChatDot.isHidden = false
            UIView.animate(withDuration: 1.0, delay: 0, options: [.repeat, .autoreverse], animations: {
                self.redChatDot.alpha = self.redChatDot.isHidden ? 1.0 : 0.0
            }, completion: { _ in
                self.redChatDot.isHidden.toggle()
            })
        }
    }
    
    private func scalePrizeButton() {
            if UserDefaults.standard.getLatestAdDate != Date().currentDay() && User.current() != nil  {
                UserDefaults.standard.latestPrizeType = ""
                UserDefaults.standard.getLatestPrizeAmount = ""
                UserDefaults.standard.freeReward = ""
                UserDefaults.standard.fiveKReward = ""
                UserDefaults.standard.sevenKReward = ""
                UserDefaults.standard.tenKReward = ""
                UIView.animate(withDuration: 0.5, delay: 0.0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: {
                    self.giftButton.transform = CGAffineTransform(scaleX: 1.20, y: 1.20)
                    
                    // self.giftButton.bounds = CGRect(x: 0, y: 0, width: self.giftButton.bounds.width * 1.2, height: self.giftButton.bounds.height * 1.2)
                }, completion: nil)
            }
    }
    
    
    
    func stopPrizeButtonScaling() {
        giftButton.layer.removeAllAnimations()
        giftButton.transform = CGAffineTransform.identity
    }
    
    func stopPostButtonScaling() {
        postAndEarnButton.layer.removeAllAnimations()
        postAndEarnButton.transform = CGAffineTransform.identity
        
    }
    
    @IBAction func loginBtnTapped(_ sender: Any) {
      dismiss(animated: true)
    }
    
    @IBAction func signupBtnTapped(_ sender: Any) {
        
        let controller = SFSafariViewController(url: AppConstants.createAccountURL)
        present(controller, animated: true, completion: nil)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            openPopup(title: NSLocalizedString("virtual_gadgets", comment: ""), description: NSLocalizedString("virtual_gadgets_details", comment: ""), cancelTitle: NSLocalizedString("close_upper", comment: ""), actionTitle: NSLocalizedString("market", comment: ""), size: .medium)
            // This method is called when a tap/select event occurs
            // You can perform actions related to the tap/select here
        }
    }
    
    
    
    @IBAction func giftButtonTapped(_ sender: Any) {
        if User.current() != nil {
             let animateButton =  (UserDefaults.standard.getLatestAdDate != Date().currentDay()) || UserDefaults.standard.getLatestPrizeAmount == ""
             present(TransparentWIthMultipleButtonsViewController.create(ad: activityTrackingViewModel.googleAd, steps: initialStepCount,animateButton: animateButton,  prizeSelection: { [weak self] prizeType in
            if(prizeType != .close) {
                self?.stopPrizeButtonScaling()
            }
            
        }), animated: true)
         } else {
              showToast(message: "Please login first")
         }
    }
    
    
    
    
    
    @IBAction func exclamationButtonTapped(_ sender: Any) {
        var body = NSLocalizedString("eligible_tokens_earn", comment: "")
        if(activityTrackingViewModel.blurtObject?.id == nil) {
            body.append(NSLocalizedString("no_blurt_account", comment: ""))
        } else {
            if let balanceString =  activityTrackingViewModel.blurtObject?.balance {
                if let balance = Double.parse(from: balanceString) {
                    if balance < 5 {
                        body.append(NSLocalizedString("low_blurt_balance", comment: ""))
                    } else {
                        
                    }
                }
            }
            //check if its below 5
        }
        if let doubleTokens = Double(activityTrackingViewModel.afitTokenObject?.tokens ?? "0.0") {
            if doubleTokens < 5000 {
                body.append(NSLocalizedString("low_afit_balance", comment: ""))
                body.append(NSLocalizedString("minimum_actifity_start", comment: ""))
                //minimum_actifity_start
            }
            
        }
        body.append(NSLocalizedString("other_token_rewards", comment: ""))
        openPopup(title: NSLocalizedString("potential_token_earnings", comment: ""), description: body, cancelTitle: NSLocalizedString("close_upper", comment: ""), size: .large)
    }
    
    private func openSocialMediaPopup() {
        let vc = SocialMediaPopupViewController.create()
        present(vc, animated: true)
    }
    
    private func openDailtyTip(dataModel: [DailyTipsModel]) {
        
        let vc = TipPopupViewController.create(tips: dataModel, title: NSLocalizedString("random_activit_tip", comment: ""), onClose: { [weak self] in
            self?.activityTrackingViewModel.getSurveyPolls()
        })
        self.present(vc, animated: true)
    }
    
    
    @IBAction func swipeGraphsTapped(_ sender: Any) {
        let isDailyChartAHidden = dailybarChart.isHidden
        let isDateChartHidden = datebarChart.isHidden
        
        // Calculate the new visibility state for the views
        let updatedDayChartVisibility = isDailyChartAHidden ? false : true
        let updatedDateChartVisibilty = isDateChartHidden ? true : false
        self.dailybarChart.alpha = 0.0
        self.datebarChart.alpha = 0.0
        
        // Animate the transition
        UIView.animate(withDuration: 0.5, animations: {
            self.dailybarChart.alpha = updatedDayChartVisibility ? 0.0 : 1.0
            self.datebarChart.alpha = updatedDateChartVisibilty ? 0.0 : 1.0
            // Update the views' hidden properties for final state
            self.dailybarChart.isHidden = updatedDayChartVisibility
            self.datebarChart.isHidden = updatedDateChartVisibilty
            // Force layout update
            //self.graphsStackVIew.layoutIfNeeded()
        })
        
        swipeGraphsButton.setTitle(NSLocalizedString(isDailyChartAHidden ? "daily" :"hourly", comment: ""), for: .normal)
        
        
        
    }
    
    private func setGadgetUI() {
        DispatchQueue.main.async {
            
            
            if self.activityTrackingViewModel.gadgetsList.isEmpty {
                self.gatgetTopView.isHidden = true
                self.noGadgetsLabel.isHidden = false
                self.noGadgetsLabel.font = UIFont.systemFont(ofSize: 12)
                self.noGadgetsLabel.textColor = .gray
                self.noGadgetsLabel.text = NSLocalizedString("no_active_gadgets", comment: "")
                
            } else {
                
                self.gatgetTopView.isHidden = false
                self.noGadgetsLabel.isHidden = true
                for index in 0..<self.activityTrackingViewModel.gadgetsList.count {
                    let resizedImg = self.resizedImage(image: self.activityTrackingViewModel.gadgetsList[index].image!, targetSize: CGSize(width: 25, height: 25))
                    let customItemView = self.createCustomItemView(imageName: resizedImg, digit: self.activityTrackingViewModel.gadgetsList[index].gadgetsLevel)
                    
                    customItemView.widthAnchor.constraint(equalToConstant: 40).isActive = true
                    customItemView.heightAnchor.constraint(equalToConstant: 35).isActive = true
                    self.gadgetHorizontalStackView.addArrangedSubview(customItemView)
                }
            }
            let totalWidth = CGFloat(self.activityTrackingViewModel.gadgetsList.count) * 40 + CGFloat(self.activityTrackingViewModel.gadgetsList.count - 1) * 10 // Considering width + spacing
            self.gadgetHorizontalStackView.widthAnchor.constraint(equalToConstant: totalWidth).isActive = true
            self.gadgetScrollView.contentSize = CGSize(width: totalWidth, height: 40)// Adjust height as needed
            if self.activityTrackingViewModel.gadgetsList.count < 3 {
                self.gadgetScrollView.isScrollEnabled = false
            } else {
                self.gadgetScrollView.isScrollEnabled = true
            }
        }
    }
    
    func createCustomItemView(imageName: UIImage?, digit: Int) -> UIView {
        let customItemView = UIView()
        // customItemView.backgroundColor = .blue
        
        let imageView = UIImageView(image:imageName!)
        // imageView.contentMode = .scaleAspectFit
        customItemView.addSubview(imageView)
        
        let digitLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
        digitLabel.translatesAutoresizingMaskIntoConstraints = false
        digitLabel.text = "\(digit)"
        digitLabel.font = UIFont.systemFont(ofSize: 12)
        digitLabel.textColor = .primaryRedColor()
        digitLabel.backgroundColor = .white
        digitLabel.textAlignment = .center
        digitLabel.layer.cornerRadius = 10
        digitLabel.clipsToBounds = true
        customItemView.addSubview(digitLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: customItemView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: customItemView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: customItemView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            //digitLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor), // Place label below the image
            digitLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 20), // Align label with the left edge
            digitLabel.widthAnchor.constraint(equalToConstant: 15),
            digitLabel.heightAnchor.constraint(equalToConstant: 20),
            digitLabel.bottomAnchor.constraint(equalTo: customItemView.bottomAnchor, constant: 5)
        ])
        
        return customItemView
    }
    
    func resizedImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        return resizedImage
    }
    
    
    func startAutoScrollTimer() {
        swipteTimer = Timer.scheduledTimer(timeInterval: autoScrollDuration, target: self, selector: #selector(scrollToNextPage), userInfo: nil, repeats: true)
    }
    
    @objc func scrollToNextPage() {
        let nextPage = pageControl.currentPage + 1
        if nextPage < bannerImages.count {
            let indexPath = IndexPath(item: nextPage, section: 0)
            collectionVIew.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            pageControl.currentPage = nextPage
        } else {
            pageControl.currentPage = 0
            let indexPath = IndexPath(item: pageControl.currentPage, section: 0)
            collectionVIew.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    func setupPageControl() {
        pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        collectionVIew.superview?.addSubview(pageControl) // Add to the collection view's superview
        
        // Set up constraints for the page control
        pageControl.centerXAnchor.constraint(equalTo: collectionVIew.centerXAnchor).isActive = true
        pageControl.bottomAnchor.constraint(equalTo: collectionVIew.bottomAnchor, constant: -5).isActive = true
        
        // Set the number of pages in the page control (the total number of items in the collection view)
        pageControl.numberOfPages = bannerImages.count
        pageControl.hidesForSinglePage = false
//        pageControl.defersCurrentPageDisplay = true
        // Set the current page to 0 initially
        pageControl.currentPage = 0
        
        
    }
    
    private func setBindings() {
        
        activityTrackingViewModel.chatBlinkingtriggerPublisher.receive(on: DispatchQueue.main).sink { blink in
            self.blinkChatIcon(blink: blink)
        }.store(in: &cancellables)
        
        
        let greyBackground = UIColor(red: 210/255, green: 215/255, blue: 211/255, alpha: 0.5)
        activityTrackingViewModel.blurtPublisher.receive(on: DispatchQueue.main).sink { isDisabled in
            if isDisabled {
                self.blurtImageView.image = UIImage(named: "blurt-icon")?.withTintColor(greyBackground)
                self.blurtImageView.tintColor = greyBackground
            }
        }.store(in: &cancellables)
        
        activityTrackingViewModel.loaderVisibilityPublisher.receive(on: DispatchQueue.main).sink { showLoader in
            self.changeLoaderStatus(showLoader: showLoader)
        }.store(in: &cancellables)
        
        activityTrackingViewModel.bannerImagesPublisher.receive(on: DispatchQueue.main).sink { [weak self] bannerItems in
            self?.bannerImages = bannerItems
            self?.setupPageControl()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self?.startAutoScrollTimer()
            })
            self?.collectionVIew.reloadData()
        }.store(in: &cancellables)
        
        activityTrackingViewModel.votingStatusPublisher.receive(on: DispatchQueue.main).sink { votingModel in
            self.votingLabel.text = votingModel.status?.isVoting == false ? votingModel.rewardStart :
            "💰 Rewards Cycle In Progress - Distributing Rewards 💰"
            self.votingScrollVIiew.contentSize = CGSize(width: self.votingLabel.intrinsicContentSize.width, height: 0)
            if votingModel.status?.isVoting == false {
                self.automateVotingScroll()
            }
        }.store(in: &cancellables)
        
        activityTrackingViewModel.afitTokenPublisher.receive(on: DispatchQueue.main).sink { [weak self] afitTokenModel in
            self?.afitBalanceLabel.text = "\(afitTokenModel.tokens ?? "") AFIT"
            if let doubleTokens = Double(afitTokenModel.tokens ?? "0.0") {
                if doubleTokens < 5000 {
                    self?.afitImageView.tintColor = greyBackground
                    self?.afitImageView.image = UIImage(named: "actifit-mini-icon")?.withTintColor(greyBackground)
                }
            }
        }.store(in: &cancellables)
        
        activityTrackingViewModel.dailyTipPublisher.receive(on: DispatchQueue.main).sink { [weak self] dailyTips in
            self?.openDailtyTip(dataModel: dailyTips )
        }.store(in: &cancellables)
        
        activityTrackingViewModel.gadgetPublisher.receive(on: DispatchQueue.main).sink { [weak self] gadgets  in
            guard let self = self else {return}
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.setGadgetUI()
            })
        }.store(in: &cancellables)
        
        activityTrackingViewModel.pollSurveryPublisher.receive(on: DispatchQueue.main).sink { [weak self] votingModel in
            let pollVC = PollDisplayViewController.create(pollViewModel: PollDisplayViewModel(survey: votingModel))
            pollVC.modalPresentationStyle = .overFullScreen
            self?.present(pollVC, animated: true)
        }.store(in: &cancellables)
        
    }
    
    func automateVotingScroll() {
        if activityTrackingViewModel.statusModel?.status?.isVoting == true {
            let totalScrollDistance = max(0, votingScrollVIiew.contentSize.width - votingScrollVIiew.bounds.width)
            
            // Set up a timer to scroll the content
            let timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] timer in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                let currentOffset = self.votingScrollVIiew.contentOffset.x
                var newOffset = currentOffset + 1.0 // Adjust the scrolling speed as needed
                if newOffset >= totalScrollDistance + 3 {
                    // Reset the content offset to start from the beginning
                    newOffset = 0
                }
                
                // Check if you've reached the end of the content
                //            if newOffset >= totalScrollDistance {
                //                timer.invalidate() // Stop the timer when you're done scrolling
                //            } else {
                self.votingScrollVIiew.setContentOffset(CGPoint(x: newOffset, y: 0), animated: false)
                //}
            }
            timer.fire()
        }

    }
    
    func getPRPercentage() {
        
        guard let username = User.current()?.steemit_username else { return }
        
        
        API().getRCPercentage(completion: {[weak self] info, statusCode in
            if let response = info as? String {
                let data = response.utf8Data()
                let decoder = JSONDecoder()
                do {
                    let percentageModel = try decoder.decode(RCPercentage.self, from: data)
                  
                    DispatchQueue.main.async {
                        self?.percentageLabel.text = percentageModel.currentRCPercent ?? ""
                    }
                }
                catch {
                   // print("Error decoding JSON: \(error.localizedDescription)")
                }
            }
        }, failure: { error in
            
        }, username: username)
    }
    
    func openResourceCreditsPopUp() {
        openPopup(title: NSLocalizedString("resource_credit_title", comment: ""), description: NSLocalizedString("resource_credits_desc", comment: ""), cancelTitle: NSLocalizedString("close_upper", comment: ""), size: .large)
    }
    
    func openUserRankPopUp() {
        openPopup(title: NSLocalizedString("user_rank_title", comment: ""), description: NSLocalizedString("user_rand_desc", comment: ""), cancelTitle: NSLocalizedString("close_upper", comment: ""), actionTitle: NSLocalizedString("user_rank_Details_upper", comment: ""), size: .large)
    }
    
    func openPopup(title: String, description: String, cancelTitle: String, actionTitle: String? = nil, size: NoteSize) {
        present(TransparentPopupViewController.create(title: title, description: description, cancelButtonText: cancelTitle, actionButtonText: actionTitle, noteSize: size), animated: true)
    }
    
    
    private func openNotificationScreen() {
        navigationController?.pushViewController(NotificationsViewController.create(), animated: true)
    }
    
    @IBAction func votingButtonTapped(_ sender: Any) {
        openPopup(title: NSLocalizedString("actifit_reward_cycle", comment: ""), description: NSLocalizedString("reward_cycle_details", comment: ""), cancelTitle: "CLOSE", size: .large)
    }
    
    
    func changeLoaderStatus(showLoader: Bool) {
        DispatchQueue.main.async {
            showLoader ? SwiftLoader().sharedInstance.show(title: "Loading", animated: true) : SwiftLoader().sharedInstance.hide()
        }
    
    }
    
    private func setButtonIcons() {
        trophyButton.setAttributedTitle(NSAttributedString.generateFontAwesomeString(code: AwesomeButtonCodes.trophyIcon.rawValue, size: 30), for: .normal)
        topSettingsButton.setAttributedTitle(NSAttributedString.generateFontAwesomeString(code: AwesomeButtonCodes.settingsIcon.rawValue, size: 30), for: .normal)
        notificationButton.setAttributedTitle(NSAttributedString.generateFontAwesomeString(code: AwesomeButtonCodes.notificationIcon.rawValue, size: 30), for: .normal)
        walletButton.setAttributedTitle(NSAttributedString.generateFontAwesomeString(code: AwesomeButtonCodes.walletIcon.rawValue, size: 30), for: .normal)
        bottomWalletButton.setAttributedTitle(NSAttributedString.generateFontAwesomeString(code: AwesomeButtonCodes.walletIcon.rawValue, size: 30), for: .normal)
        let gaugeImage = UIImage(named: "gauge")?.withTintColor(.primaryRedColor())
        let resizedImage = gaugeImage!.imageWithSize(CGSize(width: 30, height: 30))
        gaugeButton.setImage(resizedImage, for: .normal)
        gaugeButton.imageView?.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        
        gaugeButton.tintColor = .primaryRedColor()
        votingButton.setAttributedTitle(NSAttributedString.generateFontAwesomeString(code: AwesomeButtonCodes.votingIcon.rawValue, size: 30), for: .normal)
        hiveImageView.image = UIImage(named: "hive-icon")
        sportImageView.image = UIImage(named: "sports-icon")
        blurtImageView.image = UIImage(named: "blurt-icon")
        afitImageView.image = UIImage(named: "actifit-mini-icon")
        
        exclamationButton.setImage(UIImage(named: "exclamation-icon")?.withTintColor(.primaryRedColor()), for: .normal)
        marketBtn.setAttributedTitle(NSAttributedString.generateFontAwesomeString(code: AwesomeButtonCodes.marketButton.rawValue, size: 30), for: .normal)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 25) // Adjust the font size
        ]
        
        let attributedTitle = NSAttributedString(string: activityTrackingViewModel.setGiftButtonUnicodeImage(), attributes: attributes)
       
        giftButton.setAttributedTitle(attributedTitle, for: .normal)
        giftButton.layer.cornerRadius = 5
        giftButton.clipsToBounds = true
        
        referralsBtn.setAttributedTitle(NSAttributedString.generateFontAwesomeString(code: AwesomeButtonCodes.referralsButton.rawValue, size: 25), for: .normal)
        
        exchangeListBtn.layer.cornerRadius = 5
        exchangeListBtn.clipsToBounds = true
        
        exchangeListBtn.setAttributedTitle(NSAttributedString.generateFontAwesomeString(code: AwesomeButtonCodes.exchangeList.rawValue, size: 25), for: .normal)
        referralsBtn.layer.cornerRadius = 5
        referralsBtn.clipsToBounds = true

        socialBtn.setAttributedTitle(NSAttributedString.generateFontAwesomeString(code: AwesomeButtonCodes.socialIcon.rawValue, size: 30), for: .normal)
        pictureBtn.setAttributedTitle(NSAttributedString.generateFontAwesomeString(code: AwesomeButtonCodes.pictureIcon.rawValue, size: 30), for: .normal)
        historyBtn.setAttributedTitle(NSAttributedString.generateFontAwesomeString(code: AwesomeButtonCodes.historyIcon.rawValue, size: 30), for: .normal)
        listBtn.setAttributedTitle(NSAttributedString.generateFontAwesomeString(code: AwesomeButtonCodes.listIcon.rawValue, size: 30), for: .normal)
        
        let image = UIImage(named: "social-icon")?.imageWithSize(CGSize(width: 30, height: 30))
        socialsBtn.setImage(image!.withTintColor(.primaryRedColor()), for: .normal)
        
        marketMenuBtn.setAttributedTitle(NSAttributedString.generateFontAwesomeString(code: AwesomeButtonCodes.marketButton.rawValue, size: 30), for: .normal)
        
        chatBtn.setAttributedTitle(NSAttributedString.generateFontAwesomeString(code: AwesomeButtonCodes.chatIcon.rawValue, size: 30), for: .normal)
        
        videoTutorialBtn.setImage(UIImage(systemName: "questionmark")?.imageWithSize(CGSize(width: 30, height: 30))?.withTintColor(.primaryRedColor()), for: .normal)
        
    }
    
    @IBAction func gaugeButtonTapped(_ sender: Any) {
        openResourceCreditsPopUp()
    }
    
    
    @IBAction func onTrophyButtonTapped(_ sender: Any) {
        
        openUserRankPopUp()
    }
    
    @IBAction func settingstapped(_ sender: Any) {
        if User.current() != nil {
            self.navigationController?.pushViewController(SettingsVC.instantiateWithStoryboard(appStoryboard: .SB_Main), animated: true)
        } else {
            showToast(message: "Please login first")
        }
        
    }
    
    @IBAction func notificationsTapped(_ sender: Any) {
        openNotificationScreen()
    }
    
    @IBAction func walletTapped(_ sender: Any) {
        if User.current()?.steemit_username != nil {
            navigationController?.pushViewController(WalletVC.instantiateWithStoryboard(appStoryboard: .SB_Main), animated: true)
        } else {
            showToast(message: "Please login first")
        }
    }
    
    @IBAction func marketPlaceBtnTapped(_ sender: Any) {
        openPopup(title: NSLocalizedString("virtual_gadgets", comment: ""), description: NSLocalizedString("virtual_gadgets_details", comment: ""), cancelTitle: NSLocalizedString("close_upper", comment: ""), actionTitle: NSLocalizedString("market", comment: ""), size: .medium)
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
    
    
    func UserImage() {
        var  strImageUrl  = ""
        if let strUserName = User.current()?.steemit_username, strUserName != "" {
            let finalUserName = strUserName.replacingOccurrences(of: "@", with: "")
            strImageUrl = "https://images.hive.blog/u/" + finalUserName + "/avatar"
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
                        self.userImage.isHidden = true
                    }
                }
            }).resume()
            
        } else{
            
            
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
        let greenColor = UIColor.primaryGreenColor()
        let textColor = UIColor.primaryRedColor()
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
        
        let color1 = UIColor.primaryRedColor()
        let color2 = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        let greenColor = UIColor.primaryGreenColor()
        
        if initialStepCount > 5000 {
            colors.append(color2)
            colors.append(greenColor)
        } else {
            
            colors.append(color1)
            colors.append(color2)
            colors.append(color2)
        }
        pieChartDataSet.colors = colors
    }
    
    
    
    func displayUserAndRank(){
        let comparingDate = Date().dateString()
        todayDate.text =  Date().getTodaysDateWithMonthAndDay()
        let lastRankRequest = UserDefaults.standard.string(forKey: "rankLastRequest")?.date()
        var fetchNewRankVal = false
        if lastRankRequest == nil || UserDefaults.standard.string(forKey: "rank") == nil{
            fetchNewRankVal = true
        }else if comparingDate.date()! > lastRankRequest! {
            fetchNewRankVal = true
        }
        if fetchNewRankVal == false {
            
            self.rank.text = UserDefaults.standard.string(forKey: "rank")
            if let currentUser =  User.current() {
                username.isHidden = false
                self.username.text = currentUser.steemit_username
            } else {
                username.isHidden = true
                
            }
            
            
            return
        }
        if let currentUser =  User.current() {
            if currentUser.steemit_username == "" {
                return
            }
            UserDefaults.standard.set(comparingDate, forKey: "rankLastRequest")
            APIMaster.getRank(username: currentUser.steemit_username,completion: { (response, _ ) in
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
                       
                    }
                }
            }, failure: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute:  {
            self.scaleEarnButton()
        })
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.scalePrizeButton()
        })
        self.navigationController?.isNavigationBarHidden = true
        self.checkAuthorizationStatusAndStartTracking()
        displayUserAndRank()
        everyDayChart()
        UserImage()
        // TimeInterval()
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
          
            if self.checkIfCanPost() == false {
                self.stopPostButtonScaling()
            }
        })
      
       // scaleButton()
    }
    
    func everyDayChart()  {
        self.entries.removeAll()
        self.labels.removeAll()
        var i:Int = history.count - 1
       // var _:Int = historyFifteenMinute.count
        for tempData in history{
            var tempLabel = tempData.date.dateString()
            if !labels.contains(tempLabel){
                labels.append(tempLabel)
                entries.append(BarChartDataEntry(x: Double(i), y: Double(tempData.steps)))
                i -= 1
            }
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
        xAxis.valueFormatter = DayAxisValueFormatter(chart: datebarChart, labels: labels) as AxisValueFormatter



        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.minimumFractionDigits = 0
        leftAxisFormatter.maximumFractionDigits = 1
        leftAxisFormatter.negativeSuffix = ""
        leftAxisFormatter.positiveSuffix = ""


        let line = ChartLimitLine(limit: 5000, label: "Min Reward - 5K Activity")
        line.lineColor = .primaryRedColor()
        line.valueTextColor = .black
        line.valueFont = .systemFont(ofSize: 10)
        line.lineWidth = 1

        let line2 = ChartLimitLine(limit: 10000, label: "Min Reward - 10K Activity")
        line2.lineColor = .primaryGreenColor()
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
        
        for _ in  self.stepsArray{
            let dateFormatter = DateFormatter()
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "hh:mm"
            
            
            
            entriesFifteenMinuteIntervel.append(BarChartDataEntry(x: Double(i), y: stepsArray[i]))
            i -= 1
            
        }
        labels.reverse()
        entriesFifteenMinuteIntervel.reverse()
//        print(labels)
//        print(entriesFifteenMinuteIntervel)
        let xAxis = dailybarChart.xAxis
        xAxis.labelPosition = .top
        xAxis.labelFont = .systemFont(ofSize: 8)
        xAxis.granularityEnabled = true
        xAxis.granularity = 0.5
        xAxis.labelCount = 96
        xAxis.spaceMax = 73.0
      //  xAxis.valueFormatter = IndexAxisValueFormatter(values: labels)
        
        
        
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
       // dailybarChart.zoom(scaleX: 0, scaleY: 0, x: 0, y: 0)
        //dailybarChart.zoom(scaleX: 10, scaleY: 0, x: 0, y: 0)
//        dailybarChart.zoom(scaleX: 0, scaleY: 0, x: 0, y: 0)
//        dailybarChart.zoom(scaleX: 10, scaleY: 0, x: 0, y: 0)
//              dailybarChart.setScaleMinima(10.0, scaleY: 0.0)
        
//        if entriesFifteenMinuteIntervel.count > 20{
//            dailybarChart.zoom(scaleX: 7.0, scaleY: 0, x: 0, y: 0)
//                   dailybarChart.setScaleMinima(6.0, scaleY: 0.0)
//               }else if entriesFifteenMinuteIntervel.count > 15{
//            dailybarChart.zoom(scaleX: 5.0, scaleY: 0, x: 0, y: 0)
//            // dailybarChart.setScaleMinima(4.0, scaleY: 0.0)
//        }else if entriesFifteenMinuteIntervel.count >= 7{
//                   dailybarChart.zoom(scaleX: 3.5, scaleY: 0, x: 0, y: 0)
//              //      dailybarChart.setScaleMinima(3.0, scaleY: 0.0)
//               }else if entriesFifteenMinuteIntervel.count > 5{
//                   dailybarChart.zoom(scaleX: 1.5, scaleY: 0, x: 0, y: 0)
//            //dailybarChart.setScaleMinima(1.5, scaleY: 0.0)
//               }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopPostButtonScaling()
        stopPrizeButtonScaling()
        //resetting total steps count(of global variable) from midnight to 0
        //self.upToPreviousSessionStepsfromTodayMidnight = 0
        //self.onStop()
    }
    
    //MARK: INTERFACE BUILDER ACTIONS
    
    
    private func checkIfCanPost() -> Bool {
        var canPost = false
        if let user = User.current() {
            let calender = Calendar.autoupdatingCurrent
            canPost = !(calender.isDateInToday(user.last_post_date))
        }
        return canPost
    }
    
    
    @IBAction func postToSteemitBtnAction(_ sender : UIButton) {
        var userCanPost = true
        if let currentUser =  User.current() {
            let calender = Calendar.autoupdatingCurrent
            userCanPost = !(calender.isDateInToday(currentUser.last_post_date))
        } else {
            showToast(message: "Please login first")
            return
        }
        if userCanPost {
            let postToSteemitVC : PostToSteemitVC = PostToSteemitVC.instantiateWithStoryboard(appStoryboard: .SB_Main) as! PostToSteemitVC
            self.navigationController?.pushViewController(postToSteemitVC, animated: true)
        } else {
            self.showAlertWith(title: nil, message: Messages.one_post_per_day_error)
        }
    }
    
    
    
    
     func snapPicBtnAction() {
        checkCameraAuthorizationStatus()
    }
    
     func viewTrackingHistoryAction() {
        self.navigationController?.pushViewController(TrackingHistoryVC.instantiateWithStoryboard(appStoryboard: .SB_Main), animated: true)
    }
    
     func viewDailyLeaderboardAction() {
        self.navigationController?.pushViewController(DailyLeaderBoardBVC.instantiateWithStoryboard(appStoryboard: .SB_Main), animated: true)
        
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.checkAuthorizationStatusAndStartTracking()
            }
        } else {
            self.checkAuthorizationStatusAndStartTracking()
        }
    }
    
    
    
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
                    if self?.initialStepCount != totalSteps {
                        self?.initialStepCount =  totalSteps
                        self?.showStepsCount(count: totalSteps)
//
                        self?.saveCurrentStepsCounts(steps: totalSteps, midnightStartDate: AppDelegate.todayStartDate())
                        NotificationCenter.default.post(name: Notification.Name.init(StepsUpdatedNotification), object: nil, userInfo: ["steps" : totalSteps])
                    }
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
    
    
    // Mark: This function is making performance problems
    @objc func queryAndUpdateDatafromMidnightFifteenMinute() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let calender = Calendar.autoupdatingCurrent
        if !(calender.isDateInToday(startDate)) {
            //self.showStepsCount(count: 0)
          //  self.checkAuthorizationStatusAndStartTracking()
        } else {
          //  let backgroundQueue = DispatchQueue(label: "com.yourapp.backgroundQueue")
            serialQueue.async {
                let date12 = Date().dateString()
                for index in 0..<self.timeSlot.count - 1 {
                    let startdate  = self.timeSlot[index]
                    let endDate  = self.timeSlot[index + 1]

                    let sDate = date12 +  " \(startdate)"
                    let eDate = date12 +  " \(endDate)"
                    let date1  =  dateFormatter.date(from: sDate)
                    let date2 =  dateFormatter.date(from: eDate)
                    if let date1New = date1 {
                        if let date2New = date2 {
                            self.pedometer.queryPedometerData(from: date1New, to: date2New) {
                                [weak self] pedometerData, error in
                                guard let pedometerData = pedometerData, error == nil else { return }
                               // print("\(pedometerData.numberOfSteps.intValue) steps")
                                if pedometerData.numberOfSteps.intValue != 0 {
                                    DispatchQueue.main.sync {
                                        let totalSteps = pedometerData.numberOfSteps.intValue
                                      //  print(totalSteps)
                                        let today = Date().dateString()
                                        self?.saveAfterFifteenMinute(steps: totalSteps, midnightStartDate: today, timeInterval:  endDate, id: index)
                                    }
                                } else {
                                    return
                                }
                            }
                        }
                    }

                }
            }
        }
       // self.barEntry()
    }
    
}

extension ActivityTrackingVC {
    
    //on start event handler
    private func checkAuthorizationStatusAndStartTracking() {
        //resetting the start date when wiew appears
        self.startDate = Date()
        checkAuthorizationStatus()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.startUpdating()
        })
       
    }
    
    //on stop event handler
    private func onStop() {
        stopUpdating()
    }
    
    //stop updating user activity
    private func stopUpdating() {
        activityManager.stopActivityUpdates()
        pedometer.stopUpdates()
        pedometer.stopEventUpdates()
    
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
        switch CMMotionActivityManager.authorizationStatus() {
        case CMAuthorizationStatus.denied:
            onStop()
            stepsCountLabel.text = "Not available"
        default:break
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
    private func saveAfterFifteenMinute(steps : Int, midnightStartDate : String, timeInterval:String, id:Int) {
        if !ActivityFifteenMinutesInterval.all().filter({$0.id == id && $0.steps == steps}).isEmpty {
            return
        }
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
            

            
            let allsavedRecordsOfHistory = AllRecordsOfActivitiesNew.all()
            
            let arrayOfActivities = ActivityFifteenMinutesInterval.all()
            let allRecordsOfActivitiesNew = AllRecordsOfActivitiesNew()
            allRecordsOfActivitiesNew.date = midnightStartDate
            //allRecordsOfActivitiesNew.activities.append(objectsIn: arrayOfActivities)
            //            let dataToSave = NSKeyedArchiver.archivedData(withRootObject: arrayOfActivities)
            let encoder = JSONEncoder()
            let encodedData: Data? = try? encoder.encode(arrayOfActivities)
            
            allRecordsOfActivitiesNew.activitiesListData = encodedData
            
            //TEST
            if let activityInHistory = allsavedRecordsOfHistory.first(where: {$0.date == midnightStartDate}){
                
                try! realm.write {
                    activityInHistory.activitiesListData = allRecordsOfActivitiesNew.activitiesListData
                }
                
            } else {
                let activityToSave = ["id":allsavedRecordsOfHistory.count+1,"date": midnightStartDate, "activitiesListData":allRecordsOfActivitiesNew.activitiesListData] as [String : Any]
                allRecordsOfActivitiesNew.saveWith(info: activityToSave)
            }
            //TEST
            
            if id == timeSlot.count - 2{
                
                self.historyFifteenMinute = ActivityFifteenMinutesInterval.all()
              //  self.barEntry()
                self.history = Activity.allWithoutCountZero()
                self.everyDayChart()
           }
        } catch let error as NSError {
            print("Error Occured")
        }
        
    }
    

    
    //tracks different types of user activity state
    private func startTrackingActivityType() {
        activityManager.startActivityUpdates(to: OperationQueue.main) { [weak self]
            (activity: CMMotionActivity?) in
            guard let self = self, let activity = activity else { return }
            DispatchQueue.main.async {
                if activity.walking {
                    print("Walking")
                    self.startQueryingActivityEveryTwoSecond()
                } else if activity.stationary {
                    print("Stationary")
                } else if activity.running {
                    print("Running")
                    self.startQueryingActivityEveryTwoSecond()
                } else if activity.automotive {
                    print("Automotive")
                }
            }
        }
    }
    
    //ask pedometer to start updating the user data on regular basis
    private func startQueryingActivityEveryTwoSecond() {
   
      //  self.timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block: { (timer) in
            self.queryAndUpdateDatafromMidnight()
      //  })
       // self.timerAfterFifteen = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { (timer) in
            self.queryAndUpdateDatafromMidnightFifteenMinute()
      //  })
    }
    
    //show the user activity data on UI
    private func showStepsCount(count : Int) {
      //  self.queryAndUpdateDatafromMidnightFifteenMinute()
        self.pieChart(stepsCount: count)
       
       
        
      
        if UserDefaults.standard.bool(forKey: "isFitSystemSelected") == true{
            self.stepsCountLabel.text = "Fitbit Tracking Mode On"
            return
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        self.stepsCountLabel.text = "Total Activity Today: " + (formatter.string(from: NSNumber(value: Int(count))) ?? "")
        
//        self.checkAndPostNotification(count: count)
//        self.historyFifteenMinute = ActivityFifteenMinutesInterval.all()
//        self.history = Activity.allWithoutCountZero()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
//            self.everyDayChart()
//        })
//
//        self.history = Activity.allWithoutCountZero()
//        self.everyDayChart()

        
       // self.checkAndPostNotification(count: count)
        self.historyFifteenMinute = ActivityFifteenMinutesInterval.all()
        self.history = Activity.allWithoutCountZero()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.barEntry()
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5, execute: {
            
            self.everyDayChart()
        })
    
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
    
    
    
    func barEntry() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "HH:mm"

        let date12 = Date().dateString()
        var dailyLabels = [String]()
        var entriesFifteenMinuteIntervel = [BarChartDataEntry]()
        
        let timeSlot: [String] = {
            var labels = [String](repeating: String(), count: 96)
            for indHr in 0..<24 {
                for indMin in 0..<4 {
                    let slotLabel = String(format: "%02d:%02d", indHr, indMin * 15)
                    labels[indHr * 4 + indMin] = slotLabel
                }
            }
            return labels
        }()
        self.timeSlot = timeSlot

        let backgroundQueue = DispatchQueue(label: "com.yourapp.backgroundQueue")
        backgroundQueue.async {
            var k = timeSlot.count - 1

            for slotLabel in timeSlot {
                let contents = ActivityFifteenMinutesInterval.all().filter { $0.date == Date().getTodaysDateYearAndMonthAndDay() && $0.interval == slotLabel }
                
                if !contents.isEmpty && contents[0].steps > 0 {
                    let time2 = slotLabel.replacingOccurrences(of: ":", with: ".")
                    entriesFifteenMinuteIntervel.append(BarChartDataEntry(x: Double(time2)! * 4.0, y: Double(contents[0].steps)))
                }

                k -= 1
            }

            DispatchQueue.main.async { [self] in
                let xAxis = dailybarChart.xAxis
                xAxis.labelPosition = .top
                xAxis.labelFont = .systemFont(ofSize: 8)
                xAxis.granularityEnabled = true
                xAxis.granularity = 1.0
                xAxis.labelCount = 96
                xAxis.valueFormatter = IndexAxisValueFormatter(values: timeSlot)

                // ... Rest of your chart setup ...

                let set1 = BarChartDataSet(entries: entriesFifteenMinuteIntervel, label: "Today Activity Details")
                let data = BarChartData(dataSet: set1)
                data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 8)!)
                data.barWidth = 0.1
                dailybarChart.data = data
            }
          
        }
        dailybarChart.setScaleMinima(1.5, scaleY: 0.0)
    }


    
//    func barEntry()  {
//        var data_id = 0
//        let indHr = Int()
//        let indMin = Int()
//        let hoursInDay = 24;
//        let minInt = [0,15,30,45]
//        let minSlots = minInt.count
//
//        var labels = [String](repeating: String(), count: hoursInDay * minSlots)
//        entriesFifteenMinuteIntervel    = []
//        dailyLabels                     = []
//        // String[] labels = new String[hoursInDay * minSlots];
//        //loop through whole day as hours
//        for indHr in 0..<hoursInDay
//        {
//            for indMin in indMin..<minSlots{
//                var slotLabel = "" + "\(indHr)";
//                if indHr < 10 {
//                    slotLabel =  "0" + "\(indHr)";
//                }
//                labels[data_id] = slotLabel + ":";
//                if (minInt[indMin] < 10) {
//                    slotLabel +=  "\(minInt[indMin])";
//                    labels[data_id] +=  "0" + "\(minInt[indMin])";
//                } else {
//                    slotLabel += "\(minInt[indMin])";
//                    labels[data_id] += "\(minInt[indMin])";
//                }
//                data_id += 1;
//
//            }
//            timeSlot = labels
//        }
//        var k:Int = timeSlot.count - 1
//        for i in  timeSlot {
//
//
//            let dateFormatter = DateFormatter()
//            dateFormatter.locale = NSLocale.current
//            dateFormatter.dateFormat = "HH:mm"
//            let tempLabel = dateFormatter.date(from: i)
//
//            if tempLabel == nil{
//                dailyLabels.append("00:00")
//            }else{
//                let temp  =  dateFormatter.string(from: tempLabel!)
//                dailyLabels.append(temp)
//            }
//
//            var step = i
//            var contents = [ActivityFifteenMinutesInterval]()
//            let dataList = ActivityFifteenMinutesInterval.all().filter{$0.date ==  Date().getTodaysDateYearAndMonthAndDay()}
//
//            //print(dataList)
//            step = step.replacingOccurrences(of: ":", with: ".")
//
//            //let time = TimeSlot[k].replacingOccurrences(of: ":", with: ".")
//            contents = dataList.filter({$0.interval == i})
//
//            if !contents.isEmpty {
//                if (contents[0].steps) > 0{
//                    //                print(contents[0].steps)
//                    let time2 = contents[0].interval.replacingOccurrences(of: ":", with: ".")
//                    entriesFifteenMinuteIntervel.append(BarChartDataEntry(x: Double(time2)! * 4.02, y: Double(contents[0].steps)))
//                }
//
//            }
//
//
//            k = k - 1
//        }
////
//
//        let xAxis = dailybarChart.xAxis
//        xAxis.labelPosition = .top
//        xAxis.labelFont = .systemFont(ofSize: 8)
//        xAxis.granularityEnabled = true
//        xAxis.granularity = 1.0
//        xAxis.labelCount = 96
//        xAxis.valueFormatter = IndexAxisValueFormatter(values: dailyLabels)
//
//        let leftAxisFormatter = NumberFormatter()
//        leftAxisFormatter.minimumFractionDigits = 0
//        leftAxisFormatter.maximumFractionDigits = 1
//        leftAxisFormatter.negativeSuffix = ""
//        leftAxisFormatter.positiveSuffix = ""
//
//        let leftAxis = dailybarChart.leftAxis
//        leftAxis.labelFont = .systemFont(ofSize: 8)
//        leftAxis.labelCount = 8
//        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
//        leftAxis.labelPosition = .outsideChart
//        leftAxis.spaceTop = 0.15
//        leftAxis.axisMinimum = 0
////
//        let rightAxis = dailybarChart.rightAxis
//        rightAxis.enabled = true
//        rightAxis.labelFont = .systemFont(ofSize: 8)
//        rightAxis.labelCount = 8
//        rightAxis.valueFormatter = leftAxis.valueFormatter
//        rightAxis.spaceTop = 0.15
//        rightAxis.axisMinimum = 0
////
//        dailybarChart.delegate = self
//        let set1 = BarChartDataSet(entries: entriesFifteenMinuteIntervel, label: "Today Activity Details")
//        let data = BarChartData(dataSet: set1)
//        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 8)!)
//        data.barWidth = 0.1
//        dailybarChart.data = data
////        if entriesFifteenMinuteIntervel.count > 20{
////            dailybarChart.zoom(scaleX: 7.0, scaleY: 0, x: 0, y: 0)
////            dailybarChart.setScaleMinima(6.0, scaleY: 0.0)
////        }else if entriesFifteenMinuteIntervel.count > 15{
////            dailybarChart.zoom(scaleX: 5.0, scaleY: 0, x: 0, y: 0)
////            // dailybarChart.setScaleMinima(4.0, scaleY: 0.0)
////        }else if entriesFifteenMinuteIntervel.count >= 7{
////            dailybarChart.zoom(scaleX: 3.5, scaleY: 0, x: 0, y: 0)
////            //      dailybarChart.setScaleMinima(3.0, scaleY: 0.0)
////        }else if entriesFifteenMinuteIntervel.count > 5{
////            dailybarChart.zoom(scaleX: 1.5, scaleY: 0, x: 0, y: 0)
////            //dailybarChart.setScaleMinima(1.5, scaleY: 0.0)
////        }
////
//    }
    
}


extension ActivityTrackingVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bannerImages.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerImageCell", for: indexPath) as? BannerImageCell
        cell?.bannerObject = bannerImages[indexPath.row]
        cell?.onGradientTap =  { [weak self] url in
            guard let self = self else { return }
            self.present(SFSafariViewController(url: URL(string: url ?? "")!), animated: true)
        }
        return cell!
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(scrollView == gadgetScrollView) {
            
        } else {
            // Calculate the current page based on the collection view's content offset
            let pageWidth = collectionVIew.frame.width
            let currentPage = Int((scrollView.contentOffset.x + pageWidth / 1.5) / pageWidth)
            
            // Update the current page in the page control
            pageControl.currentPage = currentPage
        }
    }
    
    
    
}

extension Double {
    static func parse(from string: String) -> Double? {
        let decimalDigits = CharacterSet(charactersIn: "0123456789.")
        let cleanedString = string.components(separatedBy: decimalDigits.inverted).joined()
        return Double(cleanedString)
    }
}



struct TimeSlot {
    var hour: Int
    var minute: Int
}
