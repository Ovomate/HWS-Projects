//
//  GameScene.swift
//  Project14 - Whack a Penguin
//
//  Created by Stefan Storm on 2024/09/26.
//

import SpriteKit


class GameScene: SKScene {
    
    var slots = [WhackSlot]()
    var gameScore: SKLabelNode!
    var score = 0 {
        didSet{
            gameScore.text = "Score: \(score)"
        }
    }
    var popupTime = 0.85
    var numRound = 0
    

    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "whackBackground")
        background.zPosition = -1
        background.size.width = self.size.width
        background.size.height = self.size.height
        background.anchorPoint = CGPoint(x: 0, y: 0)
        background.blendMode = .replace
        addChild(background)
        
        gameScore = SKLabelNode(fontNamed: "Marker Felt")
        gameScore.position = CGPoint(x: 200, y: 100)
        gameScore.text = "Score: 0"
        gameScore.horizontalAlignmentMode = .center
        gameScore.fontSize = 100
        gameScore.zPosition = 2
        addChild(gameScore)
        
        // 2556 - 1179 = 1278 - 590
        // 1024 - 768 = 512 - 384
        for i in 0 ..< 5 { createSlot(at: CGPoint(x: 200 + (i * 340), y: 600)) }
        for i in 0 ..< 4 { createSlot(at: CGPoint(x: 360 + (i * 340), y: 480)) }
        for i in 0 ..< 5 { createSlot(at: CGPoint(x: 200 + (i * 340), y: 360)) }
        for i in 0 ..< 4 { createSlot(at: CGPoint(x: 360 + (i * 340), y: 240)) }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.createEnemy()
        }
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let position = touch.location(in: self)
        let tappedNodes = nodes(at: position)
  
        for node in tappedNodes {
            guard let whackSlot = node.parent?.parent as? WhackSlot else {continue}
            
            if !whackSlot.isVisible {continue}
            if whackSlot.isHit {continue}
            whackSlot.hit()
            
            if node.name == "charFriend"{
                score -= 5
                run(SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion: false))
                
            }else if node.name == "charEnemy"{

                whackSlot.charNode.xScale = 0.85
                whackSlot.charNode.yScale = 0.85
                

                score += 1
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion:false))
            }
        }
    }
    
    
    func createSlot(at position: CGPoint){
        let slot = WhackSlot()
        slot.configure(at: position)
        addChild(slot)
        slots.append(slot)
    }
    
    
    func createEnemy() {
        numRound += 1
        
        if numRound >= 30{
            for slot in slots {
                slot.hide()
            }
            
            let gameOver = SKSpriteNode(imageNamed: "gameOver")
            gameOver.position = CGPoint(x: 1278, y: 590)
            gameOver.zPosition = 1
            addChild(gameOver)
            run(SKAction.playSoundFileNamed("GameOver3.m4a", waitForCompletion: false))
            gameScore.run(SKAction.move(to: CGPoint(x: self.frame.midX, y: self.frame.midY - 200), duration: 0.5))
            return
        }

        popupTime *= 0.991

        slots.shuffle()
        slots[0].show(hideTime: popupTime)
        
        //Add mud emitter
        showEmitter(position: slots[0].position)
        if Int.random(in: 0...12) > 4 { slots[1].show(hideTime: popupTime)
            showEmitter(position: slots[1].position)}
        if Int.random(in: 0...12) > 8 {  slots[2].show(hideTime: popupTime)
            showEmitter(position: slots[2].position)}
        if Int.random(in: 0...12) > 10 { slots[3].show(hideTime: popupTime)
            showEmitter(position: slots[3].position)}
        if Int.random(in: 0...12) > 11 { slots[4].show(hideTime: popupTime)
            showEmitter(position: slots[4].position)}

        let minDelay = popupTime / 2.0
        let maxDelay = popupTime * 2
        let delay = Double.random(in: minDelay...maxDelay)

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.createEnemy()
        }
    }
    
    func showEmitter(position: CGPoint){
        if let mud = SKEmitterNode(fileNamed: "MudEmitter"){
            mud.position = position
            mud.zPosition = 2
            addChild(mud)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                mud.removeFromParent()
            }
        }
        
    }

    
}
