//
//  ViewController.swift
//  Project25 - Selfie
//
//  Created by Stefan Storm on 2024/10/17.
//
import MultipeerConnectivity
import UIKit


class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MCSessionDelegate, MCBrowserViewControllerDelegate {
    var images = [Image]()

    var peerID = MCPeerID(displayName: UIDevice.current.name)
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Selfie Share"

        let connectionPrompt = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showConnectionPrompt))
        
        let connectedPeers = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showConnectedPeers))
        
        navigationItem.leftBarButtonItems = [connectionPrompt,connectedPeers]
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(importPicture))

        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
    }
    
    
    @objc func showConnectedPeers(){
        let peers = mcSession.connectedPeers
        
        let ac = UIAlertController(title: "Connected Peers", message: nil, preferredStyle: .actionSheet)
        for peer in peers {
            ac.addAction(UIAlertAction(title: peer.displayName, style: .default))
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
        
        
        
    }

    
    @objc func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage else { return }
        
        dismiss(animated: true) {
            let ac = UIAlertController(title: "Enter description", message: nil, preferredStyle: .alert)
            ac.addTextField()
            
            let addAction = UIAlertAction(title: "Rename", style: .default){ [weak self, weak ac] _ in
                guard let newName = ac?.textFields?[0].text else {return}
                self?.images.insert(Image(name: newName, image: image), at: 0)
                self?.collectionView.reloadData()
                
                if let count = self?.mcSession.connectedPeers.count  {
                    if count > 0 {
                        
                        do {
                            
                            let encodedData = try JSONEncoder().encode(Image(name: newName, image: image))
                            
                            print("Sending Data Size: \(encodedData.count)")
                            try self?.mcSession.send(encodedData, toPeers: self!.mcSession.connectedPeers, with: .reliable)
                            print("HereSend")
                        } catch {
                            let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
                            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self?.present(ac, animated: true)
                        }
                        
                    }
                    
                }
                
            }
            
            ac.addAction(addAction)
            self.present(ac, animated: true)
        }
        
    }

    
    @objc func showConnectionPrompt() {
        let ac = UIAlertController(title: "Connect to others", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Host a session", style: .default, handler: startHosting))
        ac.addAction(UIAlertAction(title: "Join a session", style: .default, handler: joinSession))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }

    
    func startHosting(action: UIAlertAction) {
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "hws-project25", discoveryInfo: nil, session: mcSession)
        mcAdvertiserAssistant.start()
    }

    
    func joinSession(action: UIAlertAction) {
        let mcBrowser = MCBrowserViewController(serviceType: "hws-project25", session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser, animated: true)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageView", for: indexPath)
    

        if let imageView = cell.viewWithTag(1000) as? UIImageView {
            imageView.image = images[indexPath.item].toUIImage()
            
        }
        
        if let label = cell.viewWithTag(999) as? UILabel {
            label.text = images[indexPath.item].toString()
            
        }

        return cell
    }
    
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        do {
            
            let receivedImageData = try JSONDecoder().decode(Image.self, from: data)

            if let image = receivedImageData.toUIImage() {
                print("All data received")
                DispatchQueue.main.async { [weak self] in
                    self?.images.insert(Image(name: receivedImageData.toString() ?? "Empty", image: image), at: 0)
                    self?.collectionView?.reloadData()
                }
            }
            
        } catch {
            
            DispatchQueue.main.async { [weak self] in
                let ac = UIAlertController(title: "Receive error", message: String(describing: error), preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(ac, animated: true)
            }
            
        }
    }
    
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")

        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")

        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
            DispatchQueue.main.async { [weak self] in
                let ac = UIAlertController(title: "\(peerID.displayName) not connected!", message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .cancel))
                self?.present(ac, animated: true)
            }

        @unknown default:
            print("Error")
        }
    }

    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {

    }

    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {

    }

    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {

    }

    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }

    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }

    
    
}

