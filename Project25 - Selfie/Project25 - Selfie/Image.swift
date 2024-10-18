//
//  Image.swift
//  Project25 - Selfie
//
//  Created by Stefan Storm on 2024/10/18.
//

import Foundation
import UIKit

struct Image: Codable {
    
    let name: Data
    let imageData: Data
    
    init(name: String, image: UIImage) {
        self.name = Data(name.utf8)
        self.imageData = image.pngData()! 
    }
    
    func toUIImage() -> UIImage? {
        return UIImage(data: self.imageData)
    }
    
    func toString() -> String?{
        return String(decoding: name, as: UTF8.self)
    }
}

