//
//  API.swift
//  Actifit
//
//  Created by Hitender kumar on 15/08/18.
//  Copyright © 2018 actifit.io. All rights reserved.
//

import Foundation

typealias APICompletionHandler = ((_ info : Any?) -> ())?
typealias APIFailureHandler = ((_ error : NSError) -> ())?

public class API : NSObject{
    
    //MARK: Initializers
    
    override init() {
    }
    
    class var sharedInstance : API {
        return API()
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
        
        var sendRequest:URLRequest = request
        
        sendRequest.httpMethod = httpMethod as String
        //sendRequest.timeoutInterval = 5.0
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: sendRequest, completionHandler: { data, response, error in
            if error == nil{
                if let data = data {
                    #if DEBUG
                    print("Response json Data is \(data)")
                    #endif
                    //use library to extract data from response json
                    if let string = String.init(data: data, encoding: String.Encoding.utf8) {
                        // do {
                        // let json = try JSONSerialization.jsonObject(with: data, options: [])
                        completion!(string)
                        //} catch {
                        //}
                    } else {
                        completion!(nil)
                    }
                } else {
                    completion!(nil)
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

