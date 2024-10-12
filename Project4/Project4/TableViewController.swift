//
//  TableViewController.swift
//  Project4
//
//  Created by Stefan Storm on 2024/09/01.
//

import UIKit


enum textFieldError: String {
    case notWebsite = "Please enter a valid website!"
    case notTextEntered = "Please enter something!"
}



class TableViewController: UITableViewController, UITextFieldDelegate {
    
    var websites = ["hackingwithswift.com","apple.com", "apple.co.za","nvidia.com"]
    @IBOutlet var textField: UITextField!
    var leftButton = UIBarButtonItem()
    var toggleLeftButton = false
    

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Safe Browser"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = UIColor.black
        
        textField.delegate = self
        textField.isUserInteractionEnabled = true
        textField.addTarget(self, action: #selector(doneButtonTapped), for: .primaryActionTriggered)
        self.clearsSelectionOnViewWillAppear = false
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        leftButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addItem))
        self.navigationItem.leftBarButtonItem = leftButton
        toggleButton(toggle: false, alpha: 0, image: "plus")
        
        
        

    }
    
    @objc func doneButtonTapped(){
        
        guard let text = textField.text else {
            showAlert(message: textFieldError.notTextEntered.rawValue)
            return
        }
        
        guard text.contains(".com") else {
            showAlert(message: textFieldError.notWebsite.rawValue)
            return
        }
        
        websites.append(text)
        toggleButton(toggle: false, alpha: 0, image: "plus")
        print(websites)
        tableView.reloadData()
        textField.text = ""
        
    }
    
    @objc func addItem(){
        !toggleLeftButton ? toggleButton(toggle: true, alpha: 1, image: "minus.circle.fill") : toggleButton(toggle: false, alpha: 0, image: "plus")

    }
    
    func showAlert(message: String){
        
        let ac = UIAlertController(title: "Oops!", message: message , preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        present(ac, animated: true)
    }
    
    
    
    func toggleButton(toggle: Bool, alpha: CGFloat, image: String){
        leftButton.image = UIImage(systemName: image)
        textField.alpha = alpha
        textField.isHidden = !toggle
        toggleLeftButton = toggle
        if !toggle {
            textField.text = ""
            textField.resignFirstResponder()
        }
        
    }
    

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return websites.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "website", for: indexPath)
        cell.textLabel?.text = websites[indexPath.row]
        return cell
        
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "WebViewController") as? WebViewController{
            vc.selectedWebsite = websites[indexPath.row]
            print(websites[indexPath.row])
            vc.safeWebsites = websites
            
            navigationController?.pushViewController(vc, animated: true)
            
            
        }
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            toggleButton(toggle: false, alpha: 0, image: "plus")
            websites.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
