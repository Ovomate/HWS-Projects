//
//  ViewController.swift
//  Project6b
//
//  Created by Stefan Storm on 2024/09/03.
//

import UIKit

class ViewController: UIViewController {
    
    let label1: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .blue
        label.text = "These"
        label.sizeToFit()
        return label
    }()
    
    let label2: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .blue
        label.text = "These"
        label.sizeToFit()
        return label
    }()
    
    let label3: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .blue
        label.text = "These"
        label.sizeToFit()
        return label
    }()
    
    let label4: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .blue
        label.text = "These"
        label.sizeToFit()
        return label
    }()
    
    let label5: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .blue
        label.text = "These"
        label.sizeToFit()
        return label
    }()
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        view.addSubview(label1)
        view.addSubview(label2)
        view.addSubview(label3)
        view.addSubview(label4)
        view.addSubview(label5)
        setupLabels()
        

        

        
//        let viewsDictionary = ["label1": label1, "label2": label2, "label3": label3, "label4": label4, "label5": label5]
//        let metrics = ["labelHeight": 88]
//        
//        for label in viewsDictionary.keys{
//            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[\(label)]|", options: [], metrics: nil, views: viewsDictionary))
//        }
//        
//        
//        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[label1(labelHeight@999)]-[label2(label1)]-[label3(label1)]-[label4(label1)]-[label5(label1)]-(>=10)-|", options: [], metrics: metrics, views: viewsDictionary))
        
    }
    
    
    func setupLabels(){

        
        let labels = [label1,label2,label3,label4,label5]
        var previous: UILabel?
        
        for label in labels{
            
            label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
            label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
            label.heightAnchor.constraint(equalToConstant: view.frame.height / 5).isActive = true
            
            if let previous = previous {
                label.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 10).isActive = true
                
            }else{
                label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
            }
            previous = label
            
        }
        
    }
    
//    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
//        setupLabels()
//        view.setNeedsLayout()
//        view.layoutIfNeeded()
//        view.needsUpdateConstraints()
//    }
    
    


}

