//
//  ApplicationHelper.swift
//  Actifit
//
//  Created by Ali Jaber on 16/08/2023.
//

import Foundation
import UIKit
class ApplicationHelper {
    static let hiveComunity = "hive-193552"
    static func generateAndFindMin(minValue: Double, maxValue: Double) -> Double {
        var randomValues: [Double] = []
        for _ in 1...5 {
            let randomValue = Double.random(in: minValue...maxValue)
            randomValues.append(randomValue)
        }
        let minRandomValue = randomValues.min() ?? 0.0
        return truncateToThreeDecimalPlaces(minRandomValue)
        //return minRandomValue
    }
    
    static func truncateToThreeDecimalPlaces(_ value: Double) -> Double {
        return floor(value * 1000) / 1000
    }
    
    static func generateImageFromUnicode(unicode: Int) -> UIImage? {
        
        
        // Create a UIImage from the Unicode value
        if let emojiImage = imageFromUnicode(unicode) {
            return emojiImage
        }
        return nil
    }
    
    private static func imageFromUnicode(_ unicodeValue: Int) -> UIImage? {
        // Create a string from the Unicode value
        let unicodeString = String(UnicodeScalar(unicodeValue)!)
        
        // Create an attributed string with the Unicode string
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 50),
            .foregroundColor:  UIColor.primaryGreenColor()
            
        ]
        let attributedString = NSAttributedString(string: unicodeString, attributes: attributes)
        
        // Get an image from the attributed string
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 50, height: 50), false, 0.0)
        attributedString.draw(at: .zero)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    static func getSocialMedialURLByTag(tag: Int) -> URL? {
        switch tag {
        case 1: return URL(string: "https://www.facebook.com/Actifit.fitness")!
        case 2: return URL(string: "https://www.twitter.com/Actifit_fitness")!
        case 3: return URL(string: "https://links.actifit.io/discord")!
        case 4: return URL(string: "https://t.me/actifit")!
        case 5: return URL(string: "https://www.youtube.com/c/Actifitfitness")!
        case 6: return URL(string: "https://www.instagram.com/actifit.fitness")!
        case 7: return URL(string: "https://www.linkedin.com/company/actifit-io")!
        default: return nil
        }
    }

}
