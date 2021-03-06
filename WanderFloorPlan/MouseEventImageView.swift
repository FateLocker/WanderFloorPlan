//
//  MouseEventImageView.swift
//  WanderFloorPlan
//
//  Created by Hu on 2017/11/22.
//  Copyright © 2017年 IDEAMAKE. All rights reserved.
//

import Cocoa

class MouseEventImageView: NSImageView {
    
    enum IMGType {
        case Floor //户型图类视图
        case Nagivate //导航类视图
    }
    
    var type = IMGType.Nagivate //视图类型，默认为导航类视图
    
    var mousePoint = NSPoint.init() //视图内鼠标坐标
    
    var center = NSPoint.init() //视图坐标点
    
    var imageViewName = String()
    
    var rotation = CGFloat() //旋转角度

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        
        let trackingArea = NSTrackingArea.init(rect:dirtyRect, options: [.activeInActiveApp,.mouseMoved,.mouseEnteredAndExited], owner: self, userInfo: nil)
        
        self.addTrackingArea(trackingArea)
        
    }
    
    override func mouseMoved(with event: NSEvent) {
        
        let pt = self.convert(event.locationInWindow, from: self.window?.contentView)
        
        IMInstance.getSharedInstance().mousePoint = pt
        
    }
    
    
    
    override func mouseDown(with event: NSEvent) {
        
        self.mousePoint = self.convert(event.locationInWindow, from: self.window?.contentView)
    }
    
    override func mouseUp(with event: NSEvent) {
        
        self.rotation = (MathematicalFormula().getAngle(oppositeSide: (self.mousePoint.y - 150), adjacentSide: (self.mousePoint.x - 150)) / .pi) * -180
        
    }
    
    override func mouseDragged(with event: NSEvent) {
        
        if self.type == .Floor {
            
            return
        }
        
        self.wantsLayer = true
        
        let dynamicPoint = self.convert(event.locationInWindow, from: self.window?.contentView)
        
        let radius1 = MathematicalFormula().getAngle(oppositeSide: (dynamicPoint.y - 150), adjacentSide: (dynamicPoint.x - 150))
        
        let radius2 = MathematicalFormula().getAngle(oppositeSide: (self.mousePoint.y - 150), adjacentSide: (self.mousePoint.x - 150))
        
        let animation = CABasicAnimation.init(keyPath: "transform")
        
        animation.isRemovedOnCompletion = false
        
        animation.fillMode = kCAFillModeForwards
        
        animation.fromValue = NSValue(caTransform3D: CATransform3DRotate(CATransform3DIdentity, radius1, 0, 0, 1))
        
        animation.toValue = NSValue(caTransform3D: CATransform3DRotate(CATransform3DIdentity, radius2, 0, 0, 1))
        
        self.layer?.add(animation, forKey: "")
        
        self.setNeedsDisplay()
        
        self.mousePoint = dynamicPoint
    }
    
}
