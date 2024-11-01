//
//  GameViewController.swift
//  Project29 - Exploding Monkeys
//
//  Created by Stefan Storm on 2024/10/28.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    weak var currentGame: GameScene?
    
    
    
    @IBOutlet var angleSlider: UISlider!
    @IBOutlet var angleLabel: UILabel!
    @IBOutlet var velocitySlider: UISlider!
    @IBOutlet var velocityLabel: UILabel!
    @IBOutlet var launchButton: UIButton!
    @IBOutlet var playerNumber: UILabel!
    var gameOver = false
    
    @IBOutlet var playerOneScore: UILabel!
    var playerOneScoreInt = 0 {
        didSet{
            playerOneScore.text = "Score: \(playerOneScoreInt)"
        }
    }
    @IBOutlet var playerTwoScore: UILabel!
    var playerTwoScoreInt = 0 {
        didSet{
            playerTwoScore.text = "Score: \(playerTwoScoreInt)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
                
                currentGame = scene as? GameScene
                currentGame?.ViewController = self
                playerOneScoreInt = 0
                playerTwoScoreInt = 0
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
        angleChanged(self)
        velocityChanged(self)
        
        
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func angleChanged(_ sender: Any) {
        angleLabel.text = "Angle: \(Int(angleSlider.value))°"
    }
    
    @IBAction func velocityChanged(_ sender: Any) {
        velocityLabel.text = "Velocity:  \(Int(velocitySlider.value))"
    }
    
    @IBAction func launchTapped(_ sender: Any) {

        
        
        angleLabel.isHidden = true
        velocityLabel.isHidden = true
        
        angleSlider.isHidden = true
        velocitySlider.isHidden = true
        
        launchButton.isHidden = true
        playerNumber.isHidden = true
        
        playerOneScore.isHidden = true
        playerTwoScore.isHidden = true
        
        currentGame?.launch(angle: Int(angleSlider.value), velocity: Int(velocitySlider.value))
    }
    
    func activatePlayer(player: Int, gameOver: Bool) {

        angleLabel.isHidden = false
        velocityLabel.isHidden = false
        
        angleSlider.isHidden = false
        velocitySlider.isHidden = false
        
        launchButton.isHidden = false
        playerNumber.isHidden = false
        
        playerOneScore.isHidden = false
        playerTwoScore.isHidden = false
        
        
        if gameOver {
            launchButton.titleLabel?.adjustsFontForContentSizeCategory = true
            launchButton.titleLabel?.text = "Restarting..."
            
            if playerOneScoreInt == 3{
                playerNumber.text = "PLAYER ONE WINS"
            }else{
                playerNumber.text =  "PLAYER TWO WINS"
            }
            
            return
        }
        
        
        if player == 1{
            playerNumber.text =  "<<< PLAYER ONE"
        }else{
            playerNumber.text =  "PLAYER TWO >>>"
        }
        
        
    }
    
}
