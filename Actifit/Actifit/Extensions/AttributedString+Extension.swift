//
//  AttributedString+Extension.swift
//  Actifit
//
//  Created by Hitender kumar on 13/08/18.
//  Copyright © 2018 actifit.io. All rights reserved.
//

import Foundation
import UIKit
import FontAwesome_swift
extension NSAttributedString {
    func heightFor(boundingWidth : CGFloat) -> CGFloat {
        let rect = self.boundingRect(with: CGSize.init(width: boundingWidth, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        return rect.height
    }
    
    static func generateFontAwesomeString(code: String, size: CGFloat) -> NSAttributedString {
        return NSAttributedString(string: code, attributes: [.font : UIFont.fontAwesome(ofSize: size, style: .solid) ] )
    }
}

enum AwesomeButtonCodes: String {
    case trophyIcon = "\u{f091}"
    case settingsIcon = "\u{f013}"
    case notificationIcon = "\u{f0f3}"
    case walletIcon = "\u{f555}"
    case gaugeIcon =  "\u{f624}"
    case votingIcon = "\u{f4b9}"
    case exlamationIcon = "\u{f06a}"
    case marketButton = "\u{f54e}"
    case referralsButton = "\u{f234}"
    case exchangeList = "\u{f201}"
    case copyIcon = "\u{f0c5}"
    case shareIcon = "\u{f1e0}"
    case socialIcon = "\u{e068}"
    case pictureIcon = "\u{f083}"
    case historyIcon = "\u{f1da}"
    case listIcon = "\u{f0cb}"
    case socialsIcon = "\u{e4e2}"
    case chatIcon = "\u{f086}"
    case facebookIcon = "\u{f09a}"
    case twitterIcon = "\u{e61b}"//e61b
    case discordIcon = "\u{f392}"
    case telegramIcon = "\u{f2c6}"
    case youtubeIcon = "\u{f167}"
    case instagramIcon = "\u{f16d}"
    case linkedInIcon = "\u{f08c}"
}
