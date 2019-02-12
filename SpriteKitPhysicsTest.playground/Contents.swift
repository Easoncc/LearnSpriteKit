import UIKit
import SpriteKit
import PlaygroundSupport

let sceneView = SKView(frame: CGRect(x: 0, y: 0, width: 480,
                                     height: 320))
let scene = SKScene(size: CGSize(width: 480, height: 320))
sceneView.showsFPS = true
sceneView.showsPhysics = true
scene.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
scene.physicsBody = SKPhysicsBody(edgeLoopFrom: scene.frame)
sceneView.presentScene(scene)
delay(seconds: 1.0) {
    scene.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
    scene.run(
        SKAction.repeat(
            SKAction.sequence([
                SKAction.run(spawnSand),
                SKAction.wait(forDuration: 0.1)
                ]),
            count: 100))
    delay(seconds: 12, completion: shake)
}
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = sceneView

let square = SKSpriteNode(imageNamed: "square")
square.name = "shape"
square.position = CGPoint(x: scene.size.width * 0.25,
                          y: scene.size.height * 0.50)
square.physicsBody = SKPhysicsBody(rectangleOf:
    square.frame.size)

let circle = SKSpriteNode(imageNamed: "circle")
circle.name = "shape"
circle.position = CGPoint(x: scene.size.width * 0.50,
                          y: scene.size.height * 0.50)
let triangle = SKSpriteNode(imageNamed: "triangle")
triangle.name = "shape"
triangle.position = CGPoint(x: scene.size.width * 0.75,
                            y: scene.size.height * 0.50)
let trianglePath = CGMutablePath()
trianglePath.move(to: CGPoint(x: -triangle.size.width/2,
                              y: -triangle.size.height/2))
trianglePath.addLine(to: CGPoint(x: triangle.size.width/2,
                                 y: -triangle.size.height/2))
trianglePath.addLine(to: CGPoint(x: 0, y: triangle.size.height/2))
trianglePath.addLine(to: CGPoint(x: -triangle.size.width/2,
                                 y: -triangle.size.height/2))
triangle.physicsBody = SKPhysicsBody(polygonFrom: trianglePath)
scene.addChild(square)
scene.addChild(circle)
scene.addChild(triangle)

circle.physicsBody = SKPhysicsBody(circleOfRadius:
    circle.size.width/2)

let l = SKSpriteNode(imageNamed: "L")
l.name = "shape"
l.position = CGPoint(x: scene.size.width * 0.5,
                     y: scene.size.height * 0.75)
l.physicsBody = SKPhysicsBody(texture: l.texture!, size: l.size)
scene.addChild(l)


func spawnSand() {
    let sand = SKSpriteNode(imageNamed: "sand")
    sand.position = CGPoint(
        x: random(min: 0.0, max: scene.size.width),
        y: scene.size.height - sand.size.height)
    sand.physicsBody = SKPhysicsBody(circleOfRadius:
        sand.size.width/2)
    sand.name = "sand"
    sand.physicsBody!.restitution = 0.6
    sand.physicsBody!.density = 20.0
    sand.physicsBody!.friction = 0.5
    sand.physicsBody!.allowsRotation = true
    scene.addChild(sand)
}

func shake() {
    scene.enumerateChildNodes(withName: "sand") { node, _ in
        node.physicsBody!.applyImpulse(
            CGVector(dx: 0, dy: random(min: 20, max: 40))
        )
    }
    
    scene.enumerateChildNodes(withName: "shape") { node, _ in
        node.physicsBody!.applyImpulse(
            CGVector(dx: random(min:20, max:60),
                     dy: random(min:20, max:60))
        )
    }
}

var blowingRight = true
var windForce = CGVector(dx: 50, dy: 0)

extension SKScene {
    //1
    @objc func applyWindForce() {
        enumerateChildNodes(withName: "sand") { node, _ in
            node.physicsBody!.applyForce(windForce)
        }
        enumerateChildNodes(withName: "shape") { node, _ in
            node.physicsBody!.applyForce(windForce)
        }
    }
    
    //2
    @objc func switchWindDirection() {
        blowingRight = !blowingRight
        windForce = CGVector(dx: blowingRight ? 50 : -50, dy: 0)
    }
}

//3
Timer.scheduledTimer(timeInterval: 0.05, target: scene,
                     selector: #selector(SKScene.applyWindForce),
                     userInfo: nil, repeats: true)
Timer.scheduledTimer(timeInterval: 3.0, target: scene,
                     selector: #selector(SKScene.switchWindDirection),
                     userInfo: nil, repeats: true)
