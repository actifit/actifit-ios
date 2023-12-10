//
//  NotificationViewModel.swift
//  Actifit
//
//  Created by Ali Jaber on 25/07/2023.
//

import Foundation
import Combine
import UIKit
class NotificationViewModel {
    var cancellables = Set<AnyCancellable>()
    var notificationsList: [NotificationModel] = []
    private let notificationDataReceivedSubject =  PassthroughSubject<Bool, Never>()
    private let loaderStatus = PassthroughSubject<Bool, Never>()
    var loaderStatusPublisher: AnyPublisher<Bool, Never> {
        return loaderStatus.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    
    var notificationsPublisher: AnyPublisher<Bool, Never> {
        return notificationDataReceivedSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    
    init () {
        loaderStatus.send(true)
        getNotifications()
    }
    
    private func getNotifications() {
        guard let username  = User.current()?.steemit_username else { return }
        API().getAllNotifications(completion: { [weak self] info, statusCode in
            if let response = info as? String {
                self?.loaderStatus.send(false)
                let data = response.utf8Data()
                let decoder = JSONDecoder()
                do {
                    let notificationData =  try decoder.decode([NotificationModel].self, from: data)
                    print(info)
                    self?.notificationsList = notificationData
                    self?.notificationDataReceivedSubject.send(true)
                } catch let error {
                    print(error)
                }
            }
        }, failure: { error in
            
        }, username: username)

    }
}
