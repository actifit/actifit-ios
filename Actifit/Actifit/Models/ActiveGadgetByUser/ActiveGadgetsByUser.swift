//
//  ActiveGadgetsByUser.swift
//  Actifit
//
//  Created by Ali Jaber on 07/08/2023.
//

import Foundation

struct ActiveGadgeByUser: Codable {
    let id: String?
    let user:String?
    let gadget: String?
    let productType: String?
    let gadgetName: String?
    let gadgetLevel: Int?
    let status: String?
    let span: Int?
    let spanUnit: String?
    let consumed: Int?
    let note: String?
     
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case user
        case gadget
        case productType = "product_type"
        case gadgetName = "gadget_name"
        case gadgetLevel = "gadget_level"
        case status
        case span
        case consumed
        case note
        case spanUnit = "span_unit"
    }
}
