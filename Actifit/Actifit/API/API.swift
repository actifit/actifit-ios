//
//  API.swift
//  Actifit
//
//  Created by Hitender kumar on 15/08/18.
//  Copyright © 2018 actifit.io. All rights reserved.
//

import Foundation

typealias APICompletionHandler = ((_ info : Any?,_ statusCode: Int? ) -> ())?
typealias APIFailureHandler = ((_ error : NSError) -> ())?

public class API : NSObject{
    
    //MARK: Initializers
    
    override init() {
    }
    
    class var sharedInstance : API {
        return API()
    }
    
    
    func getLastNotificationRead(userName: String, completion: APICompletionHandler, failure: APIFailureHandler) {
        let url = URL(string: ApiUrls.notificationRead + userName)
        var request = URLRequest.init(url: url!)
        request.addBasicHeaderFieldsForUpdateSettings()
        forwardRequest(request: request, httpMethod: HttpMethods.HttpMethod_GET, completion: completion, failure: failure)
    }
    
    func getNotificationStats(completion: APICompletionHandler, failure: APIFailureHandler) {
        let url = URL(string: ApiUrls.notificationStats)
        var request = URLRequest.init(url: url!)
        request.addBasicHeaderFieldsForUpdateSettings()
        forwardRequest(request: request, httpMethod: HttpMethods.HttpMethod_GET, completion: completion, failure: failure)
    }
    
    
    func castSurveyVoice(userName: String, surveyId: String, option: String,completion: APICompletionHandler, failure: APIFailureHandler) {
        let url = URL(string: ApiUrls.castSurveyURL + "user=\(userName)&id=\(surveyId)&option=\(option)")
        var request = URLRequest.init(url: url!)
        request.addBasicHeaderFieldsForUpdateSettings()
        forwardRequest(request: request, httpMethod: HttpMethods.HttpMethod_GET, completion: completion, failure: failure)
    }
    
    func checkSurveyStatus(userName: String, surveyId: String, completion: APICompletionHandler, failure: APIFailureHandler) {
        let url = URL(string: ApiUrls.surveyStatusURL + "user=\(userName)&id=\(surveyId)")
        var request = URLRequest.init(url: url!)
        request.addBasicHeaderFields()
        forwardRequest(request: request, httpMethod: HttpMethods.HttpMethod_GET, completion: completion, failure: failure)
    }
    
    func getSurveys(completion: APICompletionHandler, failure: APIFailureHandler){
        let url = URL(string: ApiUrls.surveysURL)
        var request = URLRequest.init(url: url!)
        request.addBasicHeaderFields()
        forwardRequest(request: request, httpMethod: HttpMethods.HttpMethod_GET, completion: completion, failure: failure)
    }
    
    func getVideoTutorial(completion: APICompletionHandler, failure: APIFailureHandler) {
        let url = URL(string: ApiUrls.videoTutorial)
        var request = URLRequest.init(url: url!)
        request.addBasicHeaderFields()
        forwardRequest(request: request, httpMethod: HttpMethods.HttpMethod_GET, completion: completion, failure: failure)
    }
    
    func registerNotification(info: [String:Any],completion: APICompletionHandler, failure: APIFailureHandler) {
        let url = URL(string: ApiUrls.registerPushNotification)
        var request = URLRequest.init(url: url!)
        request.addBasicHeaderFields()
        request.appendBodyWith(json: info)
        forwardRequest(request: request, httpMethod: HttpMethods.HttpMethod_POST, completion: completion, failure: failure)
    }
    
    func getMarketExchangesAPI(completion: APICompletionHandler, failure: APIFailureHandler) {
        let url = URL(string: ApiUrls.getMarketExchange)
        var request = URLRequest.init(url: url!)
        request.addBasicHeaderFields()
        forwardRequest(request: request, httpMethod: HttpMethods.HttpMethod_GET, completion: completion, failure: failure)
    }
    
    func getReferrals(username: String, completion: APICompletionHandler, failure: APIFailureHandler) {
        let url = URL(string: ApiUrls.getReferrals + username)
        var request = URLRequest.init(url: url!)
        request.addBasicHeaderFields()
        forwardRequest(request: request, httpMethod: HttpMethods.HttpMethod_GET, completion: completion, failure: failure)
    }
    
    func getProducts(completion: APICompletionHandler, failure: APIFailureHandler) {
        let url = URL(string: ApiUrls.getProducts)
        var request = URLRequest.init(url: url!)
        request.addBasicHeaderFields()
        forwardRequest(request: request, httpMethod: HttpMethods.HttpMethod_GET, completion: completion, failure: failure)
    }
    
    func getActiveGadgetsByUser(username: String, completion: APICompletionHandler, failure: APIFailureHandler) {
        let url = URL(string: ApiUrls.getActiveGadgetsByUser+username)
        var request = URLRequest.init(url: url!)
        request.addBasicHeaderFields()
        forwardRequest(request: request, httpMethod: HttpMethods.HttpMethod_GET, completion: completion, failure: failure)
    }
    
    
    
