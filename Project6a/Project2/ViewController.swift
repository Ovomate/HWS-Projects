//
//  ViewController.swift
//  Project2
//
//  Created by Stefan Storm on 2024/08/26.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    
    var countries = [String]()
    var score = 0
    var correctAnswer = 0
    var questionsAsked = 0
    var leftTitleLabel = UILabel()
    var completed: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        countries += ["estonia", "france", "germany","ireland","italy","monaco","nigeria",
                      "poland","russia","spain","uk","us"]
        
        self.navigationController?.navigationBar.backgroundColor = .white
        self.view.backgroundColor = .lightGray
        
        leftTitleLabel.text = "(\(score)/10) "
        leftTitleLabel.adjustsFontSizeToFitWidth = true
        leftTitleLabel.numberOfLines = 0
        let leftItem = UIBarButtonItem(customView: leftTitleLabel)
        self.navigationItem.leftBarButtonItem = leftItem

        
        button1.layer.borderWidth = 1
        button2.layer.borderWidth = 1
        button3.layer.borderWidth = 1
        
        button1.layer.borderColor = UIColor.lightGray.cgColor
        button2.layer.borderColor = UIColor.lightGray.cgColor
        button3.layer.borderColor = UIColor.lightGray.cgColor
        
        
        askQuestion(action: nil)
        
    }
    
    func askQuestion(action:UIAlertAction!){
        if completed{
            score = 0
            leftTitleLabel.text = "(\(score)/10)   "
            completed = false
        }
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
        title = countries[correctAnswer].uppercased()
        questionsAsked += 1
        
    }
    
    func showController(title: String, message: String,button: String ){
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: button, style: .default, handler: askQuestion))
        present(ac, animated: true)
        
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        var title: String

        if sender.tag == correctAnswer{
            title = "Correct!"
            score += 1
            leftTitleLabel.text = "(\(score)/10)  "
            
        }else{
            
            title = "Incorrect!, that is the flag of \(countries[sender.tag].uppercased())"
        }
        
        if questionsAsked == 10{
            showController(title: "Quiz Complete!", message: "Your score is \(score)/10", button: "Restart")
            completed = true
            
        }else{
            showController(title: title, message: "", button: "Continue")
            
        }

        
    }
    
    
    


}

