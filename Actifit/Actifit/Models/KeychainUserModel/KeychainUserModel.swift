//
//  KeychainUserModel.swift
//  Actifit
//
//  Created by Ali Jaber on 20/09/2023.
//

import Foundation
struct UserModel: Codable {
    let username: String
    let privatePostingKey: String
    init(username: String, privatePostingKey: String) {
        self.username = username
        self.privatePostingKey = privatePostingKey
    }
}