    func getDailyTips(completion: APICompletionHandler, failure: APIFailureHandler) {
        let url = URL(string: ApiUrls.getDailyTips)
        var request = URLRequest.init(url: url!)
        request.addBasicHeaderFields()
        forwardRequest(request: request, httpMethod: HttpMethods.HttpMethod_GET, completion: completion, failure: failure)
        
    }
    
    func getAfitBalance(username: String, completion: APICompletionHandler, failure: APIFailureHandler) {
        let url = URL(string: "\(ApiUrls.getAfitBalance)\(username)?fullbalance=1")
        var request = URLRequest.init(url: url!)
        request.addBasicHeaderFields()
        forwardRequest(request: request, httpMethod: HttpMethods.HttpMethod_GET, completion: completion, failure: failure)
        
    }
    
    
    func getAccountData(username: String, completion: APICompletionHandler, failure: APIFailureHandler) {
        let url = URL(string: "\(ApiUrls.getUserData)?user=\(username)")
        var request = URLRequest.init(url: url!)
        request.addBasicHeaderFields()
        forwardRequest(request: request, httpMethod: HttpMethods.HttpMethod_GET, completion: completion, failure: failure)
    }

    
    func getVotingStatus(completion: APICompletionHandler, failure: APIFailureHandler) {
        let url = URL(string: ApiUrls.getVotingStatus)
        var request = URLRequest.init(url: url!)
        request.addBasicHeaderFields()
        forwardRequest(request: request, httpMethod: HttpMethods.HttpMethod_GET, completion: completion, failure: failure)
    }
    
    func getAllNotifications(completion: APICompletionHandler, failure: APIFailureHandler, username: String) {
        let urlStr = "\(ApiUrls.getAllNotifications)\(username)"
        let url =  URL(string: urlStr)
        var request = URLRequest.init(url: url!)
        request.addBasicHeaderFields()
        self.forwardRequest(request: request, httpMethod: HttpMethods.HttpMethod_GET, completion: completion, failure: failure)
    }
    
    func getNewsBanner(completion: APICompletionHandler, failure: APIFailureHandler) {
        let urlStr = ApiUrls.getNewsBanner
        let url =  URL(string: urlStr)
        var request = URLRequest.init(url: url!)
        request.addBasicHeaderFields()
        self.forwardRequest(request: request, httpMethod: HttpMethods.HttpMethod_GET, completion: completion, failure: failure)
    }
    
    func getLoginImage(completion: APICompletionHandler, failure : APIFailureHandler) {
        let urlStr = "\(ApiUrls.loginImageURL)"
        let url =  URL(string: urlStr)
        var request = URLRequest.init(url: url!)
        request.addBasicHeaderFields()
        self.forwardRequest(request: request, httpMethod: HttpMethods.HttpMethod_GET, completion: completion, failure: failure)
    }
    
    func getRCPercentage(completion: APICompletionHandler, failure : APIFailureHandler,username: String) {
        let urlStr = "\(ApiUrls.getRCPercentageURL)\(username)"
        let url =  URL(string: urlStr)
        var request = URLRequest.init(url: url!)
        request.addBasicHeaderFields()
        self.forwardRequest(request: request, httpMethod: HttpMethods.HttpMethod_GET, completion: completion, failure: failure)
    }
    
    //MARK: API callers
    func getRank(username : String, completion : APICompletionHandler, failure : APIFailureHandler) {
        let urlStr = "\(ApiUrls.getRank)\(username)"
        let url = URL.init(string: urlStr)
        var request = URLRequest.init(url: url!)
        request.addBasicHeaderFields()
        self.forwardRequest(request: request, httpMethod: HttpMethods.HttpMethod_GET, completion: completion, failure: failure)
    }
    
    func checkLogin(info : [String : Any], completion : APICompletionHandler, failure : APIFailureHandler) {
        let urlStr = ApiUrls.loginAuth
        let url = URL.init(string: urlStr)
        var request = URLRequest.init(url: url!)
        request.addBasicHeaderFields()
        request.appendBodyWith(json: info)
        self.forwardRequest(request: request, httpMethod: HttpMethods.HttpMethod_POST, completion: completion, failure: failure)
    }
    
    func postActvityWith(info : [String : Any], completion : APICompletionHandler, failure : APIFailureHandler) {
        let urlStr = ApiUrls.postActivity
        let url = URL.init(string: urlStr)
        var request = URLRequest.init(url: url!)
        request.addBasicHeaderFields()
        request.appendBodyWith(json: info)
        self.forwardRequest(request: request, httpMethod: HttpMethods.HttpMethod_POST, completion: completion, failure: failure)
    }
    
    func getDailyLeaderboard(completion : APICompletionHandler, failure : APIFailureHandler) {
        let urlStr = ApiUrls.getDailyLeaderboard
        let url = URL.init(string: urlStr)
        var request = URLRequest.init(url: url!)
        request.addBasicHeaderFields()
        self.forwardRequest(request: request, httpMethod: HttpMethods.HttpMethod_POST, completion: completion, failure: failure)
    }
    
