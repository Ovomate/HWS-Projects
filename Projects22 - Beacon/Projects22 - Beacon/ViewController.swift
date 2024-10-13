//
//  ViewController.swift
//  Projects22 - Beacon
//
//  Created by Stefan Storm on 2024/10/12.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var distanceReading: UILabel!
    var locationManager : CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        
        view.backgroundColor = .gray
        
        
    }
    
    

    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        print("Executed")
      
        if manager.authorizationStatus == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self){
                if CLLocationManager.isRangingAvailable() {
                    print("Executed")
                }
                
            }
        }
        
    }

    
    

}

