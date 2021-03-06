//
//  ZombieScene.swift
//  mygame
//
//  Created by chenchao on 2019/1/14.
//  Copyright © 2019 chenchao. All rights reserved.
//

import UIKit
import SpriteKit

class ZombieScene: SKScene {

    let catMovePointsPerSec = UIScreen.main.bounds.size.width
    var lastTouchLocation: CGPoint?
    var zombie1: SKSpriteNode!
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    let zombieMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPoint.zero
    let playableRect: CGRect
    let zombieAnimation: SKAction!
    var catCollisionSound: SKAction = SKAction.playSoundFileNamed(
        "hitCat.wav", waitForCompletion: false)
    var enemyCollisionSound: SKAction = SKAction.playSoundFileNamed(
        "hitCatLady.wav", waitForCompletion: false)
    var lives = 5
    var trainCount = 0
    var gameOver = false
    let cameraMovePointsPerSec: CGFloat = 200.0
    var cameraNode: SKCameraNode!
    let shape = SKShapeNode()
    let livesLabel = SKLabelNode(fontNamed: "Glimstick")
    let catCountLabel = SKLabelNode(fontNamed: "Glimstick")
    
    var cameraRect : CGRect {
        let x = cameraNode.position.x - size.width/2
            + (size.width - playableRect.width)/2
        let y = cameraNode.position.y - size.height/2
            + (size.height - playableRect.height)/2
        return CGRect(
            x: x,
            y: y,
            width: playableRect.width,
            height: playableRect.height)
    }
    
