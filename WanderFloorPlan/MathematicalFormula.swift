//
//  MathematicalFormula.swift
//  WanderFloorPlan
//
//  Created by Hu on 2017/11/27.
//  Copyright © 2017年 IDEAMAKE. All rights reserved.
//

import Cocoa

class MathematicalFormula: NSObject {
    
    //oppositeSide:角度相对边；adjacentSide：角度相邻边
    func getAngle(oppositeSide:CGFloat,adjacentSide:CGFloat) -> CGFloat {
        
        return atan2(oppositeSide,adjacentSide)
        
    }

}
