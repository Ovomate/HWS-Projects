//
//  GameScene.swift
//  Project26 - Marble Maze
//
//  Created by Stefan Storm on 2024/10/18.
//

import SpriteKit
import CoreMotion

enum CollisionTypes: UInt32 {
    case player = 1
    case wall = 2
    case star = 4
    case vortex = 8
    case finish = 16
    case teleport = 32
}

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    var lastTouchPosition: CGPoint?
    var motionManager : CMMotionManager?
    var player: SKSpriteNode!
    var isGameOver = false
    var playerStartingPosition: CGPoint?
    var teleportEntry: CGPoint?
    var teleportExit: CGPoint?
    var teleportEntryNode: SKSpriteNode!
    var teleportExitNode: SKSpriteNode!
    
    let background : SKSpriteNode = {
        let node = SKSpriteNode(imageNamed: "background")
        node.zPosition = -1
        node.anchorPoint = CGPoint(x: 0, y: 0)
        node.blendMode = .replace
        return node
    }()
    
    var gameScoreLabel : SKLabelNode = {
       let node = SKLabelNode(fontNamed: "Marker Felt")
        node.position = CGPoint(x: 50, y: 25)
        node.text = "Score: 0"
        node.fontSize = 80
        node.zPosition = 2
        node.horizontalAlignmentMode = .left
        return node
    }()
    var score : Int = 0 {
        didSet{
            gameScoreLabel.text = "Score: \(score)"
        }
    }
    
    var gameLevelLabel : SKLabelNode = {
       let node = SKLabelNode(fontNamed: "Marker Felt")
        node.position = CGPoint(x: 400, y: 25)
        node.text = "Level: 1"
        node.fontSize = 80
        node.zPosition = 2
        node.horizontalAlignmentMode = .left
        return node
    }()
    var level : Int = 1 {
        didSet {
            gameLevelLabel.text = "Level: \(level)"
        }
    }
    
    override func didMove(to view: SKView) {
        loadLevel()
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero
        
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
    }
    
    func createPlayer(position: CGPoint){
        player = SKSpriteNode(imageNamed: "player")
        player.zPosition = 1
        player.position = position
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 1.6)
        player.size = CGSize(width: player.frame.width * 1.6 , height: player.frame.height * 1.6)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.angularDamping = 0.5
        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player.physicsBody?.contactTestBitMask = CollisionTypes.star.rawValue | CollisionTypes.vortex.rawValue | CollisionTypes.finish.rawValue
        player.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue
        addChild(player)
    }
    
    func createWall(position: CGPoint){
        let node = SKSpriteNode(imageNamed: "block")
        node.position = position
        node.size = CGSize(width: node.frame.width * 1.6, height: node.frame.height * 1.6)
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
        node.physicsBody?.isDynamic = false
        
        addChild(node)
    }
    
    
    func createVortex(position: CGPoint){
        let node = SKSpriteNode(imageNamed: "vortex")
        node.position = position
        node.name = "vortex"
        node.size = CGSize(width: node.frame.width * 1.6, height: node.frame.height * 1.6)
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.frame.width / 2)
        node.physicsBody?.categoryBitMask = CollisionTypes.vortex.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.physicsBody?.isDynamic = false
        node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
        
        addChild(node)
    }
    
    func createStar(position: CGPoint){
        let node = SKSpriteNode(imageNamed: "star")
        node.name = "star"
        node.position = position
        node.size = CGSize(width: node.frame.width * 1.6, height: node.frame.height * 1.6)
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.categoryBitMask = CollisionTypes.star.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.physicsBody?.isDynamic = false
        
        addChild(node)
    }
    
    func createFinish(position: CGPoint){
        let node = SKSpriteNode(imageNamed: "finish")
        node.name = "finish"
        node.position = position
        node.size = CGSize(width: node.frame.width * 1.6, height: node.frame.height * 1.6)
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.categoryBitMask = CollisionTypes.finish.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.physicsBody?.isDynamic = false
        
        addChild(node)
    }
    
    func createTeleportEntry(position: CGPoint){
        teleportEntryNode = SKSpriteNode(imageNamed: "portal")
        teleportEntryNode.position = position
        teleportEntryNode.name = "portal"
        teleportEntryNode.size = CGSize(width: teleportEntryNode.frame.width / 1.5 , height: teleportEntryNode.frame.height / 1.5 )
        teleportEntryNode.physicsBody = SKPhysicsBody(circleOfRadius: teleportEntryNode.frame.width / 2)
        teleportEntryNode.physicsBody?.categoryBitMask = CollisionTypes.teleport.rawValue
        teleportEntryNode.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        teleportEntryNode.physicsBody?.collisionBitMask = 0
        teleportEntryNode.physicsBody?.isDynamic = false
        teleportEntryNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
        
        addChild(teleportEntryNode)
    }
    
    func createTeleportExit(position: CGPoint){
        teleportExitNode = SKSpriteNode(imageNamed: "portal")
        teleportExitNode.position = position
        teleportExitNode.name = "portal"
        teleportExitNode.size = CGSize(width: teleportExitNode.frame.width / 1.5 , height: teleportExitNode.frame.height / 1.5 )
        teleportExitNode.physicsBody = SKPhysicsBody(circleOfRadius: teleportExitNode.frame.width / 2)
        teleportExitNode.physicsBody?.categoryBitMask = CollisionTypes.teleport.rawValue
        teleportExitNode.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        teleportExitNode.physicsBody?.collisionBitMask = 0
        teleportExitNode.physicsBody?.isDynamic = false
        teleportExitNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
        
        addChild(teleportExitNode)
    }
    
    
    func loadLevel(){
        isGameOver = false
        background.size.width = self.size.width
        background.size.height = self.size.height
        
        addChild(background)
        addChild(gameScoreLabel)
        addChild(gameLevelLabel)
        
        guard let levelURL = Bundle.main.url(forResource: "level\(level)", withExtension: ".txt") else {
        fatalError("Could not load level from Bundle")}
        guard let levelSting = try? String(contentsOf: levelURL) else {
        fatalError("Could not load level from Bundle")}
        
        let lines = levelSting.components(separatedBy: "\n")
        
        for (row, line) in lines.reversed().enumerated() {
            for (column, letter) in line.enumerated(){
                let position = CGPoint(x: (100 * column) + 100, y: (100 * row) - 48)
                
                if letter == "x"{
                    createWall(position: position)
                }else if letter == "v"{
                    createVortex(position: position)
                }else if letter == "s"{
                    createStar(position: position)
                }else if letter == "f"{
                    createFinish(position: position)
                }else if letter == "p"{
                    playerStartingPosition = position
                    createPlayer(position: position)
                }else if letter == "t"{
                    createTeleportEntry(position: position)
                    teleportEntry = position
                }else if letter == "e"{
                    createTeleportExit(position: position)
                    teleportExit = position
                }else if letter == " "{
                    //Space on level - do nothing
                    
                }else{
                    fatalError("Uknown letter \(letter)")
                }
                
            }
            
        }
        
    }
    
    
    //MARK: Methods used to test gravity in simulator
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = nil
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver else {return}
        
        #if targetEnvironment(simulator)
        if let currentTouch = lastTouchPosition {
            let diff = CGPoint(x: currentTouch.x - player.position.x, y: currentTouch.y - player.position.y)
            physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
        }
        #else
        if let accelerometerData = motionManager?.accelerometerData{
            //Flip X and Y because orientation is in landscape
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
        }
        #endif
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else {return}
        guard let nodeB = contact.bodyB.node else {return}
        
        if nodeA == player{
            playerCollided(with: nodeB)
        }else if nodeB == player{
            playerCollided(with: nodeA)
        }
        
    }
    
    func playerCollided(with node: SKNode){
        
        if node.name == "vortex"{
            isGameOver = true
            player.physicsBody?.isDynamic = false
            score -= 1
            
            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            let seq = SKAction.sequence([move,scale,remove])
            player.run(seq){ [weak self] in
                self?.createPlayer(position: self?.playerStartingPosition ?? CGPoint(x: 500, y: 500))
                self?.isGameOver = false
            }
            
        }else if node.name == "star"{
            
            let emitter = SKEmitterNode(fileNamed: "starExplosion")
            emitter?.position = node.position
            emitter?.zPosition = 0
            addChild(emitter!)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                emitter?.removeFromParent()
            }
            
            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            let seq = SKAction.sequence([scale,remove])
            node.run(seq){ [weak self] in
                self?.score += 1
            }
            
        }else if node.name == "finish"{
            
            let emitter = SKEmitterNode(fileNamed: "finishExplosion")
            emitter?.position = node.position
            emitter?.zPosition = 0
            addChild(emitter!)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                emitter?.removeFromParent()
            }
            
            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            let seq = SKAction.sequence([scale,remove])
            node.run(seq)
            
            isGameOver = true
            player.physicsBody?.isDynamic = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3){ [weak self] in
                self?.level += 1
                self?.scene?.removeAllChildren()
                self?.loadLevel()
                
            }
            
        }else if node.name == "portal"{
            var tempPosition : CGPoint?
            
            let currentPosX = Int(node.position.x)
            let currentPosY = Int(node.position.y)
            let currentPos = CGPoint(x: currentPosX, y: currentPosY)
            
            if currentPos == teleportEntry {
                tempPosition = teleportExit
            }else{
                tempPosition = teleportEntry
            }
            
            player.physicsBody?.isDynamic = false
            teleportEntryNode.physicsBody?.contactTestBitMask = 0
            teleportExitNode.physicsBody?.contactTestBitMask = 0
            
            let move = SKAction.move(to: node.position, duration: 0.25)
            let scaleDown = SKAction.scale(to: 0.0001, duration: 0.25)
            let moveTo = SKAction.move(to: tempPosition!, duration: 0.25)
            let scaleUp = SKAction.scale(to: 1, duration: 0.25)
            
            let seq = SKAction.sequence([move,scaleDown,moveTo,scaleUp])
            player.run(seq){ [weak self] in
                
                self?.player.physicsBody?.isDynamic = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self?.player.physicsBody?.contactTestBitMask = CollisionTypes.star.rawValue | CollisionTypes.vortex.rawValue | CollisionTypes.finish.rawValue
                    self?.teleportEntryNode.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                    self?.teleportExitNode.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                }
            }
        }
    }
    
    
    
}
