//
//  Capital.swift
//  Project16 - Capital Cities
//
//  Created by Stefan Storm on 2024/10/01.
//
import MapKit
import UIKit

class Capital: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String
    
    init(title: String, coordinate: CLLocationCoordinate2D, info: String) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
    }
    

}
