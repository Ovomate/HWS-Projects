//
//  GameScene.swift
//  Project11 - Pachinko
//
//  Created by Stefan Storm on 2024/09/18.
//

import SpriteKit


class GameScene: SKScene, SKPhysicsContactDelegate{
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet{
            scoreLabel.text = "Score: \(score)"
            
        }
    }
    
    var editLabel: SKLabelNode!
    var editingMode: Bool = false {
        didSet{
            if editingMode{
                editLabel.text = "Done"
            }else{
                editLabel.text = "Edit"
            }
        }
    }
    
    var totalBallsLabel: SKLabelNode!
    var totalBalls = 5 {
        didSet{
            totalBallsLabel.text = "Balls left: \(totalBalls)"
            if totalBalls == 0{
                totalBallsLabel.text = "Game Over!"
            }
        }
    }
    

    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 566, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Copperplate")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "Copperplate")
        editLabel.text = "Edit"
        editLabel.horizontalAlignmentMode = .right
        editLabel.position = CGPoint(x: 100, y: 700)
        addChild(editLabel)
        
        totalBallsLabel = SKLabelNode(fontNamed: "Copperplate")
        totalBallsLabel.text = "Balls left: 5"
        totalBallsLabel.horizontalAlignmentMode = .right
        totalBallsLabel.position = CGPoint(x: 500, y: 700)
        addChild(totalBallsLabel)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        var countSlot = 141
        var toggle = true
        for _ in 1...4{
            toggle = toggle ? false : true
            makeSlot(at: CGPoint(x: countSlot, y: 0), isGood: toggle )
            countSlot += 283
        }

        var countBouncer = 0
        for _ in 1...5{
            makeBouncer(at: CGPoint(x: countBouncer, y: 0))
            countBouncer += 283
        }
        

        
    }
    
    
    func makeBouncer(at position: CGPoint){
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.frame.width / 2)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    
    func makeSlot(at position: CGPoint, isGood: Bool){
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        }else{
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        
        slotBase.position = position
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        slotGlow.position = position
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        
        
        let objects = nodes(at: location)
        
        if objects.contains(editLabel){
            editingMode.toggle()
            
        }else {
            
            if editingMode{
                let size = CGSize(width: Int.random(in: 16...128), height:  16)
                let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                box.position = location
                box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                box.physicsBody?.isDynamic = false
                box.zRotation = CGFloat.random(in: 1...3)
                //MARK: Challenge -- Box disappear
                box.name = "box"
                box.physicsBody?.contactTestBitMask = box.physicsBody!.collisionBitMask
                addChild(box)
                
                
            }else{
                
                //MARK: Challenge -- Force higher tap
                guard location.y > 500 else{ return}
                guard totalBalls > 0 else{return} //Add restart here
                //MARK: Challenge -- Random Ball Colors
                var ballColors = ["Cyan","Blue", "Red", "Green", "Grey", "Purple", "Yellow"].shuffled()
                let ball = SKSpriteNode(imageNamed: "ball\(ballColors.first!)")
                ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.frame.width / 2)
                ball.physicsBody?.restitution = 0.4
                ball.position = location
                ball.physicsBody?.contactTestBitMask = ball.physicsBody!.collisionBitMask
                ball.name = "ball"
                addChild(ball)
            }
        }
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else {return}
        guard let nodeB = contact.bodyB.node else {return}
        if nodeA.name == "ball"{
            collision(between: nodeA, object: nodeB)
        }else if nodeB.name == "ball"{
            collision(between: nodeB, object: nodeA)
        }

        
    }
    
    
    func collision(between ball: SKNode, object: SKNode){
        if object.name == "good"{
            destroy(ball: ball)
            score += 1
            totalBalls += 1
            
        }else if object.name == "bad"{
            destroy(ball: ball)
            score -= 1
            totalBalls -= 1
        }
        
        //MARK: Challenge -- Box disappear
        if object.name == "box"{
            destroy(ball: ball)
            destroy(box: object)
            totalBalls -= 1
        }
        
        
    }
    
    //MARK: Challenge -- Box disappear
    func destroy(box: SKNode){
        if let fire = SKEmitterNode(fileNamed: "FireParticles"){
            fire.position = box.position
            addChild(fire)
        }
        box.removeFromParent()
    }
    
    
    func destroy(ball: SKNode){
        if let fire = SKEmitterNode(fileNamed: "FireParticles"){
            fire.position = ball.position
            addChild(fire)
        }
        
        ball.removeFromParent()
    }
    

    
}
