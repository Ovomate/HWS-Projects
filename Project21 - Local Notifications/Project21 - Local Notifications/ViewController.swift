//
//  ViewController.swift
//  Project21 - Local Notifications
//
//  Created by Stefan Storm on 2024/10/10.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleLocal))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
    }
    
    @objc func registerLocal(){
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound], completionHandler: {granted , error in
            if granted {
                print("Yes")
            }else{
                print("Ah")
            }
        })
        
    }

    @objc func scheduleLocal(){
        registerCategories()
        
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Hi daar slaaiblaar"
        content.body = "Miskien sien jy die boodskap en dink, my donner, hier is n Afrikaanse persoon wat ook swift leer."
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customDataKey": "customDataValue"]
        content.sound = .defaultCritical
        
        var dateComponents = DateComponents()
        dateComponents.hour = 12
        dateComponents.minute = 00
        
       // let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
        
    }
    
    func registerCategories(){
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        let showAction = UNNotificationAction(identifier: "Show more", title: "Vertel my meer...", options: .foreground)
        let hideAction = UNNotificationAction(identifier: "Show something", title: "Vertel my iets...", options: .foreground)
        let category = UNNotificationCategory(identifier: "alarm", actions: [showAction, hideAction], intentIdentifiers: [], options: [])
        
        center.setNotificationCategories([category])
        
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let customData = userInfo["customDataKey"] as? String {
            print(customData)
            
            
            switch response.actionIdentifier{
            case UNNotificationDefaultActionIdentifier:
                //User swiped to unlock
                print("Default Identifier")
            case "Show more":
                print("Show more information")
            case "Show something":
                print("Show something else")
            default:
                break
                
                
            }
        }
        completionHandler()
    }

}

