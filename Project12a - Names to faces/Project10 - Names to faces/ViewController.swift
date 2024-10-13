//
//  ViewController.swift
//  Projecet10 - Names to faces
//
//  Created by Stefan Storm on 2024/09/17.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var people = [Person]()
    var defaults = UserDefaults.standard
    

    override func viewDidLoad() {
        super.viewDidLoad()
       
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
        
        if let savedPeople = defaults.object(forKey: "people") as? Data {
            if let decodedPeople = try? NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClasses: [Person.self], from: savedPeople) as? [Person]{
                people = decodedPeople
            }
        }
        
    }
    
    
    @objc func addNewPerson(){
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self

        let ac = UIAlertController(title: "Choose source", message: nil, preferredStyle: .alert)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let cameraAction = UIAlertAction(title: "Camera", style: .default){  [weak self] _ in
                picker.sourceType = .camera
                self?.present(picker,animated: true)
            }
            ac.addAction(cameraAction)
        }
        
        let libraryAction = UIAlertAction(title: "Library", style: .default){ [weak self] _ in
            picker.sourceType = .photoLibrary
            self?.present(picker,animated: true)
        }
        
        ac.addAction(libraryAction)
        present(ac, animated: true)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       guard let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            fatalError("Major fuckup!")
        }
        
        let person = people[indexPath.item]
        cell.name.text = person.name
        
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.cornerRadius = 5
        cell.layer.cornerRadius = 10
        
        return cell
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        guard let image = info[.editedImage ] as? UIImage else {return}
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        if let jpegData = image.jpegData(compressionQuality: 0.8){
            try? jpegData.write(to: imagePath)
        }
        
        let person = Person(name: "unknown", image: imageName)
        people.append(person)
        save()
        collectionView.reloadData()
        
        dismiss(animated: true)
    }
    
    
    func getDocumentsDirectory() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)
        return paths[0]
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = people[indexPath.item]
        
        let ac = UIAlertController(title: "Choose action", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let addAction = UIAlertAction(title: "Rename", style: .default){ [weak self, weak ac] _ in
            guard let newName = ac?.textFields?[0].text else {return}
            person.name = newName
            self?.save()
            self?.collectionView.reloadData()
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .default){ [weak self] _ in
            self?.people.remove(at: indexPath.item)
            self?.save()
            self?.collectionView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        ac.addAction(addAction)
        ac.addAction(cancelAction)
        ac.addAction(deleteAction)
        present(ac, animated: true)
    }
    
    func save(){
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: people, requiringSecureCoding: false){
            defaults.set(savedData, forKey: "people")
        }
        
    }


}

