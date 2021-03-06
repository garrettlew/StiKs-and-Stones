import Foundation

enum GameState {
    case Playing, GameOver
}

class MainScene: CCNode {
    
    weak var stik: CCSprite!
    
    weak var squareblock: CCSprite!
    
    weak var tapRight: CCSprite!
    
    weak var tapLeft: CCSprite!
    
    weak var restartButton: CCButton!
    
    weak var gamePhysicsNode: CCPhysicsNode!
    
    weak var scoreLabel: CCLabelTTF!
    var score : Float = 0
    
    var pivotJoint: CCPhysicsJoint?
    
    var gameState: GameState = .Playing
    
    var stones : [CCNode] = []
    
    let firstStonePosition : CGFloat = 100
    
    func didLoadFromCCB() {
        
        gamePhysicsNode.debugDraw = true
        
        userInteractionEnabled = true
        
        let launchDirection = CGPoint(x: 1, y: 0)
        let force = ccpMult(launchDirection, 49999)
        
        stik.physicsBody.applyForce(force)
        
        for i in 0...2 {
            spawnNewStone()
        }
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        
        let launchDirection = CGPoint(x: 1, y: 0)
        
        let touchLocation = touch.locationInWorld()
        
        var xTouch = touch.locationInWorld().x
        var yTouch = touch.locationInWorld().y
        
        var screenHalf = CCDirector.sharedDirector().viewSize().width / 2
        var xForce = pow(yTouch / 3, 2)     //later do something with trig and/or have an algorithm
    
        // tap sides
        if xTouch < screenHalf {
            stik.physicsBody.applyImpulse(ccpMult(launchDirection, xForce))  //left side
            
            tapLeft.position = touchLocation
            tapLeft.visible = true
            tapLeft.runAction(CCActionFadeOut(duration: 0.3))
        } else {
            stik.physicsBody.applyImpulse(ccpMult(launchDirection, -(xForce)))  //right side
            
            tapRight.position = touchLocation
            tapRight.runAction(CCActionFadeOut(duration: 0.3))
        }
        
        if gameState == .GameOver { return }
    
    }
    
    func spawnNewStone() {
        
        // create and add a new obstacle
        var rand = CGFloat (CCRANDOM_0_1())
        let stone = CCBReader.load("Stones")
        let screenHeight = CCDirector.sharedDirector().viewSize().height
        let screenWidth = CCDirector.sharedDirector().viewSize().width
        stone.position = ccp(screenWidth * rand, CGFloat(screenHeight + stone.contentSize.height))
        gamePhysicsNode.addChild(stone)
        stones.append(stone)

    }
    
    override func update(delta: CCTime) {
        
        if gameState != .GameOver {
            
            //scoring
            score += Float(delta)
            scoreLabel.string = String(Int(score))

            for stone in stones.reverse() {
                let stoneWorldPosition = gamePhysicsNode.convertToWorldSpace(stone.position)
                let stoneScreenPosition = convertToNodeSpace(stoneWorldPosition)
                
                // obstacle moved past left side of screen?
                if stoneScreenPosition.y < (-stone.contentSize.height) {
                    stone.removeFromParent()
                    stones.removeAtIndex(find(stones, stone)!)
                    
                    // for each removed obstacle, add a new one
                    spawnNewStone()
                }
            }
        }
        
        let screenBottom = CCDirector.sharedDirector().viewSize().height / 5
        
        var yStik = stik.position.y
        
        // game over
        if yStik < screenBottom {
            let joint = stik.physicsBody.joints
            
            joint.first?.invalidate()
            
            triggerGameOver()
        }
        
        if gameState != .Playing { return }
    }
    
    func triggerGameOver() {
        
        restartButton.visible = true
        
        return gameState = .GameOver
    }
    
    func restart() {
        
        var mainScene = CCBReader.load("MainScene") as! MainScene
        //mainScene.ready()
        
        var scene = CCScene()
        scene.addChild(mainScene)
        
        var transition = CCTransition(fadeWithDuration: 0.3)
        
        CCDirector.sharedDirector().presentScene(scene, withTransition: transition)
    }

}
