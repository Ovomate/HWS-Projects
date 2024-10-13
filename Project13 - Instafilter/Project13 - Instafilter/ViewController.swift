//
//  ViewController.swift
//  Project13 - Instafilter
//
//  Created by Stefan Storm on 2024/09/24.
//
import CoreImage
import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var intensity: UISlider!
    @IBOutlet var radius: UISlider!
    @IBOutlet var scale: UISlider!
    var currentImage: UIImage!
    @IBOutlet var filterButton: UIButton!
    
    var context: CIContext!
    var currentFilter: CIFilter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Instafilter"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
        
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
        filterButton.setTitle("Current: CISepiaTone", for: .normal)
        
    }
    
    
    @objc func importPicture(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {return}
        dismiss(animated: true)
        currentImage = image
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)

        applyProcessing()
        
    }
    
   // https://developer.apple.com/documentation/coreimage/cifilterprotocol
    
    @IBAction func changeFilter(_ sender: UIButton) {
        guard imageView.image != nil else {
            let ac = UIAlertController(title: "Nothing to change!", message: "Please select photo first.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            return
        }
        
        let ac = UIAlertController(title: "Choose filter:", message: nil, preferredStyle: .actionSheet)
        
        ac.addAction(UIAlertAction(title: "CIZoomBlur", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIGlassDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIHoleDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIPhotoEffectTransfer", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CISRGBToneCurveToLinear", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIColorInvert", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIPhotoEffectMono", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CICircularWrap", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CILightTunnel", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIGlassLozenge", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIPinchDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIGlassLozenge", style: .default, handler: setFilter))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        
        
        if let popoverController = ac.popoverPresentationController{
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        present(ac, animated: true)
        
    }
    
    
    func setFilter(_ action: UIAlertAction){
        guard currentImage != nil else {return}
        guard let actionTitle = action.title else {return}
        
        //Challenge 2: Show current filter
        filterButton.setTitle("Current:\(actionTitle)", for: .normal)
        currentFilter = CIFilter(name: actionTitle)
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)

        applyProcessing()
    }
    
    
    @IBAction func save(_ sender: Any) {
        guard let image = imageView.image else {
            //Challenge 1
            let ac = UIAlertController(title: "Nothing to Save.", message: "Please select photo first.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            return
        }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    
    @IBAction func intensityChanged(_ sender: Any) {
        applyProcessing()
    }
 
    
    @IBAction func radiusChanged(_ sender: Any) {
        applyProcessing()
    }
    
    
    @IBAction func scaleChanged(_ sender: Any) {
        applyProcessing()
    }
    
    
    func applyProcessing(){
        let inputKeys = currentFilter.inputKeys
        //Print parameters to see which keys are available to play with.
        print(inputKeys)
        
        if inputKeys.contains(kCIInputIntensityKey){
            print("Intensity")
            currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
        }
        
        if inputKeys.contains(kCIInputRadiusKey){
            print("Radius")
            currentFilter.setValue(radius.value * 200, forKey: kCIInputRadiusKey)
        }
        
        if inputKeys.contains(kCIInputAngleKey) {
            print("Angle")
            currentFilter.setValue(scale.value * 10, forKey: kCIInputAngleKey)
        }
        
        if inputKeys.contains(kCIInputCenterKey){
            currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey)
        }
        
        guard let outputImage = currentFilter.outputImage else {return}
      
        imageView.alpha = 0
        
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent){
            let processedImage = UIImage(cgImage: cgImage)
            imageView.image = processedImage

            UIView.animate(withDuration: 2) {
                self.imageView.alpha = 1
            }
        }
    }
    
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer){
        if let error = error{
            let ac = UIAlertController(title: "Save Error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }else{
            let ac = UIAlertController(title: "Saved!", message: "Your altered photo has been saved to your library.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }


}

