//
//  ViewController.swift
//  Project8 - Swifty Words
//
//  Created by Stefan Storm on 2024/09/10.
//

import UIKit

class ViewController: UIViewController {
    
    var cluesLabel: UILabel!
    var answersLabel: UILabel!
    var currentAnswer: UITextField!
    var scoreLabel: UILabel!
    var letterButtons = [UIButton]()
    
    var activatedButtons = [UIButton]()
    var solutions = [String]()
    var triesLeft = 5
    
    var score = 0 {
        didSet{
            scoreLabel.text = "Correct: \(score)/7"
        }
    }
    var level = 1
    
    
    
    override func loadView() {
        self.view = UIView()
        view.backgroundColor = .white
        setupLayout()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        performSelector(inBackground: #selector(loadLevel), with: nil) //loadLevel()
    }
    
    
    @objc func letterTapped(_ sender: UIButton){
        guard let buttonTitle = sender.titleLabel?.text else {return}
        
        currentAnswer.text = currentAnswer.text?.appending(buttonTitle)
        activatedButtons.append(sender)
        
        //Update for Project15 challenge
        UIView.animate(withDuration: 1, delay: 0) {
            sender.alpha = 0
        }

        
    }
    
    
    @objc func submitTapped(_ sender: UIButton){
        guard let answerText = currentAnswer.text else {return}

        if let solutionsPosition = solutions.firstIndex(of: answerText){
            activatedButtons.removeAll()
            
            var splitAnswers = answersLabel.text?.components(separatedBy: "\n")
            splitAnswers?[solutionsPosition] = answerText
            answersLabel.text = splitAnswers?.joined(separator: "\n")
            
            currentAnswer.text = ""
            score += 1
            
            if score == 7 {
                showMessage(title: "Well done!", message: "Are you ready for the next level?", alertActionTitle: "Let's go!", doesHaveHandler: true, handler: levelUp)
            }
        }else{
            
            triesLeft -= 1
            guard triesLeft != 0 else {
                showMessage(title: "GAME OVER", message: "\(triesLeft) tries left", alertActionTitle: "Restart", doesHaveHandler: false, handler: levelUp)
                solutions.removeAll(keepingCapacity: true)
                currentAnswer.text = ""
                triesLeft = 5
                score = 0
                level = 1
                loadLevel()
                for button in letterButtons {
                    button.isHidden = false
                }
                return
            }
                
                showMessage(title: "Wrong word, sorry", message: "\(triesLeft) tries left", alertActionTitle: "Retry", doesHaveHandler: false, handler: levelUp)
                currentAnswer.text = ""
   
                for button in activatedButtons {
                    button.isHidden = false
                }
                
                activatedButtons.removeAll()
            
        }

    }
    
    
    func showMessage(title: String , message: String, alertActionTitle: String , doesHaveHandler: Bool, handler: @escaping ((_: UIAlertAction) -> Void)) {
        let ac = UIAlertController(title: title, message: message , preferredStyle: .alert)
        if doesHaveHandler{
            ac.addAction(UIAlertAction(title: alertActionTitle, style: .default, handler: handler))
        }else{
            ac.addAction(UIAlertAction(title: alertActionTitle, style: .default))
        }
        present(ac, animated: true)
    }
    
    
    func levelUp(action: UIAlertAction){
        level += 1
        score = 0
        solutions.removeAll(keepingCapacity: true)
        performSelector(inBackground: #selector(loadLevel), with: nil)
        for button in letterButtons {
            button.alpha = 1
        }
        
    }
    
    
    @objc func clearTapped(_ sender:UIButton){
        currentAnswer.text = ""
        
        for button in activatedButtons {
            button.alpha = 1
        }
        
        activatedButtons.removeAll()
    }
    
    
    @objc func loadLevel(){
        
        var clueString = ""
        var solutionsString = ""
        var letterBits = [String]()
        
        if let levelFileURL = Bundle.main.url(forResource: "level\(level)", withExtension: "txt"){
            if let levelContents = try? String(contentsOf: levelFileURL){
                var lines = levelContents.components(separatedBy: "\n")
                lines.shuffle()
                
                for (index, line) in lines.enumerated(){
                    let parts = line.components(separatedBy: ": ")
                    let answer = parts[0]
                    let clue = parts[1]
                    
                    clueString += "\(index + 1). \(clue)\n"
                    let solutionWord = answer.replacingOccurrences(of: "|", with: "")
                    solutionsString += "\(solutionWord.count) letters\n"
                    solutions.append(solutionWord)
                    
                    let bits = answer.components(separatedBy: "|")
                    letterBits += bits
                    
                }
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            
            self?.cluesLabel.text = clueString.trimmingCharacters(in: .whitespacesAndNewlines)
            self?.answersLabel.text = solutionsString.trimmingCharacters(in: .whitespacesAndNewlines)
            self?.letterButtons.shuffle()
            
            if self?.letterButtons.count == letterBits.count{
                for i in 0..<(self?.letterButtons.count)!{
                    self?.letterButtons[i].setTitle(letterBits[i], for: .normal)
                }
            }
        }
        
    }
        
        
    
    
    
    func setupLayout(){
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.textAlignment = .right
        scoreLabel.text = "Correct: 0/7"
        view.addSubview(scoreLabel)
        
        cluesLabel = UILabel()
        cluesLabel.translatesAutoresizingMaskIntoConstraints = false
        cluesLabel.font = UIFont.systemFont(ofSize: 24)
        cluesLabel.text = "CLUES"
        cluesLabel.numberOfLines = 0
        cluesLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        view.addSubview(cluesLabel)
        
        answersLabel = UILabel()
        answersLabel.translatesAutoresizingMaskIntoConstraints = false
        answersLabel.font = UIFont.systemFont(ofSize: 24)
        answersLabel.text = "ANSWERS"
        answersLabel.numberOfLines = 0
        answersLabel.textAlignment = .right
        answersLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        view.addSubview(answersLabel)
        
        currentAnswer = UITextField()
        currentAnswer.translatesAutoresizingMaskIntoConstraints = false
        currentAnswer.isUserInteractionEnabled = false
        currentAnswer.placeholder = "Tap letters to guess"
        currentAnswer.textAlignment = .center
        currentAnswer.font = UIFont.systemFont(ofSize: 44)
        view.addSubview(currentAnswer)
        
        let submit = UIButton(type: .system)
        submit.translatesAutoresizingMaskIntoConstraints = false
        submit.setTitle("Submit", for: .normal)
        submit.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        view.addSubview(submit)
        
        let clear = UIButton(type: .system)
        clear.translatesAutoresizingMaskIntoConstraints = false
        clear.setTitle("Clear", for: .normal)
        clear.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        view.addSubview(clear)
        
        let buttonsView = UIView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        buttonsView.backgroundColor = .lightText
        buttonsView.layer.borderWidth = 2
        buttonsView.layer.cornerRadius = 20
        
        view.addSubview(buttonsView)

        
        
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            cluesLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            cluesLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 100),
            cluesLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.6, constant: -100),
            
            answersLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            answersLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -100),
            answersLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.4, constant: -100),
            answersLabel.heightAnchor.constraint(equalTo: cluesLabel.heightAnchor),
            
            currentAnswer.topAnchor.constraint(equalTo: cluesLabel.bottomAnchor, constant: 20),
            currentAnswer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            currentAnswer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            submit.topAnchor.constraint(equalTo: currentAnswer.bottomAnchor),
            submit.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -100),
            submit.heightAnchor.constraint(equalToConstant: 44),
            
            clear.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 100),
            clear.centerYAnchor.constraint(equalTo: submit.centerYAnchor),
            clear.heightAnchor.constraint(equalToConstant: 44),
            
            buttonsView.widthAnchor.constraint(equalToConstant: 750),
            buttonsView.heightAnchor.constraint(equalToConstant: 320),
            buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsView.topAnchor.constraint(equalTo: submit.bottomAnchor, constant: 20),
            buttonsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20)
        ])
        
        let width = 150
        let height = 80
        
        for row in 0..<4{
            for column in 0..<5{
                let letterButton = UIButton(type: .system)
                letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 36)
                letterButton.setTitle("WWW", for: .normal)
                let frame = CGRect(x: column * width, y: row * height, width: width, height: height)
                letterButton.frame = frame
                letterButton.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
                buttonsView.addSubview(letterButton)
                letterButtons.append(letterButton)
            }
        }
        
        
        
    }


}

