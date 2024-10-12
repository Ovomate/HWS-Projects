//
//  ViewController.swift
//  Project7
//
//  Created by Stefan Storm on 2024/09/09.
//

import UIKit

class ViewController: UITableViewController {
    
    var petitions = [Petition]()
    var filteredPetitions = [Petition]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        title = "White House Petitions"
        navigationController?.navigationBar.prefersLargeTitles = true
        let credit = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(creditsTapped))
        let search = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchTapped))
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshTapped))
        
        navigationItem.rightBarButtonItems = [credit, search, refresh]
        
        let urlString: String
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        }else{
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
        
        if let url = URL(string: urlString){
            if let data = try? Data(contentsOf: url){
                parse(json: data)
                return
            }
        }
        showError(message: "Error downloading information. Please check network connection.")
    }
    
    
    @objc func refreshTapped(){
        self.filteredPetitions.removeAll()
        filteredPetitions = petitions
        tableView.reloadData()
    }
    
    
    @objc func searchTapped(){
        let ac = UIAlertController(title: "Search", message: "Search for a specific petition below", preferredStyle: .alert)
        ac.addTextField()
        
        let addAction = UIAlertAction(title: "Search", style: .default) { [weak self, weak ac] _ in
            guard let item = ac?.textFields?[0].text else {return}
            guard !item.isEmpty else { self?.showError(message: "Textfield empty.");return}
            guard let petitions = self?.filteredPetitions else {return}
            
            self?.filteredPetitions.removeAll()
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                
                
                for petition in petitions{
                    if petition.title.contains(item){
                        self?.filteredPetitions.append(petition)
                    }
                }
                DispatchQueue.main.async {[weak self] in
                    self?.tableView.reloadData()
                }
            }
        }
        ac.addAction(addAction)
        present(ac, animated: true)
    }
    
    
    @objc func creditsTapped(){
        let ac = UIAlertController(title: "INFORMATION SOURCE:", message: "All the info is sourced from the wethepeople.gov api", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Okay", style: .default))
        present(ac, animated: true)
    }
    
    
    func showError(message: String){
        let ac = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Okay", style: .default))
        present(ac, animated: true)
    }
    
    
    func parse(json: Data){
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json){
            petitions = jsonPetitions.results
            filteredPetitions = petitions
            tableView.reloadData()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredPetitions.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = filteredPetitions[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = filteredPetitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }

}

