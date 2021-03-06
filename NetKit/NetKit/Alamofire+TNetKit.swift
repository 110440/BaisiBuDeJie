//
//  Alamofire+TNetKit.swift
//  UseNetwork
//
//  Created by tanson on 16/1/31.
//  Copyright © 2016年 tanson. All rights reserved.
//

import Foundation
import Alamofire


// MARK:- responseObject
public extension Alamofire.Request {
    
    public func responseObject<T:TSwiftyJSONAble>(completionHandler: (response: NSURLResponse?,object: T?, error: NSError?) -> () ) -> Self{
        return responseJSON(completionHandler: { response in
            switch response.result{
            case .Success(let jsonValue):
                // to swiftyJSON
                var json = JSON(jsonValue)
                
                // 对于业务上的协议,这里可以有一次机会对返回的数据再进行过滤,设置NetKitGloble.willReturnObjectBlock就行
                // 比如对返回 json 的 (code , msg , result) 字段进行处理
                if let willReturnObjectBlock = NetKitGloble.willReturnObjectBlock {
                    
                    let (newjson,error) = willReturnObjectBlock(json: json)
                    if let error = error {
                        completionHandler(response: response.response , object: nil, error: error)
                        return
                    }
                    if newjson == nil{ fatalError("NetKit responseObject () willReturnObjectBlock must return newJson or error !") }
                    json = newjson!
                }
                
                let obj = T(json: json)
                if obj != nil {
                    completionHandler(response: response.response , object: obj, error: nil)
                }else{
                    let failureReason = "object could not be init from SwiftyJSON "
                    let error = NSError(domain: failureReason , code: -1, userInfo: nil)
                    completionHandler(response: response.response , object: nil, error: error)
                }
                
            case .Failure(let error):
                completionHandler(response: response.response, object: nil, error: error as NSError)
            }
        })
    }

}

// MARK:- responseArray
public extension Alamofire.Request {
    
    public func responseArray<T:TSwiftyJSONAble>(completionHandler: (response: NSURLResponse?,object: [T]?, error: NSError?) -> () ) -> Self{
        return responseJSON(completionHandler: { response in
            switch response.result{
            case .Success(let value):
                
                var json = JSON(value)
                
                if let willReturnObjectBlock = NetKitGloble.willReturnObjectBlock{
                    
                    let (newjson,error) = willReturnObjectBlock(json: json)
                    if let error = error {
                        completionHandler(response: response.response , object: nil, error: error)
                        return
                    }
                    if newjson == nil{ fatalError("NetKit responseArray() willReturnObjectBlock must return newJson or error !") }
                    json = newjson!
                }
                
                let jsonArray:[JSON] = json.arrayValue
                var objectArray = [T]()
                for json in jsonArray{
                    let obj = T(json: json)
                    if let object = obj {
                        objectArray.append(object)
                    }else{
                        print("object could not be init from SwiftyJSON")
                    }
                }
                
                completionHandler(response: response.response , object: objectArray, error: nil)
                
            case .Failure(let error):
                completionHandler(response: response.response, object: nil, error: error as NSError)
            }
        })
    }
}

