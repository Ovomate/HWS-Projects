//
//  DetailViewController.swift
//  Project1
//
//  Created by Stefan Storm on 2024/08/24.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var selectedImage: String?
    var selectedImageViews: Int?
    var pictureArray: [String]?
    var selectedIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        assert(selectedImage != nil, "Image = nil")
        
        if let selectedIndex = selectedIndex, let pictureArray = pictureArray {
            title = "Image \(selectedIndex + 1) of \(pictureArray.count)"
        }

        if let imageToLoad = selectedImage{
            imageView.image = UIImage(named: imageToLoad)
        }
  
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
        
    }
    

    
    
}