    func getWalletBalanceWith(username : String, completion : APICompletionHandler, failure : APIFailureHandler) {
        let urlStr = ApiUrls.walletBalance + username
        let url = URL.init(string: urlStr)
        var request = URLRequest.init(url: url!)
        request.addBasicHeaderFields()
        self.forwardRequest(request: request, httpMethod: HttpMethods.HttpMethod_GET, completion: completion, failure: failure)
    }
    
    func getTransactions(username : String, completion : APICompletionHandler, failure : APIFailureHandler) {
        let urlStr = ApiUrls.transactions + username
        let url = URL.init(string: urlStr)
        var request = URLRequest.init(url: url!)
        request.addBasicHeaderFields()
        self.forwardRequest(request: request, httpMethod: HttpMethods.HttpMethod_GET, completion: completion, failure: failure)
    }
    
    func getCharities(completion : APICompletionHandler, failure : APIFailureHandler) {
        let urlStr = ApiUrls.charities
        let url = URL.init(string: urlStr)
        var request = URLRequest.init(url: url!)
        request.addBasicHeaderFields()
        self.forwardRequest(request: request, httpMethod: HttpMethods.HttpMethod_GET, completion: completion, failure: failure)
    }
    
    func getUserSettings(params: String, completion : APICompletionHandler, failure : APIFailureHandler) {
        let urlStr = "\(ApiUrls.getUserSetting)/" + "\(params)"
        let url = URL.init(string: urlStr)
        var request = URLRequest.init(url: url!)
        request.addBasicHeaderFields()
        self.forwardRequest(request: request, httpMethod: HttpMethods.HttpMethod_GET, completion: completion, failure: failure)
    }
    
    func getNotifications(completion : APICompletionHandler, failure : APIFailureHandler) {
        let urlStr = ApiUrls.notificationType
        let url = URL.init(string: urlStr)
        var request = URLRequest.init(url: url!)
        request.addBasicHeaderFields()
        self.forwardRequest(request: request, httpMethod: HttpMethods.HttpMethod_GET, completion: completion, failure: failure)
    }
    
    func updateUserSettings(username: String, settings: [String: Any], completion : APICompletionHandler, failure : APIFailureHandler) {
    
        
       do {
            let data1 =  try JSONSerialization.data(withJSONObject: settings, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
           let convertedString = String(data: data1, encoding: .utf8) // the data will be converted to the string
            print(convertedString!) // <-- here is ur string
           let urlEncodedJson = convertedString!.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)

           
           let urlStr = "\(ApiUrls.updateUserSetting)/?user=" + "\(username)&settings=" + "\(urlEncodedJson!)"
            let url = URL.init(string: urlStr)
            var request = URLRequest.init(url: url!)
            request.addBasicHeaderFieldsForUpdateSettings()
            self.forwardRequest(request: request, httpMethod: HttpMethods.HttpMethod_GET, completion: completion, failure: failure)
           
       } catch let myJSONError {
                    print(myJSONError)
                }
    }
    
    //MARK: Dispatching Request to server
    
    func forwardRequest(request : URLRequest, httpMethod : String, completion : APICompletionHandler, failure : APIFailureHandler) {
        var statusCode: Int? = nil
        var sendRequest:URLRequest = request
        
        sendRequest.httpMethod = httpMethod as String
        //sendRequest.timeoutInterval = 5.0
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: sendRequest, completionHandler: { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                statusCode = httpResponse.statusCode
                   // Use the statusCode as needed
               }
            if error == nil{
                if let data = data {
                    #if DEBUG
                    print("Response json Data is \(data)")
                    #endif
                    //use library to extract data from response json
                    if let string = String.init(data: data, encoding: String.Encoding.utf8) {
                        // do {
                       
                        completion!(string, statusCode)
                        //} catch {
                        //}
                    } else {
                        completion!(nil,statusCode)
                    }
                } else {
                    completion!(nil,statusCode)
                }
            } else{
                if failure != nil {
                    failure!(error! as NSError )
                }
            }
            
        })
        task.resume()
    }
}

extension URLRequest {
    mutating func addBasicHeaderFields() {
        self.setValue("application/json", forHTTPHeaderField: "Content-Type")
       // self.setValue("application/json", forHTTPHeaderField: "Accept")
    }
    mutating func addBasicHeaderFieldsForUpdateSettings() {
        self.setValue("application/json", forHTTPHeaderField: "Content-Type")
        self.setValue("Bearer \(UserDefaults.standard.value(forKey: "authToken") ?? "")", forHTTPHeaderField: "Authorization")
    }
    
    mutating func appendBodyWith(json : [String : Any]) {
        do {
            self.httpBody = try JSONSerialization.data(withJSONObject: json, options:[])
        } catch _{}
    }
}

