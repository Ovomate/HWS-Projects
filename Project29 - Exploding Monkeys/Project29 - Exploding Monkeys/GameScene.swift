//
//  GameScene.swift
//  Project29 - Exploding Monkeys
//
//  Created by Stefan Storm on 2024/10/28.
//

import SpriteKit

enum CollisionTypes : UInt32{
    case banana = 1
    case building = 2
    case player = 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var buildings = [BuildingNode]()
    weak var ViewController : GameViewController?
    
    var player1: SKSpriteNode!
    var player2: SKSpriteNode!
    var banana: SKSpriteNode!
    var gameOver = false
    
    var currentPlayer = 1
    
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(hue: 0.669 , saturation: 0.99, brightness: 0.67, alpha: 1)
        
        createBuildings()
        createPlayers()
        physicsWorld.contactDelegate = self
        
        
    }
    
    func createBuildings() {
        var currentX: CGFloat = -15

        while currentX < 2556 {
            let size = CGSize(width: Int.random(in: 2...4) * 40, height: Int.random(in: 300...600))
            currentX += size.width + 2

            let building = BuildingNode(color: UIColor.red, size: size)
            building.position = CGPoint(x: currentX - (size.width / 2), y: size.height / 2)
            building.setup()
            addChild(building)

            buildings.append(building)
        }
    }
    
    func launch(angle: Int, velocity: Int) {
        let speed = Double(velocity) / 6
        let radians = deg2rad(degrees: angle)
        
        if banana != nil {
            banana.removeFromParent()
            banana = nil
        }
        
        banana = SKSpriteNode(imageNamed: "banana")
        banana.name = "banana"
        banana.physicsBody = SKPhysicsBody(circleOfRadius: banana.size.width / 2)
        banana.physicsBody?.categoryBitMask = CollisionTypes.banana.rawValue
        banana.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue | CollisionTypes.building.rawValue
        banana.physicsBody?.collisionBitMask = CollisionTypes.player.rawValue | CollisionTypes.building.rawValue
        banana.physicsBody?.usesPreciseCollisionDetection = true
        
        addChild(banana)
        
        if currentPlayer == 1{
            banana.position = CGPoint(x: player1.position.x - 30, y: player1.position.y + 40)
            banana.physicsBody?.angularVelocity = -20
            
            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player1Throw"))
            let pause = SKAction.wait(forDuration: 0.15)
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let seq = SKAction.sequence([raiseArm,pause,lowerArm])
            player1.run(seq)
            
            let impulse = CGVector(dx: cos(radians) * speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse)
        }else{
            banana.position = CGPoint(x: player2.position.x + 30, y: player2.position.y + 40)
            banana.physicsBody?.angularVelocity = -20
            
            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player2Throw"))
            let pause = SKAction.wait(forDuration: 0.15)
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let seq = SKAction.sequence([raiseArm,pause,lowerArm])
            player2.run(seq)
            
            let impulse = CGVector(dx: cos(radians) * -speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse)
        }
        
        
    }
    
    func createPlayers(){
        player1 = SKSpriteNode(imageNamed: "player")
        player1.name = "player1"
        player1.physicsBody = SKPhysicsBody(circleOfRadius: player1.size.width / 2)
        player1.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player1.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
        player1.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue
        player1.physicsBody?.isDynamic = false
        
        let player1Building = buildings[2]
        player1.position = CGPoint(x: player1Building.position.x, y: player1Building.position.y + ((player1Building.size.height + player1.size.height) / 2))
        addChild(player1)
        
        player2 = SKSpriteNode(imageNamed: "player")
        player2.name = "player2"
        player2.physicsBody = SKPhysicsBody(circleOfRadius: player2.size.width / 2)
        player2.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player2.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue
        player2.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
        player2.physicsBody?.isDynamic = false

        let player2Building = buildings[buildings.count - 3]
        player2.position = CGPoint(x: player2Building.position.x, y: player2Building.position.y + ((player2Building.size.height + player2.size.height) / 2))
        addChild(player2)
        
    }
    
    func deg2rad(degrees: Int) -> Double{
        return Double(degrees) * .pi / 180
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody: SKPhysicsBody
        let secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        guard let firstNode = firstBody.node else {return}
        guard let secondNode = secondBody.node else {return}
        
        if firstNode.name == "banana" && secondNode.name == "building" {
            bananaHit(building: secondNode, atPoint: contact.contactPoint)
        }
        
        if firstNode.name == "banana" && secondNode.name == "player1"{
            ViewController?.playerTwoScoreInt += 1
            gameOver = ViewController?.playerTwoScoreInt == 3 ? true : false
            destroy(player: player1)
            
            
        }
        
        if firstNode.name == "banana" && secondNode.name == "player2"{
            ViewController?.playerOneScoreInt += 1
            gameOver = ViewController?.playerOneScoreInt == 3 ? true : false
            destroy(player: player2)
        }
        
    }
    
    func  bananaHit(building: SKNode, atPoint contactPoint: CGPoint){
        guard let building = building as? BuildingNode else {return}
        let buildingLocation = convert(contactPoint, to: building)
        building.hit(at: buildingLocation)
        
        if let explosion = SKEmitterNode(fileNamed: "hitBuilding") {
            explosion.position = contactPoint
            addChild(explosion)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                explosion.removeFromParent()
            }
            
        }
        
        banana.name = ""
        banana.removeFromParent()
        banana = nil
        changePlayer()
    }
    
    func destroy(player: SKSpriteNode){
        if let explosion = SKEmitterNode(fileNamed: "hitPlayer") {
            explosion.position = player.position
            addChild(explosion)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                explosion.removeFromParent()
            }
            
            
        }
        
        player.removeFromParent()
        banana.removeFromParent()
        
        if gameOver{
            changePlayer()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                self.ViewController?.playerTwoScoreInt = 0
                self.ViewController?.playerOneScoreInt = 0
                self.restartGame()
            }
            
            return
        }
        restartGame()

    }
    
    func restartGame(){
        gameOver = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3){
            
            let newGame = GameScene(size: self.size)
            newGame.ViewController = self.ViewController
            self.ViewController?.currentGame = newGame
            self.ViewController?.launchButton.titleLabel?.text = "Launch!"

            
            self.changePlayer()
            newGame.currentPlayer = self.currentPlayer
            
            let transition = SKTransition.doorsCloseHorizontal(withDuration: 2)
            self.view?.presentScene(newGame, transition: transition)
        }
    }
    
    func changePlayer(){
        
        if currentPlayer == 1 {
            currentPlayer = 2
        }else{
            currentPlayer = 1
        }
        
        ViewController?.activatePlayer(player: currentPlayer, gameOver: gameOver )
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard banana != nil else {return}
        
        if abs(banana.position.y) > 2600 {
            banana.removeFromParent()
            banana = nil
            changePlayer()
        }
    }
    
}
