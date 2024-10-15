//
//  GameScene.swift
//  Project23 - Ninja
//
//  Created by Stefan Storm on 2024/10/14.
//

import SpriteKit
import AVFoundation

enum ForceBomb {
    case never
    case always
    case random
}

enum sequenceType : CaseIterable{
    case oneNoBomb
    case one
    case twoWithOneBomb
    case two
    case three
    case four
    case chain
    case fastChain
}


class GameScene: SKScene {
    
    let background : SKSpriteNode = {
        let node = SKSpriteNode(imageNamed: "sliceBackground")
        node.zPosition = -1
        node.anchorPoint = CGPoint(x: 0, y: 0)
        node.blendMode = .replace
        return node
        
    }()
    
    var gameScore : SKLabelNode = {
       let node = SKLabelNode(fontNamed: "Marker Felt")
        node.position = CGPoint(x: 100, y: 100)
        node.text = "Score: 0"
        node.fontSize = 80
        node.zPosition = 2
        node.horizontalAlignmentMode = .left
        return node
    }()
    var score : Int = 0 {
        didSet{
            gameScore.text = "Score: \(score)"
        }
    }
    
    var gameOverLabel : SKLabelNode = {
       let node = SKLabelNode(fontNamed: "Marker Felt")
        node.position = CGPoint(x: 1260, y: 590)
        node.text = """
        GAME OVER
        Tap to restart!
        """
        node.fontSize = 100
        node.zPosition = 2
        node.numberOfLines = 2
        node.horizontalAlignmentMode = .center
        node.alpha = 0
        node.name = "gameOverLabel"
        return node
    }()
    
    var livesImages = [SKSpriteNode]()
    var lives = 3
    
    var activeSliceBG : SKShapeNode!
    var activeSliceFG : SKShapeNode!
    var activeSlicePoints = [CGPoint]()
    
    var isSwooshSoundActive = false
    
    var activeEnemies = [SKSpriteNode]()
    
    var bombSoundEffect: AVAudioPlayer!
    
    var popupTime = 0.9
    var sequence = [sequenceType]()
    var sequencePosition = 0
    var chainDelay = 3.0
    var nextSequenceQueued = true
    
    var isGameEnded = false
    
    let outerXVelocity = Int.random(in: 8...15)
    let innerXVelocity = Int.random(in: 3...5)
    
    
    