    override init(size: CGSize) {
        
        let maxAspectRatio = UIScreen.main.bounds.size.width/UIScreen.main.bounds.size.height
        let playableHeight = size.width/maxAspectRatio
        let playableMargin = (size.height-playableHeight)/2.0
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        
        // 1
        var textures:[SKTexture] = []
        // 2
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        // 3
        textures.append(textures[2])
        textures.append(textures[1])
        // 4
        zombieAnimation = SKAction.animate(with: textures,
                                           timePerFrame: 0.1)
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        for i in 0...1 {
            let background = backgroundNode()
            background.anchorPoint = CGPoint.zero
            background.zPosition = -1
            background.position =
                CGPoint(x: CGFloat(i)*background.size.width, y: 0)
            background.name = "background"
            addChild(background)
        }
        
        zombie1 = SKSpriteNode(imageNamed: "zombie1")
        zombie1.position = CGPoint(x: 400, y: 500)
        zombie1.zPosition = 1
        addChild(zombie1)
        
        debugDrawPlayableArea()
        
        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run() { [weak self] in
                self?.spawnEnemy()
                }, SKAction.wait(forDuration: 2.0)])))
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run { [weak self] in
            self?.spawnCat()
            }, SKAction.wait(forDuration: 1)])))
        playBackgroundMusic(filename: "backgroundMusic.mp3")
        
        cameraNode = SKCameraNode()
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: size.width/2, y: size.height/2)
        
        livesLabel.text = "Lives: "+lives.description
        livesLabel.fontColor = SKColor.black
        livesLabel.fontSize = 100
        livesLabel.zPosition = 150
        livesLabel.horizontalAlignmentMode = .left
        livesLabel.verticalAlignmentMode = .bottom
        livesLabel.position = CGPoint(
            x: -playableRect.size.width/2 + CGFloat(20),
            y: -playableRect.size.height/2 + CGFloat(20))
        cameraNode.addChild(livesLabel)
        
        catCountLabel.text = "Cats: "+trainCount.description
        catCountLabel.fontColor = SKColor.black
        catCountLabel.fontSize = 100
        catCountLabel.zPosition = 150
        catCountLabel.horizontalAlignmentMode = .right
        catCountLabel.verticalAlignmentMode = .bottom
        catCountLabel.position = CGPoint(
            x: playableRect.size.width/2 - CGFloat(20),
            y: -playableRect.size.height/2 + CGFloat(20))
        cameraNode.addChild(catCountLabel)
    }
    
    func startZombieAnimation() {
        if zombie1.action(forKey: "animation") == nil {
            zombie1.run(SKAction.repeatForever(zombieAnimation), withKey: "animation")
        }
    }
    
    func stopZombieAnimation() {
        zombie1.removeAction(forKey: "animation")
    }
    
    func spawnCat() {
        // 1
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.name = "cat"
        cat.position = CGPoint(
            x: CGFloat.random(min: cameraRect.minX,
                              max: cameraRect.maxX),
            y: CGFloat.random(min: cameraRect.minY,
                              max: cameraRect.maxY))
        cat.zPosition = 50
        cat.setScale(0)
        addChild(cat)
        // 2
        let appear = SKAction.scale(to: 1.0, duration: 0.5)
//        let wait = SKAction.wait(forDuration: 10.0)
        
        cat.zRotation = CGFloat(-Double.pi / 16.0)
        let leftWiggle = SKAction.rotate(byAngle: CGFloat(Double.pi/8.0), duration: 0.5)
        let rightWiggle = leftWiggle.reversed()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
        let scaleUp = SKAction.scale(by: 1.2, duration: 0.25)
        let scaleDown = scaleUp.reversed()
        let fullScale = SKAction.sequence(
            [scaleUp, scaleDown, scaleUp, scaleDown])
        let group = SKAction.group([fullScale, fullWiggle])
        let groupWait = SKAction.repeat(group, count: 10)
        let disappear = SKAction.scale(to: 0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        let actions = [appear, groupWait, disappear, removeFromParent]
        cat.run(SKAction.sequence(actions))
    }
    
    func spawnEnemy() {
        
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.name = "enemy"
        enemy.position = CGPoint(
            x: cameraRect.maxX + enemy.size.width/2,
            y: CGFloat.random(
                min: playableRect.minY + enemy.size.height/2,
                max: playableRect.maxY - enemy.size.height/2))
        addChild(enemy)
        let actionMove =
            SKAction.moveTo(x:cameraRect.minX-enemy.size.width/2, duration: 2.0)
        enemy.run(actionMove)
    }
    
    func zombieHit(cat: SKSpriteNode) {
        
        trainCount += 1
        catCountLabel.text = "Cats: "+trainCount.description
        
        cat.removeAllActions()
        cat.name = "train"
        cat.setScale(1.0)
        cat.zPosition = 0
        
        let turnGreen = SKAction.colorize(with: SKColor.green, colorBlendFactor: 1.0, duration: 0.2)
        cat.run(turnGreen)
        
        run(catCollisionSound)
    }
    
    func zombieHit(enemy: SKSpriteNode) {
        
        loseCats()
        lives -= 1
        livesLabel.text = "Lives: "+lives.description
        enemy.removeFromParent()
        run(enemyCollisionSound)
        
        let actionIn = SKAction.fadeIn(withDuration: 0.2)
        let actionOut = SKAction.fadeOut(withDuration: 0.2)
        
        zombie1.run(SKAction.repeat(SKAction.sequence([actionIn, actionOut, SKAction.wait(forDuration: 0.2)]), count: 3)) { [weak self] in
            self?.zombie1.alpha = 1
            self?.zombie1.isHidden = false
        }
        
//        let blinkTimes = 10.0
//        let duration = 3.0
//        let blinkAction = SKAction.customAction(withDuration: duration) { node, elapsedTime in
//            let slice = duration / blinkTimes
//            let remainder = Double(elapsedTime).truncatingRemainder(
//                dividingBy: slice)
//            node.isHidden = remainder > slice / 2
//
//            print("slice:"+slice.description)
//        }
//
//        let setHidden = SKAction.run() { [weak self] in
//            self?.zombie1.isHidden = false
//        }
//        zombie1.run(SKAction.sequence([blinkAction, setHidden]))

    }
    
    func checkCollisions() {
        var hitCats: [SKSpriteNode] = []
        enumerateChildNodes(withName: "cat") { node, _ in
            let cat = node as! SKSpriteNode
            if cat.frame.intersects(self.zombie1.frame) {
                hitCats.append(cat)
            }
        }
        for cat in hitCats {
            zombieHit(cat: cat)
        }
        var hitEnemies: [SKSpriteNode] = []
        enumerateChildNodes(withName: "enemy") { node, _ in
            let enemy = node as! SKSpriteNode
            if node.frame.insetBy(dx: 20, dy: 20).intersects(
                self.zombie1.frame) {
                hitEnemies.append(enemy)
            }
        }
        for enemy in hitEnemies {
            zombieHit(enemy: enemy)
        }
    }
    
    func move(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = velocity * CGFloat(dt)
        sprite.position += amountToMove
    }
    
    func moveZombieToward(location: CGPoint) {
        
        let offset = location - zombie1.position
        let direction = offset.normalized()
        velocity = direction * zombieMovePointsPerSec
        startZombieAnimation()
    }
    
//    func rotate(sprite: SKSpriteNode, direction: CGPoint) {
//        sprite.zRotation = direction.angle
//    }
    
    func rotate(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
        let shortest = shortestAngleBetween(angle1: sprite.zRotation, angle2: velocity.angle)
        let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate
    }
    
    func sceneTouched(touchLocation:CGPoint) {
        lastTouchLocation = touchLocation
        moveZombieToward(location: touchLocation)
    }
    
    func boundsCheckZombie() {
        let bottomLeft = CGPoint(x: cameraRect.minX, y: cameraRect.minY)
        let topRight = CGPoint(x: cameraRect.maxX, y: cameraRect.maxY)
        if zombie1.position.x <= bottomLeft.x {
            zombie1.position.x = bottomLeft.x
            velocity.x = abs(velocity.x)
        }
        if zombie1.position.x >= topRight.x {
            zombie1.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if zombie1.position.y <= bottomLeft.y {
            zombie1.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if zombie1.position.y >= topRight.y {
            zombie1.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }
    
    func debugDrawPlayableArea() {
        let path = CGMutablePath()
        path.addRect(playableRect)
        shape.path = path
        shape.strokeColor = SKColor.red
        shape.lineWidth = 4.0
        
        addChild(shape)
    }
    
    func moveTrain() {
        
        var position = zombie1.position
        
        enumerateChildNodes(withName: "train") { (node, _) in
            
            if !node.hasActions() {
                let actionDuration: CGFloat = 0.3
                let offset = position - node.position
                let direction = offset.normalized()
                let amountToMovePerSec = direction*self.catMovePointsPerSec
                let amountToMove = amountToMovePerSec * actionDuration
                let moveAction = SKAction.moveBy(x: amountToMove.x, y: amountToMove.y, duration: TimeInterval(actionDuration))
                node.run(moveAction)
            }
            
            position = node.position
        }
        
        if trainCount >= 15 && !gameOver {
            gameOver = true
            print("You win!")
            backgroundMusicPlayer.stop()
            
            let gameOverScene = GameOverScene(size: self.size, won: true)
            gameOverScene.scaleMode = .aspectFill
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    func loseCats() {
        // 1
        var loseCount = 0
        enumerateChildNodes(withName: "train") { node, stop in
            // 2
            var randomSpot = node.position
            randomSpot.x += CGFloat.random(min: -100, max: 100)
            randomSpot.y += CGFloat.random(min: -100, max: 100)
            // 3
            node.name = ""
            node.run(
                SKAction.sequence([
                    SKAction.group([
                        SKAction.rotate(byAngle: π*4, duration: 1.0),
                        SKAction.move(to: randomSpot, duration: 1.0),
                        SKAction.scale(to: 0, duration: 1.0)
                        ]),
                    SKAction.removeFromParent()
                    ]))
            // 4
            loseCount += 1
            if self.trainCount > 0 {
                self.trainCount -= 1
                self.catCountLabel.text = "Cats: "+self.trainCount.description
            }
            
            if loseCount >= 2 {
                stop[0] = true
            }
        }
    }
    
    func backgroundNode() -> SKSpriteNode {
        // 1
        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = CGPoint.zero
        backgroundNode.name = "background"
        // 2
        let background1 = SKSpriteNode(imageNamed: "background1")
        background1.anchorPoint = CGPoint.zero
        background1.position = CGPoint(x: 0, y: 0)
        backgroundNode.addChild(background1)
        // 3
        let background2 = SKSpriteNode(imageNamed: "background2")
        background2.anchorPoint = CGPoint.zero
        background2.position =
            CGPoint(x: background1.size.width, y: 0)
        backgroundNode.addChild(background2)
        // 4
        backgroundNode.size = CGSize(
            width: background1.size.width + background2.size.width,
            height: background1.size.height)
        return backgroundNode
    }
    
    func moveCamera() {
        let backgroundVelocity =
            CGPoint(x: cameraMovePointsPerSec, y: 0)
        let amountToMove = backgroundVelocity * CGFloat(dt)
        cameraNode.position += amountToMove
        
        enumerateChildNodes(withName: "background") { node, _ in
            let background = node as! SKSpriteNode
            if background.position.x + background.size.width <
                self.cameraRect.origin.x {
                background.position = CGPoint(
                    x: background.position.x + background.size.width*2,
                    y: background.position.y)
            }
        }
        
        shape.position = CGPoint(x: cameraNode.position.x-shape.frame.size.width/2, y: shape.position.y)
    }
}

extension ZombieScene {
    
    override func update(_ currentTime: TimeInterval) {
        //        zombie1.position = CGPoint(x: zombie1.position.x+8, y: zombie1.position.y)
        
        if lives <= 0 && !gameOver {
            gameOver = true
            print("You lose!")
            
            backgroundMusicPlayer.stop()
            
            // 1
            let gameOverScene = GameOverScene(size: size, won: false)
            gameOverScene.scaleMode = .aspectFill
            // 2
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            // 3
            view?.presentScene(gameOverScene, transition: reveal)
        }
        
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        
//        if let lastTouchLocation = lastTouchLocation {
//            let diff = lastTouchLocation - zombie1.position
//            if diff.length() <= zombieMovePointsPerSec * CGFloat(dt) {
//                zombie1.position = lastTouchLocation
//                velocity = CGPoint.zero
//                stopZombieAnimation()
//            } else {
                move(sprite: zombie1, velocity: velocity)
                rotate(sprite: zombie1, direction: velocity, rotateRadiansPerSec: 4.0 * π)
//            }
//        }
        
        boundsCheckZombie()
        moveTrain()
        moveCamera()
//        camera?.position = zombie1.position
    }
    
    override func didEvaluateActions() {
        checkCollisions()
    }
}

extension ZombieScene {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touche = touches.first else {
            return
        }
        
        sceneTouched(touchLocation: touche.location(in: self))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation: touchLocation)
    }
}
