//
//  GameScene.swift
//  SceneKit1
//
//  Created by iSal on 14/05/20.
//  Copyright © 2020 iSal. All rights reserved.
//

import SpriteKit
import GameplayKit

enum PhysicsCategory:UInt32 {
    case Enemy  = 1
    case Bullet = 2
    case Player = 3
}

class GameScene: SKScene {
    var spaceShip:SKSpriteNode!
    var enemy: SKSpriteNode!
    var bullet:SKSpriteNode!
    
    var enemySpawnTimer: Timer!
    var bulletSpawnTimer: Timer!
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        self.backgroundColor = .black
        createSpaceShip()
        
        enemySpawnTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(spawnFallingObject), userInfo: nil, repeats: true)
        
        bulletSpawnTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(createBullet), userInfo: nil, repeats: true)
    }
    
    func createSpaceShip(){
        spaceShip = SKSpriteNode(color: .blue, size: CGSize(width: 50, height: 50))
        spaceShip.name = "SpaceShip"
        spaceShip.position = CGPoint(x: frame.midX, y: frame.midY - 280)
        spaceShip.physicsBody   = SKPhysicsBody(rectangleOf: spaceShip.size)
        spaceShip.physicsBody?.categoryBitMask = PhysicsCategory.Player.rawValue
        spaceShip.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy.rawValue
        spaceShip.physicsBody?.affectedByGravity = false
        spaceShip.physicsBody?.isDynamic = false
        addChild(spaceShip)
    }
    
    @objc func spawnFallingObject(){
        let randXPosition   = Int.random(in: Int(frame.minX)...Int(frame.maxX))
        enemy               = SKSpriteNode(color: .red, size: CGSize(width: 50, height: 50))
        enemy.name          = "Enemy"
        enemy.position      = CGPoint(x: randXPosition, y: Int(frame.maxY))
        enemy.physicsBody   = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.categoryBitMask = PhysicsCategory.Enemy.rawValue
        enemy.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet.rawValue
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.isDynamic = true
        addChild(enemy)
        
        let moveAction      = SKAction.move(to: CGPoint(x: randXPosition, y: Int(frame.minY)), duration: 1.5)
        let removeAction    = SKAction.removeFromParent()
        let sequence        = SKAction.sequence([moveAction,removeAction])
        enemy.run(sequence)
    }
    
    @objc func createBullet(){
        bullet              = SKSpriteNode(color: .yellow, size: CGSize(width: 10, height: 10))
        bullet.name         = "Bullet"
        bullet.zPosition    = -1
        bullet.position     = CGPoint(x: spaceShip.position.x, y: spaceShip.position.y)
        bullet.physicsBody   = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.categoryBitMask = PhysicsCategory.Bullet.rawValue
        bullet.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy.rawValue
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.isDynamic = false
        addChild(bullet)
        
        let moveAction      = SKAction.move(to: CGPoint(x: bullet.position.x, y: size.height + 100), duration: 0.8)
        let removeAction    = SKAction.removeFromParent()
        let sequence        = SKAction.sequence([moveAction,removeAction])
        bullet.run(sequence)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { (touch) in
            let location = touch.location(in: self)
            spaceShip.position.x = location.x
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { (touch) in
            let location = touch.location(in: self)
            spaceShip.position.x = location.x
        }
    }
}


extension GameScene:SKPhysicsContactDelegate{
    
    func didBegin(_ contact: SKPhysicsContact) {
        let (nodeA, nodeB) = (contact.bodyA, contact.bodyB)
        if  (nodeA.categoryBitMask == PhysicsCategory.Enemy.rawValue &&
            nodeB.categoryBitMask == PhysicsCategory.Bullet.rawValue) ||
            
            (nodeA.categoryBitMask == PhysicsCategory.Bullet.rawValue &&
            nodeB.categoryBitMask == PhysicsCategory.Enemy.rawValue) {
            
            collisionWithBullet(enemy: nodeA.node as! SKSpriteNode, bullet: nodeB.node as! SKSpriteNode)
        }
        
        if  (nodeA.categoryBitMask == PhysicsCategory.Player.rawValue &&
            nodeB.categoryBitMask == PhysicsCategory.Enemy.rawValue) ||
            
            (nodeA.categoryBitMask == PhysicsCategory.Enemy.rawValue &&
            nodeB.categoryBitMask == PhysicsCategory.Player.rawValue) {
            
            collisionEnemyWithPlayer(player: nodeA.node as! SKSpriteNode, enemy: nodeB.node as! SKSpriteNode)
        }
    }
    
    func collisionWithBullet(enemy:SKSpriteNode, bullet:SKSpriteNode) {
        enemy.removeFromParent()
        bullet.removeFromParent()
    }
    
    func collisionEnemyWithPlayer(player:SKSpriteNode, enemy:SKSpriteNode) {
        bulletSpawnTimer.invalidate()
        enemySpawnTimer.invalidate()
    }
}
