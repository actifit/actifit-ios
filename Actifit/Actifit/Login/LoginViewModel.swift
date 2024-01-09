//
//  LoginViewModel.swift
//  Actifit
//
//  Created by Ali Jaber on 03/07/2023.
//

import Foundation
import Combine
import UIKit

class LoginViewModel {
    var labelRedColor: UIColor {
        return .primaryRedColor()
    }
    @Published var username: String = ""
    @Published var privatePostingKey = ""
    
    @Published var loginEnabled: Bool = false
    private let loaderVisibilitySubject = PassthroughSubject<Bool, Never>()
    private let imageLoaderVisibilitySubject = PassthroughSubject<Bool, Never>()
    var imageLoaderVisibiltyPublisher: AnyPublisher<Bool, Never> {
        return imageLoaderVisibilitySubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    var loaderVisibilityPublisher: AnyPublisher<Bool, Never> {
        return loaderVisibilitySubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    
    private let isUserAutorizedSubject = PassthroughSubject<Bool, Never>()
    var isUserBiometricAuthorizedPublisher: AnyPublisher<Bool, Never> {
        return isUserAutorizedSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    
    
    private let imageSubject = PassthroughSubject<UIImage?, Never>()
    private let proccessSuccessSubject = PassthroughSubject<Bool,Never>()
    
    var successProcessPublisher: AnyPublisher<Bool, Never> {
        return proccessSuccessSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }

    
    private var cancellables = Set<AnyCancellable>()
    private var cancellable: AnyCancellable?
    init() {
//        Publishers.CombineLatest($username, $privatePostingKey).map {(username, key) in
//            return !username.isEmpty && !key.isEmpty
//        }.assign(to: \.loginEnabled, on: self)
//            .store(in: &cancellables)
        getBannerImage()
    }
    
    private func getBannerImage() {
        imageLoaderVisibilitySubject.send(true)
        API().getLoginImage { info, statusCode  in
            if let response = info as? String {
                let data = response.utf8Data()
                let decoder = JSONDecoder()
                do {
                    let myData = try decoder.decode(LoginBanner.self, from: data)
                    self.loadImage(url: URL(string: myData.imgUrl ?? "")!)
                }
                catch {
                    print("Error decoding JSON: \(error.localizedDescription)")
                }
            }
        } failure: { error in
            
        }

    }
    
     func loadImage(url: URL)  {
         cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map {data, _ -> UIImage? in
                UIImage(data: data)
            }.receive(on: DispatchQueue.main)
             .replaceError(with: nil)
             .sink{[weak self ] image in
                 self?.imageSubject.send(image)
                 self?.imageLoaderVisibilitySubject.send(false)
             }
    }
    
    func imagePublisher() -> AnyPublisher<UIImage?, Never> {
        return imageSubject.eraseToAnyPublisher()
    }
    
    func authorizeUser() {
        let biometricIDAuth = BiometricIDAuth()
        biometricIDAuth.canEvaluate { canEvaluate, _ , canEvaluateError in
            if canEvaluate {
                biometricIDAuth.evaluate {[weak self] success, error in
                    guard success else {
                        self?.isUserAutorizedSubject.send(false)
                        return
                    }
                    self?.isUserAutorizedSubject.send(true)
                    }
                }
            
        }
    }

    func proceedTapped(username: String, privatePostingKey: String) {
        loaderVisibilitySubject.send(true)
        do {
            try Keychain.setObject(UserModel(username: username, privatePostingKey: privatePostingKey), service: KeychainKeys.user.rawValue)
        } catch let error {
            print(error.localizedDescription)
        }
        let dict = ["username": username, "ppkey": privatePostingKey, "bchain": "HIVE", "loginsource": "ios", "keeploggedin": "true"]
        APIMaster.checkLogin(info: dict) { info, statusCode in
            if let statusCode = statusCode {
                if !(200...205).contains(statusCode) {
                    self.proccessSuccessSubject.send(false)
                    self.loaderVisibilitySubject.send(false)
                }
            }
            
            if let response = info as? String, statusCode != 400 {
                let data = response.utf8Data()
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if let jsonArray = (json as? NSDictionary){
                        UserDefaults.standard.set(username, forKey: "currentUserName")
                        UserDefaults.standard.set(privatePostingKey, forKey: "currentUserPrivateKey")
                        UserDefaults.standard.synchronize()
                        
                        UserDefaults.standard.setValue(jsonArray.value(forKey:"token"), forKey: "authToken")
                        User.saveWith(info: [UserKeys.steemit_username : username, UserKeys.private_posting_key : privatePostingKey, UserKeys.last_post_date : Date().yesterday])
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            self.loaderVisibilitySubject.send(false)
                            self.proccessSuccessSubject.send(true)
                        })
                      
                    }
                }catch {
                    print("Failed to convert JSON string to pretty JSON: \(error)")
                }
              
            } else {
                self.proccessSuccessSubject.send(false)
                self.loaderVisibilitySubject.send(false)
            }
        } failure: { error in
            print(error.localizedDescription)
            self.proccessSuccessSubject.send(false)
            self.loaderVisibilitySubject.send(false)
        }

    }
    
    
}

