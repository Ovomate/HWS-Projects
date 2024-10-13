//
//  Person.swift
//  Project10 - Names to faces
//
//  Created by Stefan Storm on 2024/09/17.
//

import UIKit

class Person: NSObject, Codable{
    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}
