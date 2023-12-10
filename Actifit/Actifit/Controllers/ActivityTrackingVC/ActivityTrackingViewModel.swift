//
//  ActivityTrackingViewModel.swift
//  Actifit
//
//  Created by Ali Jaber on 21/07/2023.
//

import Foundation
import Combine
import UIKit
import GoogleMobileAds
class ActivityTrackingViewModel {
    var googleAd: GADRewardedAd?
    private let cancellables = Set<AnyCancellable>()
    private let loaderSubject = PassthroughSubject<Bool, Never>()
    var blurtObject: Blurt?
    var afitTokenObject: AfitTokenModel?
    var dailyTips: [DailyTipsModel] = []
    var activeGadgetUserData: [ActiveGadgeByUser] = []
    var products: [Product] = []
    var gadgetsList: [GadgetImageObject] = []
    var statusModel: VotingStatusModel?
    var surveysArray: [SurveyModel] = []
    
    private let pollSurveySubject = PassthroughSubject<SurveyModel, Never>()
    var pollSurveryPublisher: AnyPublisher<SurveyModel, Never> {
        return pollSurveySubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    var loaderVisibilityPublisher: AnyPublisher<Bool, Never> {
        return loaderSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    
    private let percentageSubscriber = PassthroughSubject<String, Never> ()
    var percentagePublisher: AnyPublisher<String, Never> {
        return percentageSubscriber.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    
    private let bannerImagesSubject = PassthroughSubject<[BannerImageModel], Never> ()
    var bannerImagesPublisher: AnyPublisher<[BannerImageModel], Never> {
        return bannerImagesSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    
    private let votingStatus = PassthroughSubject<VotingStatusModel, Never>()
    var votingStatusPublisher: AnyPublisher<VotingStatusModel, Never> {
        return votingStatus.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    
    private let afitTokenSubject = PassthroughSubject<AfitTokenModel, Never>()
    var afitTokenPublisher: AnyPublisher<AfitTokenModel,Never> {
        return afitTokenSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    
    private let blurtSubject = PassthroughSubject<Bool, Never>()
    var blurtPublisher: AnyPublisher<Bool, Never> {
        return blurtSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    private let dailyTipSubscriber = PassthroughSubject<[DailyTipsModel], Never>()
    var dailyTipPublisher: AnyPublisher<[DailyTipsModel], Never> {
        return dailyTipSubscriber.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    private let gadgetSubscriber = PassthroughSubject<[GadgetImageObject], Never>()
    var gadgetPublisher: AnyPublisher<[GadgetImageObject], Never> {
        return gadgetSubscriber.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    
    private let chatBlinkingTriggerSubject = PassthroughSubject<Bool, Never> ()
    var chatBlinkingtriggerPublisher: AnyPublisher<Bool, Never> {
        return chatBlinkingTriggerSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    
    init() {
        loadAd()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.getNewsBannerAPI()
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.getVotingStatusAPI()
            self.getAfitTokens()
            self.getAccountData()
            self.getActiveGadgetsByUser()
         
            self.getNotificationCountAPI()
        })
        
        
        if UserDefaults.standard.showTips {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.getDailyTips()
            })
        } else {
            callSurveyAPI()
        }
        
        updateToken()
      
        
        
    }
    
    private func updateToken() {
        if let userName = User.current()?.steemit_username, let ppKey = User.current()?.private_posting_key {
            let dict = ["username": userName, "ppkey": ppKey, "bchain": "HIVE", "loginsource": "ios", "keeploggedin": "true"]
            APIMaster.checkLogin(info: dict) { info, statusCode in
                if let response = info as? String, statusCode != 400 {
                    let data = response.utf8Data()
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        if let jsonArray = (json as? NSDictionary){
                            UserDefaults.standard.setValue(jsonArray.value(forKey:"token"), forKey: "authToken")
                        }
                    }catch {
                        print("Failed to convert JSON string to pretty JSON: \(error)")
                    }
                  
                }
            } failure: { error in
                print(error.localizedDescription)
               }
        }
    }
    
    private func callSurveyAPI() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: {
            self.getSurveyPolls()
        })
    }
    
    private func loadAd() {
        GADRewardedAd.load(withAdUnitID: "ca-app-pub-2770948859841315/8644692724", request: GADRequest()) { ad, error in
            self.googleAd = ad
            
        }
    }
    
    private func checkNotificationDate(notification: ReadChatNotification?, statIndex: Int, newNotificationCount: Int) {
        guard  UserDefaults.standard.lastChatDateDisplay != "" else {
            chatBlinkingTriggerSubject.send(true)
            return
        }
        let lastLocalChat = UserDefaults.standard.lastChatDateDisplay
        
        if let dateDifferences =  Date().dateDifferenceByNumberOfDates(startDate: Date().getTodaysDateYearAndMonthAndDay(), endDate: UserDefaults.standard.lastChatDateDisplay) {
            if dateDifferences > 6 {
                print(dateDifferences)
                chatBlinkingTriggerSubject.send(true)
                return
               
            }
            
            
            
        }
      
        let lastDateFromAPI = Date.convertServerDateString(notification?.date ?? "") ?? ""
        if let dateDifferenceWithServer = Date().dateDifferenceByNumberOfDates(startDate: Date().getTodaysDateYearAndMonthAndDay(), endDate: UserDefaults.standard.lastChatDateDisplay) {
            if dateDifferenceWithServer == statIndex {
                if UserDefaults.standard.lastNotificationCount == newNotificationCount {
                    return
                } else {
                    chatBlinkingTriggerSubject.send(true)
                    UserDefaults.standard.lastNotificationCount = newNotificationCount
                }
            } else if statIndex < dateDifferenceWithServer {
                chatBlinkingTriggerSubject.send(true)
                UserDefaults.standard.lastNotificationCount = newNotificationCount
            } else {
                return
            }
            
            
        }

    }
    
    func getLastChatNotificationRead(statIndex: Int, newNotificationCount: Int) {
        guard let userName = User.current()?.steemit_username  else { return }
        API().getLastNotificationRead(userName: userName) { info, statusCode in
            if let response = info as? String {
                let data = response.utf8Data()
                do {
                    if var jsonArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [Any] {
                        jsonArray?.removeFirst()
                        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonArray!, options: []),
                           let decodedArray = try? JSONDecoder().decode([[ReadChatNotification]].self, from: jsonData) {
                            if decodedArray.isEmpty {
                                self.chatBlinkingTriggerSubject.send(true)
                            } else {
                                print(decodedArray)
                                self.checkNotificationDate(notification: decodedArray.flatMap{$0}.first, statIndex: statIndex, newNotificationCount: newNotificationCount)
                            }
                        }
                    }
                }
            }
        } failure: { error in
            print(error.localizedDescription)
        }
    }
    
    private func getNotificationCountAPI() {
        API().getNotificationStats { info, statusCode in
            if let response = info as? String {
                let data = response.utf8Data()
                do {
                    if var jsonArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [Any] {
                        jsonArray?.removeFirst()
                        if var list = jsonArray?.first as? [Any] {
                            if list.count > 1 {
                                list.removeLast()
                            }
                            if let jsonData = try? JSONSerialization.data(withJSONObject: list.first, options: []),
                               
                            let decodedArray = try? JSONDecoder().decode([ChatNotificationCount].self, from: jsonData) {
                                let reversedNotifications = Array(decodedArray.reversed())
                                var notificationCount = 0
                                for i in 0..<reversedNotifications.count {
                                    if reversedNotifications[i].hiveCommunity != nil && (reversedNotifications[i].hiveCommunity ?? 0) > 0 {
                                       // UserDefaults.standard.lastNotificationCount = reversedNotifications[i].hiveCommunity!
                                        self.getLastChatNotificationRead(statIndex: i, newNotificationCount: reversedNotifications[i].hiveCommunity!)
                                        return
                                    }
                                }
                            } else {
                                
                            }
                        }
                     
                    }
                }
            }
        } failure: { error in
            
        }

    }
    
    
    
    func getSurveyPolls() {
        guard  User.current() != nil else {return }
        API().getSurveys { info, statusCode in
            if let response = info as? String {
                let data = response.utf8Data()
                let decoder = JSONDecoder()
                do {
                    let surveys = try? decoder.decode([SurveyModel].self, from: data)
                    guard surveys?.isEmpty == false  else { return }
                    self.surveysArray = surveys ?? []
                    self.surveysArray.reverse()
                    self.checkValidSurveys(surveys: self.surveysArray)
                    return
                    
                    
                }
            }
        } failure: { error in
            
        }
        
    }

        
    
    func checkValidSurveys(surveys: [SurveyModel]) {
        guard let userName = User.current()?.steemit_username else {
            return
        }
        
        let dispatchGroup = DispatchGroup()
        var currentIndex = 0 // Track the current index in surveys
        
        func processSurvey(_ survey: SurveyModel, completion: @escaping (Bool) -> Void) {
            API().checkSurveyStatus(userName: userName, surveyId: survey.id ?? "") { info, statusCode in
                defer {
                    dispatchGroup.leave()
                    currentIndex += 1 // Move to the next survey regardless of the result
                    processNextSurvey() // Process the next survey
                }
                if let response = info as? String {
                    let data = response.utf8Data()
                    let decoder = JSONDecoder()
                    do {
                        let voteStatus = try decoder.decode(SurveyStatusModel.self, from: data)
                        if voteStatus.voted == false {
                            self.pollSurveySubject.send(survey)
                            completion(false)
                         
                        }
                    } catch {
                        // Handle decoding errors
                    }
                } else {
                    // Handle API response errors
                }
              
            } failure: { error in
                dispatchGroup.leave()
            }
        }
        
        func processNextSurvey() {
            if currentIndex < surveys.count {
                let survey = surveys[currentIndex]
                if survey.isValidSurvey() {
                    dispatchGroup.enter()
                    processSurvey(survey) { shouldContinue in
                        if shouldContinue {
                          // Move to the next survey if the current one is not valid
                            processNextSurvey() // Process the next survey
                        }
                    }
                } else {
                    currentIndex += 1 // Move to the next survey if the current one is not valid
                    processNextSurvey() // Process the next survey
                }
            }
        }
        
        // Start processing the first survey
        processNextSurvey()

        dispatchGroup.notify(queue: .main) {
            print("DONE")
        }
    }
    
    
    func getNewsBannerAPI() {
        self.loaderSubject.send(true)
        API().getNewsBanner { info, statusCode in
            if let response = info as? String {
                let data = response.utf8Data()
                let decoder = JSONDecoder()
                do {
                    let myData = try decoder.decode([BannerImageModel].self, from: data)
                    self.bannerImagesSubject.send(myData)
                    self.loaderSubject.send(false)
                    print(myData)
                }catch _ {
                    
                }
            }
        } failure: { error in
            self.loaderSubject.send(false)
        }
        
    }
    
    func setGiftButtonUnicodeImage() -> String {
        let unicodeValue = 127873
        let unicodeScalar = Unicode.Scalar(unicodeValue)!
        return String(unicodeScalar)
    }
    
    private func getVotingStatusAPI() {
        API().getVotingStatus { info, statusCode in
            if let response = info as? String {
                let data = response.utf8Data()
                let decoder = JSONDecoder()
                do {
                    self.statusModel = try decoder.decode(VotingStatusModel.self, from: data)
                    self.votingStatus.send(self.statusModel!)
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        } failure: { error in
            
        }
        
    }
    

    
    private func getPRPercentage() {
        guard let username = User.current()?.steemit_username else { return }
        API().getRCPercentage(completion: {info, statusCode in
            if let response = info as? String {
                let data = response.utf8Data()
                let decoder = JSONDecoder()
                do {
                    let percentageModel = try decoder.decode(RCPercentage.self, from: data)
                    print(percentageModel)
                    DispatchQueue.main.async {
                        
                        //TODO: send percentage
                        //  self?.percentageLabel.text = percentageModel.currentRCPercent ?? ""
                    }
                }
                catch {
                    print("Error decoding JSON: \(error.localizedDescription)")
                }
            }
        }, failure: { error in
            
        }, username: username)
    }
    
    private func getAccountData() {
        guard let username = User.current()?.steemit_username else { return }
        API().getAccountData(username: username) { info, statusCode in
            if let response = info as? String {
                print(response)
                let data = response.utf8Data()
                let decoder = JSONDecoder()
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    
                    // Check if the "BLURT" object exists in the JSON
                    if let blurtObject = json?["BLURT"] as? [String: Any] {
                        let blurtData = try JSONSerialization.data(withJSONObject: blurtObject, options: [])
                        let blurt = try decoder.decode(Blurt.self, from: blurtData)
                        print(blurt)
                        self.blurtObject = blurt;
                        self.blurtSubject.send((blurt.id != nil && (blurt.balanceWithoutNaming ?? 0) > 5) ? false : true)
                    } else {
                        self.blurtSubject.send(true)
                        print("No 'BLURT' object found in the JSON.")
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            }
            
        } failure: { error in
            print(error.localizedDescription)
        }
        
    }
    
    private func getAfitTokens() {
        guard let username = User.current()?.steemit_username else { return }
        API().getAfitBalance(username: username) { info, statusCode in
            if let response = info as? String {
                
                let data = response.utf8Data()
                let decoder = JSONDecoder()
                do {
                    print(data)
                    let afitModel = try decoder.decode(AfitTokenModel.self, from: data)
                    self.afitTokenObject = afitModel
                    self.afitTokenSubject.send(afitModel)
                    
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        } failure: { error in
            print(error.localizedDescription)
        }
        
    }
    
    private func getDailyTips() {
        API().getDailyTips { info, statusCode in
            if let response = info as? String {
                let data = response.utf8Data()
                let decoder = JSONDecoder()
                print(data)
                do {
                    let dailyTips = try decoder.decode([DailyTipsModel].self, from: data)
                    self.dailyTips = dailyTips
                    self.pickTip()
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        } failure: { error in
            print(error.localizedDescription)
        }
        
    }
    
    private func pickTip() {
        dailyTipSubscriber.send(dailyTips)
    }
    
    private func getProducts() {
        API().getProducts { info, statusCode in
            if let response = info as? String {
                let data = response.utf8Data()
                let decoder = JSONDecoder()
                do {
                    let products = try decoder.decode([Product].self, from: data)
                    self.products = products
                    self.getGatgetsURLS()
                } catch let error {
                    print(error.localizedDescription)
                }
            }
            } failure: { error in
                
            }
            
    }
    
    private func getGatgetsURLS() {
        activeGadgetUserData.forEach { element in
            if let product =  products.filter({$0.id == element.gadget}).first {
                gadgetsList.append(GadgetImageObject(imageURL: "https://actifit.io/img/gadgets/\(product.image ?? "")", gadgetsLevel: element.gadgetLevel ?? 0))
 //               imageURLArray.append("https://actifit.io/img/gadgets/\(product.image ?? "")")
            }
        }
        if !gadgetsList.isEmpty {
            Task {
                await loadImage()
                
            }
        } else {
            gadgetSubscriber.send(gadgetsList)
        }
    }
    
    
    func loadImage() async {
        for element in gadgetsList {
            do {
                let (data, _) = try await URLSession.shared.data(from: URL(string: element.imageURL)!)
                if let image = UIImage(data: data) {
                    element.setImage(receivedImage: image)
                }
            } catch {
                print("Error fetching image: \(error)")
            }
            
        }
        
        gadgetSubscriber.send(gadgetsList)
    }
    
    private func getActiveGadgetsByUser() {
        guard let username = User.current()?.steemit_username else { return }
        API().getActiveGadgetsByUser(username: username) { info, statusCode in
            if let response = info as? String {
                let data = response.utf8Data()
                let decoder = JSONDecoder()
               
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                    if let gadgetObject = json, let ownArray = gadgetObject["own"] as? [[String: Any]] {
                        let jsonData = try JSONSerialization.data(withJSONObject: ownArray)
                        let gadgetData = try decoder.decode([ActiveGadgeByUser].self, from: jsonData)
                        self.activeGadgetUserData =  gadgetData
                        self.getProducts()
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        } failure: { error in
            
            
        }
    }
}


class GadgetImageObject {
    let imageURL: String
    let gadgetsLevel: Int
    var image: UIImage?
    init(imageURL: String, gadgetsLevel: Int) {
        self.imageURL = imageURL
        self.gadgetsLevel = gadgetsLevel
    }
    
     func setImage(receivedImage: UIImage) {
        image = receivedImage
    }
}
