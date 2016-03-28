//
//  Utils.swift
//  BaiSiBuDeJie
//
//  Created by tanson on 16/3/23.
//  Copyright © 2016年 tanson. All rights reserved.
//

import Foundation
import UIKit

extension String{
    
    var int:Int{
        return Int(self) ?? 0
    }
    
    var float:Float{
        return Float(self) ?? 0
    }
    
    var cgFloat:CGFloat {
        return CGFloat(self.float)
    }
}

extension UIImage{
    class func imageWithColor(color:UIColor,size:CGSize)->UIImage?{
        
        if (size.width <= 0 || size.height <= 0) {return nil}
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}