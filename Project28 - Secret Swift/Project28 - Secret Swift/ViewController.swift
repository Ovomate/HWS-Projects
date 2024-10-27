//
//  ViewController.swift
//  Project28 - Secret Swift
//
//  Created by Stefan Storm on 2024/10/26.
//

import LocalAuthentication
import UIKit


class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet var secret: UITextView!
    @IBOutlet var imageView: UIImageView!
    
    var lockButton: UIBarButtonItem!
    var addPicButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Nothing to see here!"
        
        lockButton = UIBarButtonItem(title: "Lock", style: .plain, target: self, action: #selector(saveSecretMessage))
        addPicButton = UIBarButtonItem(title: "Add Pic", style: .plain, target: self, action: #selector(addPicture))
        
       
        self.lockButton?.isEnabled = false
        self.lockButton?.tintColor = UIColor.clear
        self.addPicButton?.isEnabled = false
        self.addPicButton?.tintColor = UIColor.clear
        
        
        navigationItem.rightBarButtonItems = [addPicButton, lockButton]
       
        // MARK: Cursor to not disappear behind software keyboard
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)
        
    }
    
    @objc func addPicture(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage ] as? UIImage else {return}
        imageView.image = image
        
        dismiss(animated: true)
    }
    
    
    @objc func adjustForKeyboard(notification : Notification){
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        
        let keyboardEndScreen = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardEndScreen, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            
            secret.contentInset = .zero
        }else{
            
            secret.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        secret.scrollIndicatorInsets = secret.contentInset
        
        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
    }
    
    
    func unlockSecretMessage(){
        secret.isHidden = false
        imageView.isHidden = false
        title = "Secret Stuff!"
        lockButton?.isEnabled = true
        lockButton?.tintColor = UIColor.systemBlue
        addPicButton?.isEnabled = true
        addPicButton?.tintColor = UIColor.systemBlue
        if let text = KeychainWrapper.standard.string(forKey: "secretMessage"){
            secret.text = text
        }
        
        if let imageData = KeychainWrapper.standard.data(forKey: "secretImage"){
            imageView.image = UIImage(data: imageData)
        }
        
       //OR: secret.text = KeychainWrapper.standard.string(forKey: "secretMessage") ?? "First message"
        
    }
    
    @objc func saveSecretMessage(){
        guard secret.isHidden == false else {return}
        
        KeychainWrapper.standard.set(secret.text, forKey: "secretMessage")
        
        if let image = imageView.image?.pngData(){
            KeychainWrapper.standard.set(image, forKey: "secretImage")
        }
       
        self.lockButton?.isEnabled = false
        self.lockButton?.tintColor = UIColor.clear
        self.addPicButton?.isEnabled = false
        self.addPicButton?.tintColor = UIColor.clear
        
        secret.resignFirstResponder()
        secret.isHidden = true
        imageView.isHidden = true
        title = "Nothing to see here!"
    }
    
    @IBAction func authenticateTapped(_ sender: Any) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
            let reason = "Identify yourself!"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success , autheticationError in
                
                DispatchQueue.main.async {
                    if success {
                        self?.unlockSecretMessage()
                    }else{
                        let ac = UIAlertController(title: "Authentication failed!", message: "Please try again!", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(ac, animated: true)
                    }
                }
            }
            
        }else{
            
            let ac = UIAlertController(title: "Biometrics unavailable", message: "Your phone is not configured for biometric use.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            ac.addAction(UIAlertAction(title: "Use password", style: .default, handler: { [weak self] _ in
                
                print("Entered")
                let firstLoad = KeychainWrapper.standard.bool(forKey: "firstLoad")
                
                if firstLoad == nil {
                    self?.createPassword()
                    
                }else{
                    self?.enterPassword()
                }
                
            }))
            self.present(ac, animated: true)
        }

    }
    
    func enterPassword(){
        let ac = UIAlertController(title: "Enter password", message: nil, preferredStyle: .alert)
        ac.addTextField()
        let action = UIAlertAction(title: "Enter", style: .default){ [weak self, weak ac] _ in
            guard let password = ac?.textFields?[0].text else {return}
            
            if let savedPassword = KeychainWrapper.standard.string(forKey: "passwordForApp"){
                if password == savedPassword {
                    self?.unlockSecretMessage()
                }else{
                    
                    let ac = UIAlertController(title: "Password incorrect!", message: "Please try again", preferredStyle: .alert)
                    self?.present(ac, animated: true){
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                            ac.dismiss(animated: true)
                        }
                        
                    }
                    return
                }
            }
        }
        
        ac.addAction(action)
        present(ac, animated: true)
        
    }
    
    
    func createPassword(){
        
        let ac = UIAlertController(title: "Please enter 8 letter password!", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addTextField()
        let action = UIAlertAction(title: "Continue", style: .default){[weak self, weak ac] _ in
            guard let passwordFirst = ac?.textFields?[0].text else {return}
            guard let passwordSecond = ac?.textFields?[1].text else {return}
            
            if passwordFirst.count < 8 {
                let ac = UIAlertController(title: "Password is not 8 characters!", message: "Please try again", preferredStyle: .alert)
                self?.present(ac, animated: true){
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                        ac.dismiss(animated: true)
                    }
                    
                }
                return
            }
            
            if passwordFirst != passwordSecond {
                let ac = UIAlertController(title: "Passwords don't match!", message: "Please try again", preferredStyle: .alert)
                self?.present(ac, animated: true){
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                        ac.dismiss(animated: true)
                    }
                }
                return
            }
            
            KeychainWrapper.standard.set(false, forKey: "firstLoad")
            KeychainWrapper.standard.set(passwordSecond, forKey: "passwordForApp")
            self?.unlockSecretMessage()
            
        }
        
        ac.addAction(action)
        present(ac, animated: true)
    }
    
    
    
    
    
}