    override func didMove(to view: SKView) {
        setupScene()
        setupSequence()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2){
            [weak self] in self?.tossEnemies()
        }
        
    }
    
    func setupSequence(){
        sequence.removeAll()
        sequencePosition = 0
        sequence = [.oneNoBomb, .oneNoBomb, .twoWithOneBomb, .twoWithOneBomb, .three, .one, .chain]
        
        for _ in 1...1000{
            if let nextSequence = sequenceType.allCases.randomElement() {
                sequence.append(nextSequence)
            }
        }
    }
    
    
    func setupScene(){
        background.size.width = self.size.width
        background.size.height = self.size.height
        
        addChild(background)
        addChild(gameOverLabel)
        addChild(gameScore)
        score = 0
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        physicsWorld.speed = 0.85
        
        createLives()
        createSlices()
        
    }
    
    
    func createLives(){
        for i in 1...3{
            let node = SKSpriteNode(imageNamed: "sliceLife")
            node.position = CGPoint(x: CGFloat(2000 + (i * 100)), y: 1000)
            node.size = CGSize(width: node.size.width * 1.5, height: node.size.height * 1.5)
            addChild(node)
            livesImages.append(node)
        }
    }
    
    
    func createSlices(){
        activeSliceBG = SKShapeNode()
        activeSliceBG.zPosition = 2
        
        activeSliceFG = SKShapeNode()
        activeSliceFG.zPosition = 3
        
        activeSliceBG.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1)
        activeSliceBG.lineWidth = 9
        
        activeSliceFG.strokeColor = .white
        activeSliceFG.lineWidth = 5
        
        addChild(activeSliceBG)
        addChild(activeSliceFG)
        
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard isGameEnded == false else {return}
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        redrawActiveSlice()
        
        if !isSwooshSoundActive{
           playSwooshSound()
        }
        
        let nodesAtPoint = nodes(at: location)
        
        for case let node as SKSpriteNode in nodesAtPoint{
            
            
            if node.name == "enemyFast"{
                if let emitter = SKEmitterNode(fileNamed: "sliceHitEnemyFast") {
                    emitter.position = node.position
                    addChild(emitter)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                        emitter.removeFromParent()
                    }
                }
                
                node.name = ""
                node.physicsBody?.isDynamic = false
                
                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut,fadeOut])
                
                let sequence = SKAction.sequence([group, .removeFromParent()])
                node.run(sequence)
                
                score += 5
                
                if let index = activeEnemies.firstIndex(of: node){
                    activeEnemies.remove(at: index)
                }
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
                
            }else if node.name == "enemy"{
                if let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy") {
                    emitter.position = node.position
                    addChild(emitter)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                        emitter.removeFromParent()
                    }
                }
                
                
                node.name = ""
                node.physicsBody?.isDynamic = false
                
                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut,fadeOut])
                
                let sequence = SKAction.sequence([group, .removeFromParent()])
                node.run(sequence)
                
                score += 1
                
                if let index = activeEnemies.firstIndex(of: node){
                    activeEnemies.remove(at: index)
                }
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
                
            }else if node.name == "bomb"{
                guard let bombContainer = node.parent as? SKSpriteNode else {continue}
                
                if let emitter = SKEmitterNode(fileNamed: "sliceHitBomb") {
                    emitter.position = bombContainer.position
                    addChild(emitter)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                        emitter.removeFromParent()
                    }
                }
                
                node.name = ""
                bombContainer.physicsBody?.isDynamic = false
                
                
                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut,fadeOut])
                
                let sequence = SKAction.sequence([group, .removeFromParent()])
                bombContainer.run(sequence)
                
                if let index = activeEnemies.firstIndex(of: bombContainer){
                    activeEnemies.remove(at: index)
                }
                
                run(SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: false))
                endGame(triggeredByBomb: true)
                
            }
        }
    }
    
    
    func endGame(triggeredByBomb: Bool){
        guard isGameEnded == false else {return}
        
        let alpha = SKAction.fadeAlpha(to: 1, duration: 0.5)
        gameOverLabel.run(alpha)
        
        isGameEnded = true

        bombSoundEffect?.stop()
        bombSoundEffect = nil

        if triggeredByBomb {
            livesImages[0].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[1].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[2].texture = SKTexture(imageNamed: "sliceLifeGone")
        }
    }
                    
    
    func playSwooshSound(){
        isSwooshSoundActive = true
        
        let randomNumber = Int.random(in: 1...3)
        let swooshName = "swoosh\(randomNumber).caf"
        
        let swooshSound = SKAction.playSoundFileNamed(swooshName, waitForCompletion: true)
        
        run(swooshSound) { [weak self] in
            self?.isSwooshSoundActive = false
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeSliceBG.run(SKAction.fadeOut(withDuration: 0.25))
        activeSliceFG.run(SKAction.fadeOut(withDuration: 0.25))
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        
        //MARK: Restart game
        let nodesAtPoint = nodes(at: location)
        for node in nodesAtPoint{
            if node.name == "gameOverLabel"{
                let alpha = SKAction.fadeAlpha(to: 0, duration: 0.5)
                node.run(alpha)
                
                isGameEnded = false
                score = 0
                lives = 3
                popupTime = 0.9
                chainDelay = 3.0
                physicsWorld.speed = 1
                
                for i in 0...2{
                    livesImages[i].texture = SKTexture(imageNamed: "sliceLife")
                }
           
                setupSequence()

                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                    [weak self] in self?.tossEnemies()
                }
            }
        }
        
        activeSlicePoints.removeAll(keepingCapacity: true)
        activeSlicePoints.append(location)
        
        redrawActiveSlice()
        
        activeSliceBG.removeAllActions()
        activeSliceFG.removeAllActions()
        
        activeSliceBG.alpha = 1
        activeSliceFG.alpha = 1
    }
    
    
    func redrawActiveSlice(){
        if activeSlicePoints.count < 2 {
            activeSliceBG.path = nil
            activeSliceFG.path = nil
            return
        }

        if activeSlicePoints.count > 12 {
            activeSlicePoints.removeFirst(activeSlicePoints.count - 12)
        }
        
        let path = UIBezierPath()
        path.move(to: activeSlicePoints[0])
        
        for i in 1..<activeSlicePoints.count {
            path.addLine(to: activeSlicePoints[i])
        }
        
        activeSliceBG.path = path.cgPath
        activeSliceFG.path = path.cgPath
        
    }

    
    func createEnemy(forceBomb: ForceBomb = .random) {
        guard isGameEnded == false else {return}
        var enemy: SKSpriteNode

        var enemyType = Int.random(in: 0...2)

        if forceBomb == .never {
            enemyType = 1
        } else if forceBomb == .always {
            enemyType = 0
        }

        if enemyType == 0 {
            
            enemy = SKSpriteNode()
            enemy.zPosition = 1
            enemy.name = "bombContainer"

            let bombImage = SKSpriteNode(imageNamed: "sliceBomb")
            bombImage.name = "bomb"
            enemy.addChild(bombImage)

            if bombSoundEffect != nil {
                bombSoundEffect.stop()
                bombSoundEffect = nil
            }


            let path = Bundle.main.path(forResource: "sliceBombFuse.caf", ofType:nil)!
            let url = URL(fileURLWithPath: path)
            let sound = try! AVAudioPlayer(contentsOf: url)
            bombSoundEffect = sound
            sound.play()

            
            let emitter = SKEmitterNode(fileNamed: "sliceFuse")!
            emitter.position = CGPoint(x: 76, y: 64)
            enemy.addChild(emitter)
            
        } else if enemyType == 1{
            
            enemy = SKSpriteNode(imageNamed: "penguin")
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            enemy.name = "enemy"
            
        }else{
            //MARK: Added fast enemy
            enemy = SKSpriteNode(imageNamed: "penguinFast")
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            enemy.name = "enemyFast"
            
        }

        let randomPosition = CGPoint(x: Int.random(in: 100...2000), y: -128)
        enemy.position = randomPosition

        let randomAngularVelocity = CGFloat.random(in: -6...6) / 2.0
        var randomXVelocity = 0

        if randomPosition.x < 600 {
            randomXVelocity = outerXVelocity
        } else if randomPosition.x < 1200 {
            randomXVelocity = innerXVelocity
        } else if randomPosition.x < 1800 {
            randomXVelocity = -innerXVelocity
        } else {
            randomXVelocity = -outerXVelocity
        }

        let randomYVelocity = Int.random(in: 24...32)

        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 64)
        enemy.physicsBody?.velocity = CGVector(dx: randomXVelocity * 40, dy: enemy.name == "enemyFast" ? randomYVelocity * 60 : randomYVelocity * 45 )
        enemy.physicsBody?.angularVelocity = randomAngularVelocity
        enemy.physicsBody?.collisionBitMask = 0

        addChild(enemy)
        activeEnemies.append(enemy)
    }

    
    func subtractLife() {
        lives -= 1

        run(SKAction.playSoundFileNamed("wrong.caf", waitForCompletion: false))

        var life: SKSpriteNode

        if lives == 2 {
            life = livesImages[0]
        } else if lives == 1 {
            life = livesImages[1]
        } else {
            life = livesImages[2]
            endGame(triggeredByBomb: false)
        }

        life.texture = SKTexture(imageNamed: "sliceLifeGone")

        life.xScale = 1.3
        life.yScale = 1.3
        life.run(SKAction.scale(to: 1, duration:0.1))
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        if activeEnemies.count > 0 {
            for node in activeEnemies {
                if node.position.y < -140 {
                    node.removeAllActions()
                    
                    if node.name == "enemy" || node.name == "enemyFast" {
                        node.name = ""
                        subtractLife()
                        
                        node.removeFromParent()
                        
                        if let index = activeEnemies.firstIndex(of: node) {
                            activeEnemies.remove(at: index)
                        }
                    } else if node.name == "bombContainer" {
                        node.name = ""
                        node.removeFromParent()
                        
                        if let index = activeEnemies.firstIndex(of: node) {
                            activeEnemies.remove(at: index)
                        }
                    }
                }
            }
        } else {
            if !nextSequenceQueued {
                DispatchQueue.main.asyncAfter(deadline: .now() + popupTime) { [unowned self] in
                    self.tossEnemies()
                }
                
                nextSequenceQueued = true
            }
        }
        
        var bombCount = 0
        
        for node in activeEnemies {
            if node.name == "bombContainer" {
                bombCount += 1
                break
            }
        }
        
        if bombCount == 0 {
            if bombSoundEffect != nil {
                bombSoundEffect.stop()
                bombSoundEffect = nil
            }
        }
    }

    
    func tossEnemies() {
        popupTime *= 0.991
        chainDelay *= 0.99
        physicsWorld.speed *= 1.02

        let sequenceType = sequence[sequencePosition]

        switch sequenceType {
        case .oneNoBomb:
            createEnemy(forceBomb: .never)

        case .one:
            createEnemy()

        case .twoWithOneBomb:
            createEnemy(forceBomb: .never)
            createEnemy(forceBomb: .always)

        case .two:
            createEnemy()
            createEnemy()

        case .three:
            createEnemy()
            createEnemy()
            createEnemy()

        case .four:
            createEnemy()
            createEnemy()
            createEnemy()
            createEnemy()

        case .chain:
            createEnemy()

            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 2)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 3)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 4)) { [weak self] in self?.createEnemy() }

        case .fastChain:
            createEnemy()

            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 2)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 3)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 4)) { [weak self] in self?.createEnemy() }
        }

        sequencePosition += 1
        nextSequenceQueued = false
    }
    
    
}

