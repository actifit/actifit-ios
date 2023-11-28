//
//  AdsViewController.swift
//  Actifit
//
//  Created by Ali Jaber on 15/08/2023.
//

import GoogleMobileAds
import UIKit
import UserMessagingPlatform

class AdsViewController: UIViewController {
    private var isAdCompleted = false
    var userName: String!
    var rewardValue: String!
    var buttonText: String!
    var tier: Int = 1
    var prizeType: PrizeButtonType!
    var rewardAmount = "0.0"
    var rewardedAd: GADRewardedAd?
    var serverSideVerification: GADServerSideVerificationOptions?
    var onAdCompletion: ((Bool, PrizeButtonType, String) -> ())?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let parameters = UMPRequestParameters()
        parameters.tagForUnderAgeOfConsent = false
        UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: parameters) {[weak self] error in
            guard let self = self else { return }
            if let consentError = error {
                 // Consent gathering failed.
                 return print("Error: \(consentError.localizedDescription)")
            }
            
            
            UMPConsentForm.loadAndPresentIfRequired(from: self) {
                [weak self] loadAndPresentError in
                guard let self = self else { return }
                if let consentError = loadAndPresentError {
                          // Consent gathering failed.
                          return print("Error: \(consentError.localizedDescription)")
                    }
                if UMPConsentInformation.sharedInstance.canRequestAds {
                    self.gadServerVerification()
                }
            }
           
        }
      
    }

    func checkUMPConsentForm() {
        
    }

  func loadRewardedAd() {
      if let ad = rewardedAd {
          ad.fullScreenContentDelegate = self
      
          ad.present(fromRootViewController: self) {
           

              self.isAdCompleted = true
          }
//          ad.present(fromRootViewController: self, userDidEarnRewardHandler: { [weak self] reward in
//
//
//
//          })
      } else {
          let request = GAMRequest()
          GADRewardedAd.load(withAdUnitID:"ca-app-pub-xxxxxxxxxxxx/xxxxxxx",//"/6499/example/rewarded",
                             request: request,
                             completionHandler: { [self] ad, error in
              if let error = error {
                  print("Failed to load rewarded ad with error: \(error.localizedDescription)")
                  dismiss(animated: true)
                  return
              }
              rewardedAd = ad
              print("Rewarded ad loaded.")
              rewardedAd?.fullScreenContentDelegate = self
              ad?.present(fromRootViewController: self, userDidEarnRewardHandler: { [weak self] in
                //  self?.gadServerVerification(ad: self?.rewardedAd)
                  self?.isAdCompleted = true
              })
          }
          )
      }
  }
    
    func generateRewardValue(reward: PrizeButtonType) -> String {
        var total = 0.0
        switch reward {
        case .free: total =  ApplicationHelper.generateAndFindMin(minValue: 0.01 , maxValue: 3.0)
           
        case .five: total =  ApplicationHelper.generateAndFindMin(minValue: 0.01, maxValue: 5.0)
           
        case .seven: total =  ApplicationHelper.generateAndFindMin(minValue: 0.01, maxValue: 7.0)
           
        case .ten: total =  ApplicationHelper.generateAndFindMin(minValue: 0.01, maxValue: 10.0)
          
        default: return String(total)
        }
        return String(total)
    }
    
    func gadServerVerification() {
        if let buttonTitle = buttonText {
            guard rewardedAd != nil else  { return }
            rewardAmount = generateRewardValue(reward: prizeType)
            switch prizeType {
            case .close:
                break;
            case .free:
                UserDefaults.standard.freeReward = rewardAmount
            case .five:
                UserDefaults.standard.fiveKReward = rewardAmount
            case .seven:
                UserDefaults.standard.sevenKReward = rewardAmount
            case .ten:
                UserDefaults.standard.tenKReward = rewardAmount
            case .none:
                break
            }
            let options = GADServerSideVerificationOptions()
            let rewardString = "\(userName!)_\(rewardAmount)_\(tier)_\(buttonTitle)"
            let encodedReward = rewardString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            options.customRewardString = encodedReward
            rewardedAd!.serverSideVerificationOptions = options
            loadRewardedAd()
        }
    }
}//vevita_1.227_2_Free Reward

extension AdsViewController:  GADFullScreenContentDelegate {
    

    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
       print("Ad will present full screen content.")
     }

     /// Tells the delegate that the ad dismissed full screen content.
     func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        
       print("Ad did dismiss full screen content.")
         dismiss(animated: true) {
             self.onAdCompletion?(self.isAdCompleted, self.prizeType, self.rewardAmount)
         }
     }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
        switch prizeType {
        case .free: UserDefaults.standard.freeReward = ""
        case .five:  UserDefaults.standard.fiveKReward = ""
        case .seven: UserDefaults.standard.sevenKReward = ""
        case .ten: UserDefaults.standard.tenKReward = ""
        default: break
        }
        dismiss(animated: true) {
            self.onAdCompletion?(false, self.prizeType, self.rewardAmount)
        }
    }
    

    
    
}
