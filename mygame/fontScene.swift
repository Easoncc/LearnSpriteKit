//
//  fontScene.swift
//  mygame
//
//  Created by 陈超 on 2019/1/26.
//  Copyright © 2019 chenchao. All rights reserved.
//

import UIKit
import SpriteKit

class fontScene: SKScene {
    
    var playableRect: CGRect!
    var familyIndex: Int = -1
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(size: CGSize) {
        super.init(size: size)
        
        let maxAspectRatio = UIScreen.main.bounds.size.width/UIScreen.main.bounds.size.height
        let playableHeight = size.width/maxAspectRatio
        let playableMargin = (size.height-playableHeight)/2.0
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        
        showNextFamily()
    }
    func showCurrentFamily() -> Bool {
        // TODO: Coming soon...
        // 1
        removeAllChildren()
        // 2
        let familyName = UIFont.familyNames[familyIndex]
        // 3
        let fontNames = UIFont.fontNames(forFamilyName: familyName)
        if fontNames.count == 0 {
            return false
        }
        print("Family: \(familyName)")
        // 4
        for (idx, fontName) in fontNames.enumerated() {
            let label = SKLabelNode(fontNamed: fontName)
            label.text = fontName
            label.position = CGPoint(
                x: size.width / 2,
                y: (playableRect.size.height * (CGFloat(idx+1))) /
                    (CGFloat(fontNames.count)+1)+playableRect.origin.y)
            label.fontSize = 50
            label.verticalAlignmentMode = .center
            addChild(label)
        }
        
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
                               showNextFamily()
    }
    
    func showNextFamily() {
        var familyShown = false
        repeat {
            familyIndex += 1
            if familyIndex >= UIFont.familyNames.count {
                familyIndex = 0
            }
            familyShown = showCurrentFamily()
        } while !familyShown
    }
    
}
