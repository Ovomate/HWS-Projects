//
//  ScriptTableViewCell.swift
//  Extension
//
//  Created by Stefan Storm on 2024/10/08.
//

import UIKit

class ScriptTableViewCell: UITableViewCell {
    
    
    var scriptLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Test"
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.numberOfLines = 0
        label.clipsToBounds = true

        return label
    }()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.accessoryType = .disclosureIndicator
        
        setupCell()
        
        
    }
    
    
    func setupCell(){
        
        self.addSubview(scriptLabel)
        
        NSLayoutConstraint.activate([
            scriptLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            scriptLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 5),
            scriptLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5),
            scriptLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),

            
            ])
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
