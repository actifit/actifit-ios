//
//  ChatNotificationsCounr.swift
//  Actifit
//
//  Created by Ali Jaber on 14/10/2023.
//

import Foundation
struct ChatNotificationCount: Codable {
    let hiveCommunity: Int?
    enum CodingKeys: String, CodingKey {
        case hiveCommunity = "hive-193552"
    }
}
