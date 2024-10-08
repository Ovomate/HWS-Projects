//
//  ScriptViewController.swift
//  Extension
//
//  Created by Stefan Storm on 2024/10/08.
//

import UIKit

protocol ScriptViewControllerDelegate: AnyObject {
    func didSelectItem(_ selectedItem: String)
}

class ScriptViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {


    var cellID = "cellID"
    let defaults = UserDefaults.standard
    weak var delegate: ScriptViewControllerDelegate?
    var script = [String: Any]()

    
    lazy var scriptTableView: UITableView = {
        let tv = UITableView(frame: CGRect.zero, style: .plain)
        tv.register(ScriptTableViewCell.self, forCellReuseIdentifier: cellID)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.dataSource = self
        tv.delegate = self
        tv.layer.cornerRadius = 20
        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.layer.borderWidth = 1
        return tv
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white

        
        setupView()
        DispatchQueue.global().async { [weak self] in
            if let scriptDict = self?.defaults.dictionary(forKey: "scriptDict") {
                self?.script = scriptDict

            }
        }

    }
    
    
    func setupView(){
        view.addSubview(scriptTableView)
        
        NSLayoutConstraint.activate([
            scriptTableView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 10) ,
            scriptTableView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            scriptTableView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            scriptTableView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -10),
            
            
        ])

    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let keys = Array(script.keys)
        return keys.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? ScriptTableViewCell else {fatalError()}
        let keys = Array(script.keys)
        let key = keys[indexPath.row]
        cell.scriptLabel.text = key
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let keys = Array(script.keys)
        let key = keys[indexPath.row]
        delegate?.didSelectItem(script[key] as! String)
        navigationController?.popViewController(animated: true)
    }

}
