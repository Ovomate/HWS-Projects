//
//  GameScene.swift
//  Project17 - Space Race
//
//  Created by Stefan Storm on 2024/10/02.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starField : SKEmitterNode = {
        var node = SKEmitterNode(fileNamed: "starfield")!
        node.position = CGPoint(x: 2556, y: 590)
        node.zPosition = -1
        node.advanceSimulationTime(10)
        return node
    }()
    
    var player : SKSpriteNode = {
        var node = SKSpriteNode(imageNamed: "player")
        node.position = CGPoint(x: 200, y: 590)
        node.zPosition = 0
        node.physicsBody = SKPhysicsBody(texture: node.texture!, size: node.size)
        node.physicsBody?.contactTestBitMask = 1
       return node
    }()
    
    var scoreLabel : SKLabelNode = {
        var node = SKLabelNode(fontNamed: "Futura")
        node.position = CGPoint(x: 50, y: 50)
        node.zPosition = 1
        node.horizontalAlignmentMode = .left
        node.fontSize = 50
        return node
    }()
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var possibleEnemies = ["ball", "hammer","tv"]
    var gameTimer: Timer?
    var gameOver = false
    
    
    

    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        setupScene()
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)

    }
    
    
    @objc func createEnemy(){
        print("Enemy Created")
        guard let enemy = possibleEnemies.randomElement() else {return}
        let sprite  = SKSpriteNode(imageNamed: enemy)
        sprite.position = CGPoint(x: 2700, y: Int.random(in: 50...1000))
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
        addChild(sprite)
        
    }
    
    
    func setupScene(){
        addChild(starField)
        addChild(player)
        addChild(scoreLabel)
        score = 0
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        for node in children{
            if node.position.x < -300{
                node.removeFromParent()
                
            }
        }
        
        if !gameOver{
            score += 1
        }
        
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        var location = touch.location(in: self)
        
        if location.y < 50 {
            location.y = 50
        }else if location.y > 1150{
            location.y = 1150
        }
        player.position = location
        
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        gameOver = true
    }
    
}
