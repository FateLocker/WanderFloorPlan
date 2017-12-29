//
//  DotImgaeView.swift
//  WanderFloorPlan
//
//  Created by Hu on 2017/12/11.
//  Copyright © 2017年 IDEAMAKE. All rights reserved.
//

import Cocoa

class DotImgaeView: NSImageView{
    
    var selected = false
    
    var id = String()
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        
        let trackArea = NSTrackingArea.init(rect: dirtyRect, options: [.activeInActiveApp,.mouseMoved,.mouseEnteredAndExited], owner: self, userInfo: nil)
        
        self.addTrackingArea(trackArea)
        
    }
    
    override func mouseDown(with event: NSEvent) {
        
        selected = !selected
        
        self.wantsLayer = true
        
        self.layer?.cornerRadius = 5
        
        self.layer?.backgroundColor = selected ? NSColor.gray.cgColor:NSColor.green.cgColor
        
        self.setNeedsDisplay()
    }
    
}
