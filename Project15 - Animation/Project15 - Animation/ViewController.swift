//
//  ViewController.swift
//  Project15 - Animation
//
//  Created by Stefan Storm on 2024/09/28.
//

import UIKit

class ViewController: UIViewController {
    var imageView: UIImageView!
    var currentAnimation = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView = UIImageView()
        imageView.image = UIImage(named: "penguin")
        imageView.frame = CGRect(x: view.frame.midX, y: view.frame.midY, width: view.frame.width / 2, height: view.frame.height / 2)
        imageView.center = view.center
        imageView.contentMode = .scaleAspectFit
        print(view.center)
        print(view.frame.midX)
        print(imageView.frame.midX)
        print(view.frame.midX)
        view.addSubview(imageView)
    }
    

    @IBAction func Tapped(_ sender: UIButton) {
        sender.isHidden = true
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5) {
            switch self.currentAnimation{
            case 0:
                self.imageView.transform = CGAffineTransform(scaleX: 2, y: 2)
                break
            case 1:
                //Reset to original image.
                self.imageView.transform = .identity
            case 2:
                self.imageView.transform = CGAffineTransform(translationX: self.imageView.frame.maxX, y: self.imageView.frame.maxY)
            case 3:
                self.imageView.transform = .identity
            case 4:
                self.imageView.transform = CGAffineTransform(rotationAngle: .pi)
            case 5:
                self.imageView.transform = .identity
            case 6:
                self.imageView.backgroundColor = .black
                self.imageView.alpha = 0.1
            case 7:
                self.imageView.backgroundColor = .clear
                self.imageView.alpha = 1
                
            default:
                break
            }
        } completion: { finished in
            sender.isHidden = false
        }

        
        currentAnimation += 1
        if currentAnimation > 7 {
            currentAnimation = 0
        }
        
        
    }
    

}

