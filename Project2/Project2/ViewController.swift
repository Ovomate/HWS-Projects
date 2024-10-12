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
    var correctAnswer = 0
    var questionsAsked = 0
    var leftTitleLabel = UILabel()
    var score = 0 {
        didSet {
            leftTitleLabel.text = "(\(score)/10) "
        }
    }
    var rightTitleLabel = UILabel()
    var highScore = 0 {
        didSet {
            rightTitleLabel.text = "Highscore: \(highScore)"
        }
    }
    var completed: Bool = false
    var defaults = UserDefaults.standard
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        countries += ["estonia", "france", "germany","ireland","italy","monaco","nigeria",
                      "poland","russia","spain","uk","us"]
        
        self.navigationController?.navigationBar.backgroundColor = .white
        self.view.backgroundColor = .lightGray

        leftTitleLabel.adjustsFontSizeToFitWidth = true
        leftTitleLabel.numberOfLines = 0
        leftTitleLabel.text = "(\(score)/10) "
        rightTitleLabel.adjustsFontSizeToFitWidth = true
        rightTitleLabel.numberOfLines = 1
        let bestScore = defaults.integer(forKey: "highScore")
        rightTitleLabel.text = "Highscore: \(bestScore)"
        
        let leftItem = UIBarButtonItem(customView: leftTitleLabel)
        let rightItem = UIBarButtonItem(customView: rightTitleLabel)
        self.navigationItem.leftBarButtonItem = leftItem
        self.navigationItem.rightBarButtonItem = rightItem
        
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
        
        //MARK: Project15 Challenge
        button1.transform = .identity
        button2.transform = .identity
        button3.transform = .identity
     
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
        
        //MARK: Challenge for Project15
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 10) {
            sender.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }
        
        if sender.tag == correctAnswer{
            title = "Correct!"
            score += 1

            if score >= highScore{
                highScore += 1
                defaults.set(highScore, forKey: "highScore")
            }
            
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

