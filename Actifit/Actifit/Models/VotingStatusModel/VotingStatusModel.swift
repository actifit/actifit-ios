//
//  VotingStatusModel.swift
//  Actifit
//
//  Created by Ali Jaber on 27/07/2023.
//

import Foundation
struct VotingStatusModel: Codable {
    let status: Status?
    let vp: Double?
    let rewardStart: String?
    
    enum CodingKeys: String, CodingKey {
        case status
        case vp
        case rewardStart = "reward_start"
    }
}

struct Status: Codable {
    let id: String?
    let isVoting: Bool?
    let votingStart: String?
    let votingEnd: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case isVoting = "is_voting"
        case votingStart = "voting_start"
        case votingEnd = "voting_end"
    }
}
