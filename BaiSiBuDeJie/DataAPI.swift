//
//  DataAPI.swift
//  BaiSiBuDeJie
//
//  Created by tanson on 16/3/23.
//  Copyright © 2016年 tanson. All rights reserved.
//

import Foundation
import NetKit
import Alamofire


private let dateFormatter:NSDateFormatter = {
    let f = NSDateFormatter()
    f.dateFormat = "yyyyMMddHHmmss"
    return f
}()


enum DataAPI:NetKitTarget{
    case GetImageDatas(page:Int)
    case GetTextJoy(page:Int)
}


extension DataAPI{
    var baseURLString: String {
        return "http://route.showapi.com"
    }
    var path: String {
        return "/255-1"
    }
    var method: NetKit.NetKitMethod {
        return .GET
    }
    var parameters: [String : AnyObject]? {
        let now = NSDate()
        let dateStr = dateFormatter.stringFromDate(now)
        switch self{
        case .GetImageDatas(let page ):
            return ["type":"10","page":String(page),"showapi_timestamp":dateStr]
        case .GetTextJoy(let page ):
            return ["type":"29","page":String(page),"showapi_timestamp":dateStr]
        }
    }
}

