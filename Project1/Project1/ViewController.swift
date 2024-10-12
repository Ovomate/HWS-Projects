//
//  ViewController.swift
//  Project1
//
//  Created by Stefan Storm on 2024/08/24.
//

import UIKit

class ViewController: UICollectionViewController {
    
    
    var pictures = [Picture]()
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Storm Viewer"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = UIColor.black
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
        loadPictures()
    }
    
     func viewWillAppear() {
        super.viewWillAppear(true)
        self.collectionView.reloadData()
    }
    
    
    func loadPictures(){

        DispatchQueue.global(qos: .background).async {[weak self] in
            guard let firstLoad = self?.defaults.bool(forKey: "firstLoad") else {return}
            if  !firstLoad {
                print("FirstSave")
                let fm = FileManager.default
                let path = Bundle.main.resourcePath!
                let items = try! fm.contentsOfDirectory(atPath: path)
                for item in items {
                    if item.hasPrefix("nssl"){
                        let picture = Picture.init(image: item, views: 0)
                        self?.pictures.append(picture)
                    }
                }
                
                self?.defaults.set(true, forKey: "firstLoad")
                self?.savePictures()
                
            }else{
                print("FirstSave Not")
                if let savedPicture = self?.defaults.object(forKey: "pictures") as? Data {
                    let jsonDecoder = JSONDecoder()
                    
                    do{
                        self?.pictures = try jsonDecoder.decode([Picture].self, from: savedPicture)
                        for picture in self!.pictures {
                            print(picture.image)
                            print(picture.views)
                        }
                    }catch{
                        print("Failed")
                    }

                }
    
            }
            
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
        
    }
    
    
    func savePictures(){
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(pictures){
            defaults.set(savedData, forKey: "pictures")
        }else{
            print("Save failure")
        }
    }
    
    
    @objc func shareTapped(){
        let url = URL(string: "https://apps.apple.com/us")!
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(vc, animated: true)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pictures.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Picture", for: indexPath) as? PictureCell else {fatalError("Error")}
        cell.label.text = pictures[indexPath.row].image
        cell.viewsLabel.text = "Views: \(String(pictures[indexPath.row].views))"
        cell.imageView.image = UIImage(named: pictures[indexPath.row].image)
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.cornerRadius = 5
        cell.layer.cornerRadius = 10
        return cell
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as?
            DetailViewController{
            
            
            pictures[indexPath.item].views += 1
            savePictures()
            collectionView.reloadData()
            vc.selectedImage = pictures[indexPath.item].image
            vc.selectedIndex = indexPath.item
            vc.pictureArray = pictures as? [String]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
  
    
// MARK: Tableview setup
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return pictures.count
//    }
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
//        
//        cell.textLabel?.text = pictures[indexPath.row]
//        return cell
//    }
//    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as?
//            DetailViewController{
//            vc.selectedImage = pictures[indexPath.row]
//            vc.selectedIndex = indexPath.row
//            vc.pictureArray = pictures
//            navigationController?.pushViewController(vc, animated: true)
//        }
//    }


}
