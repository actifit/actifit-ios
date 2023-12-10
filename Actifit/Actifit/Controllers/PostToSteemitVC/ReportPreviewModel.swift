//
//  ReportPreviewModel.swift
//  Actifit
//
//  Created by Ali Jaber on 11/07/2023.
//

import Foundation
import UIKit
struct ReportPreviewModel: Codable {
    var titleText: String?
    var addedImage: UIImage?
    var imageURL: String?
    var unusableImageURL: String?
    var displayCell: Bool?
    init(titleText: String? = nil, addedImage: UIImage? = nil, imageURL: String? = nil, unusableImageURL: String? = nil, displayCell: Bool? = nil) {
        self.titleText = titleText
        self.addedImage = addedImage
        self.imageURL = imageURL
        self.unusableImageURL = unusableImageURL
        self.displayCell = displayCell
    }
    
    init(from decoder: Decoder) throws {
           let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            titleText =  try values.decode(String.self, forKey: .textTtile)
            imageURL =  try values.decode(String.self, forKey: .imageURL)
            displayCell = try values.decode(Bool.self, forKey: .displayCell)
            unusableImageURL = try values.decode(String.self, forKey: .unusedURL)
        } catch let error {
            titleText = nil
            imageURL = nil
            unusableImageURL = nil
            displayCell = nil
            print(error.localizedDescription)
        }
      
          

     
//

        do {
            let data = try values.decode(Data.self, forKey: .image)
            if data.isEmpty {
                self.addedImage = UIImage()
            } else {
                guard let image = UIImage(data: data, scale: 1.0) else {
                    self.addedImage = UIImage()
                    throw DecodingError.dataCorruptedError(forKey: .image, in: values, debugDescription: "Invalid image data")
                }
                self.addedImage = image //image
            }
        } catch let error {
            self.addedImage = UIImage()
            print(error.localizedDescription)
        }
//        let data = try values.decode(Data.self, forKey: .image)
//        if data.isEmpty {
//            self.addedImage = UIImage()
//        } else {
//
//        }

       }
    

       func encode(to encoder: Encoder) throws {
           var container = encoder.container(keyedBy: CodingKeys.self)
           
           try container.encode(titleText ?? "", forKey: .textTtile)
           try container.encode(imageURL ?? "", forKey: .imageURL)
           try container.encode(unusableImageURL ?? "", forKey: .unusedURL)
           try container.encode(displayCell ?? true, forKey: .displayCell)
           if let image = addedImage {
               do {
                   
                   let data = UIImagePNGRepresentation(image)
                   try container.encode(data, forKey: .image)
               } catch let error {
                   print(error)
               }
           }
       }

    enum CodingKeys: String, CodingKey {
           case textTtile = "textTitle"
           case imageURL = "imageurl"
           case image = "image"
           case unusedURL = "unusedURL"
           case displayCell = "showCell"
       }
}
