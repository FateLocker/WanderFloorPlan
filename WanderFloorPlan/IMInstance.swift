//
//  IMInstance.swift
//  WanderFloorPlan
//
//  Created by Hu on 2017/11/24.
//  Copyright © 2017年 IDEAMAKE. All rights reserved.
//

import Cocoa

class IMInstance: NSObject {
    
    private static var _sharedInstance:IMInstance?
    
    var mousePoint:NSPoint{
    
        didSet {
            
//            print(mousePoint)
        
        }
    }
    ///dotDic字典存储信息，key="空间名" value= NSArray[空间导航点坐标，空间导航点旋转角度] （or直接存储一个导航视图模型(包含坐标，旋转角度)？）
    var dotDic:NSDictionary = [:]
    
    class func getSharedInstance() -> IMInstance {
        
        guard let instance = _sharedInstance else {
            
            _sharedInstance = IMInstance()
            
            return _sharedInstance!
        }
        return instance
    }
    
    private override init() {
        
        mousePoint = NSPoint()
        
    }

}
