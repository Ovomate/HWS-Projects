//
//  ViewController.swift
//  Project5
//
//  Created by Stefan Storm on 2024/09/02.
//

import UIKit

class ViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsURL){
                allWords = startWords.components(separatedBy: "\n")
            }
            
        }
        
        if allWords.isEmpty{
            allWords = ["Silkworm"]
            
        }
        
        startGame()
        
    }

    
    @objc func startGame(){
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
        
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        usedWords.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
        
    }
    
    
    @objc func promptForAnswer(){
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text?.lowercased() else {return}
            self?.submit(answer)
            ac?.textFields?[0].becomeFirstResponder()
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
        
    }
    
    func submit(_ answer: String){
        _ = answer.lowercased()
        let _: String
        let _: String
        
        if isPossible(word: answer){
            if isOriginal(word: answer){
                if isReal(word: answer){
                    usedWords.insert(answer, at: 0)
                    
                    let indexPath = IndexPath(row: 0, section:  0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    return
                }else{
                    showErrorMessage(errorTitle: "Word not recognized!", errorMessage: "You can't just make them up, you know...")
                }
            }else{
                showErrorMessage(errorTitle: "Word already used!", errorMessage: "Need an original word.")
            }
        }else{
            guard let title = title else {return}
            showErrorMessage(errorTitle: "Not possible to form that word!", errorMessage: "You can't spell that word from \(title.lowercased())")
            
        }
    }
    
    
    func isPossible(word: String) -> Bool{
        guard var tempWord = title?.lowercased() else {return false}
        for letter in word{
            if let position = tempWord.firstIndex(of: letter){
                tempWord.remove(at: position)
            }else{
                return false
            }
        }
        return true
    }
    
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    
    func isReal(word: String) -> Bool {
        guard word.count >= 3 else { showErrorMessage(errorTitle: "Word too short!", errorMessage: "Word must contain more than 2 letters.");return false}
        guard word.lowercased() != title?.lowercased() else {showErrorMessage(errorTitle: "Same word!", errorMessage: "Word cannot be the same as the given word.");return false}
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    
    func showErrorMessage(errorTitle: String, errorMessage: String){
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }


}

