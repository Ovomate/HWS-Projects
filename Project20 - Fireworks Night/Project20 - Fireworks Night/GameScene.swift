//
//  GameScene.swift
//  Project20 - Fireworks Night
//
//  Created by Stefan Storm on 2024/10/09.
//

import SpriteKit


class GameScene: SKScene {
    
    var gameTimer: Timer?
    var fireWorks = [SKNode]()
    
    var leftEdge = -22
    var bottomEdge = -22
    var rightEdge = 2556 + 22
    var launchCount = 0
    
    let background : SKSpriteNode = {
       let node = SKSpriteNode(imageNamed: "background")
        node.zPosition = -1
        node.anchorPoint = CGPoint(x: 0, y: 0)
        node.blendMode = .replace
        return node
        
    }()
    
    var scoreLabel : SKLabelNode = {
       let node = SKLabelNode(fontNamed: "Marker Felt")
        node.position = CGPoint(x: 200, y: 100)
        node.text = "Score: 0"
        node.fontSize = 50
        node.zPosition = 2
        return node
    }()
    
    var score = 0 {
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    

    
    override func didMove(to view: SKView) {
        setupScene()
        
        
    }
    
    func setupScene(){
        background.size.width = self.size.width
        background.size.height = self.size.height
        
        addChild(background)
        addChild(scoreLabel)
        startTimer()

    }
    
    func startTimer(){
        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
    }
    
    
    @objc func launchFireworks(){
        launchCount += 1
        
        if launchCount == 6 {
            gameTimer?.invalidate()
            let moveUp = SKAction.move(to: CGPoint(x: 1278, y: 590), duration: 1)
            let moveDown = SKAction.move(to: CGPoint(x: 200, y: 100), duration: 1)
            scoreLabel.run(moveUp)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5){ [weak self] in
                self?.scoreLabel.run(moveDown)
                self?.launchCount = 0
                self?.score = 0
                self?.startTimer()
            }
            
        }else{
            
            let movementAmount: CGFloat = 1800
            
            switch Int.random(in: 1...3){
            case 1 :
                //Straight up
                createFirework(xMovement: 0, x: 1278, y: bottomEdge)
                createFirework(xMovement: 0, x: 1278 + 300, y: bottomEdge)
                createFirework(xMovement: 0, x: 1278 + 150, y: bottomEdge)
                createFirework(xMovement: 0, x: 1278 - 150, y: bottomEdge)
                createFirework(xMovement: 0, x: 1278 - 300, y: bottomEdge)
            case 2 :
                //Fan
                createFirework(xMovement: 0, x: 1278, y: bottomEdge)
                createFirework(xMovement: 300, x: 1278 + 300, y: bottomEdge)
                createFirework(xMovement: 150, x: 1278 + 150, y: bottomEdge)
                createFirework(xMovement: -150, x: 1278 - 150, y: bottomEdge)
                createFirework(xMovement: -300, x: 1278 - 300, y: bottomEdge)
            case 3 :
                //Left to right
                createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 600)
                createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 450)
                createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 300)
                createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 150)
                createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge)
            default :
                break
                
            }
        }
    }
    
    
    func createFirework(xMovement: CGFloat, x: Int, y: Int){
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)
        
        let fireWork = SKSpriteNode(imageNamed: "rocket")
        fireWork.colorBlendFactor = 1
        fireWork.name = "firework"
        node.addChild(fireWork)
        
        switch Int.random(in: 1...3){
        case 1:
            fireWork.color = .yellow
        case 2:
            fireWork.color = .green
        default:
            fireWork.color = .red
        }
        
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: xMovement, y: 1500))
        
        let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
        node.run(move)
        
        if let fuseEmitter = SKEmitterNode(fileNamed: "fuse"){
            fuseEmitter.position = CGPoint(x: 0, y: -22)
            node.addChild(fuseEmitter)
        }
        
        fireWorks.append(node)
        addChild(node)
        
    }
    
    
    func checkTouches(_ touches: Set<UITouch>){
        guard let touch = touches.first else { return }

        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)

        for case let node as SKSpriteNode in nodesAtPoint {
            guard node.name == "firework" else { continue }
            
            for parent in fireWorks {
                guard let firework = parent.children.first as? SKSpriteNode else { continue }

                if firework.name == "selected" && firework.color != node.color {
                    firework.name = "firework"
                    firework.colorBlendFactor = 1
                }
            }
            node.name = "selected"
            node.colorBlendFactor = 0
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        checkTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        checkTouches(touches)
    }
   
 
    override func update(_ currentTime: TimeInterval) {
        for (index, firework) in fireWorks.enumerated().reversed(){
            if firework.position.y > 1200{
                fireWorks.remove(at: index)
                firework.removeFromParent()
            }
        }
    }
    
    
    func explode(firework: SKNode) {
        if let emitter = SKEmitterNode(fileNamed: "explode") {
            emitter.position = firework.position
            let wait = SKAction.wait(forDuration: 1)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([wait, remove])
            emitter.run(sequence)
            addChild(emitter)
            
            
        }

        firework.removeFromParent()
    }
    
    
    func explodeFireworks() {
        var numExploded = 0

        for (index, fireworkContainer) in fireWorks.enumerated().reversed() {
            guard let firework = fireworkContainer.children.first as? SKSpriteNode else { continue }

            if firework.name == "selected" {
                explode(firework: fireworkContainer)
                fireWorks.remove(at: index)
                numExploded += 1
            }
        }
        
        switch numExploded {
        case 0:
            break
        case 1:
            score += 200
        case 2:
            score += 500
        case 3:
            score += 1500
        case 4:
            score += 2500
        default:
            score += 4000
        }
        
        
        
    }
    
    
    
    
    
    
}
