//
//  Picture.swift
//  Project1
//
//  Created by Stefan Storm on 2024/09/21.
//

import Foundation


class Picture: Codable{
    var image: String
    var views: Int
    
    init(image: String, views: Int) {
        self.image = image
        self.views = views
    }
    
}
