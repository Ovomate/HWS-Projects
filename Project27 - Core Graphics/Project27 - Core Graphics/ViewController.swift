//
//  ViewController.swift
//  Project27 - Core Graphics
//
//  Created by Stefan Storm on 2024/10/21.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate  {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var redrawButton: UIButton!
    var currentDrawType = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPhoto))
        let share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(sharePhoto))
        
        navigationItem.rightBarButtonItems = [add, share]
        
        drawRectangle()
    }
    
    
    @objc func sharePhoto(){
        if let image = imageView.image?.pngData() {
            let vc = UIActivityViewController(activityItems:[image], applicationActivities: nil)
            present(vc, animated: true)
        }

        
    }
    
    @objc func addPhoto(){
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
        
    }
    
    //Picked image drawn to canvas and watermark added over it.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let photo = info[.editedImage ] as? UIImage else {return}
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1028, height: 1028))
        
        let image = renderer.image{ctx in
            
            let rect = CGRect(x: 0, y: 0, width: 1028, height: 1028).insetBy(dx: 10, dy: 10)
            
            photo.draw(in: rect)
            
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributes : [NSAttributedString.Key: Any] = [
                .font : UIFont.systemFont(ofSize: 60),
                .foregroundColor : UIColor.black.withAlphaComponent(0.2),
                .paragraphStyle : paragraphStyle
            ]
            
            let string = "This picture has been watermarked!"
            let attributedString = NSAttributedString(string: string, attributes: attributes)
            var moveBy = 128
            
            for _ in 1...10 {

                attributedString.draw(at: CGPoint(x: 64, y: moveBy))
                moveBy += 128
                
            }

        }
        
        imageView.image = image
        
        dismiss(animated: true)
    }
    
    
    

    @IBAction func redrawButtonTapped(_ sender: Any) {
        currentDrawType += 1
        
        if currentDrawType > 10{
            currentDrawType = 0
        }
        
        switch currentDrawType{
        case 0:
            drawRectangle()
        case 1:
            drawCircle()
        case 2:
            drawCheckerboard()
        case 3:
            drawRotatedSquares()
        case 4:
            drawLines()
        case 5:
            drawImagesAndText()
        case 6:
            drawEmoji()
        case 7:
            drawTWIN()
        default:
            break
        }
        
        
    }
    
    func drawRectangle(){
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1028, height: 1028))
        
        let image = renderer.image{ctx in
            let rect = CGRect(x: 0, y: 0, width: 1028, height: 1028).insetBy(dx: 10, dy: 10)
            
            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(10)
            ctx.cgContext.addRect(rect)
            ctx.cgContext.drawPath(using: .fillStroke)
            
        }
        
        imageView.image = image
    }
    
    func drawCircle(){
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1028, height: 1028))
        
        let image = renderer.image{ctx in
            let rect = CGRect(x: 0, y: 0, width: 1028, height: 1028).insetBy(dx: 10, dy: 10)
            
            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(10)
            ctx.cgContext.addEllipse(in:rect)
            ctx.cgContext.drawPath(using: .fillStroke)
            
        }
        
        imageView.image = image
        
    }
    
    func drawCheckerboard(){
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1028, height: 1028))
        
        let image = renderer.image{ctx in
            ctx.cgContext.setFillColor(UIColor.black.cgColor)
            
            for row in 0..<8{
                for col in 0..<8{
                    if (row + col) % 2 == 0 {
                        ctx.cgContext.fill(CGRect(x: col * 128, y: row * 128, width: 128, height: 128))
                    }
                }
            }
        }
        
        imageView.image = image
    }
    
    func drawRotatedSquares(){
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1028, height: 1028))
        
        let image = renderer.image{ctx in
            ctx.cgContext.translateBy(x: 512, y: 512)
            
            let rotations = 16
            let amount = Double.pi / Double(rotations)

            for _ in 0..<rotations{
                ctx.cgContext.rotate(by: amount)
                ctx.cgContext.addRect(CGRect(x: -256, y: -256, width: 512, height: 512))
            }
            
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.strokePath()
            
        }
        
        imageView.image = image
    }
    
    func drawLines(){
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1028, height: 1028))
        
        let image = renderer.image{ctx in
            ctx.cgContext.translateBy(x: 512, y: 512)
            
            var first = true
            var length : CGFloat = 512
            
            for _ in 0..<512{
                ctx.cgContext.rotate(by: .pi / 3)
                
                if first {
                    ctx.cgContext.move(to: CGPoint(x: length, y: 50))
                    first = false
                }else{
                    ctx.cgContext.addLine(to: CGPoint(x: length, y: 50))
                }
                
                length *= 0.99
            }
            
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.strokePath()
            
        }
        
        imageView.image = image
    }
    
    func drawImagesAndText(){
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1028, height: 1028))
        
        let image = renderer.image{ctx in
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributes : [NSAttributedString.Key: Any] = [
                .font : UIFont.systemFont(ofSize: 48),
                .paragraphStyle : paragraphStyle
            ]
            
            let string = "Die muis se moer!"
            
            let attributedString = NSAttributedString(string: string, attributes: attributes)
            attributedString.draw(with: CGRect(x: 0, y: 0, width: 1028, height: 1028).insetBy(dx: 10, dy: 10), options: .usesLineFragmentOrigin, context: nil)
            
            let mouse = UIImage(named: "mouse")
            mouse?.draw(at: CGPoint(x: 512, y: 256))
            
        }
        
        imageView.image = image
        
    }
    
    func drawEmoji(){
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        
        
        let image = renderer.image { ctx in
            let rect = CGRect(x: 0, y: 0, width: 512, height: 512).insetBy(dx: 10, dy: 10)
            //Center the context because the Rect is maller that Renderer
           // ctx.cgContext.translateBy(x: 256, y: 256)
            
            //Create the emoji body
            ctx.cgContext.setFillColor(UIColor(red: 255/255, green: 222/255, blue: 51/255, alpha: 1).cgColor)
            ctx.cgContext.addEllipse(in:rect)
            ctx.cgContext.drawPath(using: .fillStroke)
            //Create left eye
            ctx.cgContext.addEllipse(in: CGRect(origin: CGPoint(x: 96, y: 128), size: CGSize(width: 128, height: 128)))
            ctx.cgContext.setFillColor(UIColor.white.cgColor)
            ctx.cgContext.drawPath(using: .fillStroke)
            //Create left pupil
            ctx.cgContext.addEllipse(in: CGRect(origin: CGPoint(x: 144, y: 128), size: CGSize(width: 32, height: 32)))
            ctx.cgContext.setFillColor(UIColor.black.cgColor)
            ctx.cgContext.drawPath(using: .fillStroke)
            //Create right eye
            ctx.cgContext.addEllipse(in: CGRect(origin: CGPoint(x: 286, y: 128), size: CGSize(width: 128, height: 128)))
            ctx.cgContext.setFillColor(UIColor.white.cgColor)
            ctx.cgContext.drawPath(using: .fillStroke)
            //Create right pupil
            ctx.cgContext.addEllipse(in: CGRect(origin: CGPoint(x: 336, y: 128), size: CGSize(width: 32, height: 32)))
            ctx.cgContext.setFillColor(UIColor.black.cgColor)
            ctx.cgContext.drawPath(using: .fillStroke)
            
            //Create mouth
            ctx.cgContext.move(to: CGPoint(x: 216, y: 384))
            
            ctx.cgContext.addLine(to: CGPoint(x: 296, y: 384))
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(10)
            ctx.cgContext.strokePath()

            
        }
        
        imageView.image = image
        
    }
    
    func drawTWIN(){
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1024, height: 1024))
        
        
        
        let image = renderer.image { ctx in
    
            ctx.cgContext.move(to: CGPoint(x: 206, y: 256))
            //T
            ctx.cgContext.addLine(to: CGPoint(x: 306, y: 256))
            ctx.cgContext.move(to: CGPoint(x: 256, y: 256))
            ctx.cgContext.addLine(to: CGPoint(x: 256, y: 356))
            ctx.cgContext.move(to: CGPoint(x: 320, y: 256))
            //W
            ctx.cgContext.addLine(to: CGPoint(x: 352, y: 356))
            ctx.cgContext.move(to: CGPoint(x: 352, y: 356))
            ctx.cgContext.addLine(to: CGPoint(x: 384, y: 256))
            ctx.cgContext.move(to: CGPoint(x: 384, y: 256))
            ctx.cgContext.addLine(to: CGPoint(x: 416, y: 356))
            ctx.cgContext.move(to: CGPoint(x: 416, y: 356))
            ctx.cgContext.addLine(to: CGPoint(x: 448, y: 256))
            //I
            ctx.cgContext.move(to: CGPoint(x: 468, y: 256))
            ctx.cgContext.addLine(to: CGPoint(x: 468, y: 356))
            //N
            ctx.cgContext.move(to: CGPoint(x: 488, y: 356))
            ctx.cgContext.addLine(to: CGPoint(x: 488, y: 256))
            ctx.cgContext.move(to: CGPoint(x: 488, y: 256))
            ctx.cgContext.addLine(to: CGPoint(x: 545, y: 356))
            ctx.cgContext.move(to: CGPoint(x: 545, y: 356))
            ctx.cgContext.addLine(to: CGPoint(x: 545, y: 256))
            
            
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(5)
            ctx.cgContext.strokePath()
            
            
        }
        
        imageView.image = image
    }
    
    

}

