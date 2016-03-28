//
//  DataModel.swift
//  BaiSiBuDeJie
//
//  Created by tanson on 16/3/23.
//  Copyright © 2016年 tanson. All rights reserved.
//

import Foundation
import NetKit

class DataModel:TSwiftyJSONAble,TToDictionaryAble {
    
    class Pagebean:TSwiftyJSONAble,TToDictionaryAble {
        
        class Contentlist:TSwiftyJSONAble,TToDictionaryAble {
            
            var create_time:String?
            var width:String?
            var image1:String?
            var weixin_url:String?
            var image2:String?
            var love:String?
            var voiceuri:String?
            var type:String?
            var profile_image:String?
            var name:String?
            var voicetime:String?
            var voicelength:String?
            var id:String?
            var text:String?
            var hate:String?
            var height:String?
            var image3:String?
            var image0:String?
            var videotime:String?
            
            required init?(json:JSON) {
                self.create_time = json["create_time"].string
                self.width = json["width"].string
                self.image1 = json["image1"].string
                self.weixin_url = json["weixin_url"].string
                self.image2 = json["image2"].string
                self.love = json["love"].string
                self.voiceuri = json["voiceuri"].string
                self.type = json["type"].string
                self.profile_image = json["profile_image"].string
                self.name = json["name"].string
                self.voicetime = json["voicetime"].string
                self.voicelength = json["voicelength"].string
                self.id = json["id"].string
                self.text = json["text"].string
                self.hate = json["hate"].string
                self.height = json["height"].string
                self.image3 = json["image3"].string
                self.image0 = json["image0"].string
                self.videotime = json["videotime"].string
            }
            
            init(){ }
            
            func toDictionary()->Dictionary<String,AnyObject>{
                var dic = [String:AnyObject]()
                dic["create_time"] = self.create_time
                dic["width"] = self.width
                dic["image1"] = self.image1
                dic["weixin_url"] = self.weixin_url
                dic["image2"] = self.image2
                dic["love"] = self.love
                dic["voiceuri"] = self.voiceuri
                dic["type"] = self.type
                dic["profile_image"] = self.profile_image
                dic["name"] = self.name
                dic["voicetime"] = self.voicetime
                dic["voicelength"] = self.voicelength
                dic["id"] = self.id
                dic["text"] = self.text
                dic["hate"] = self.hate
                dic["height"] = self.height
                dic["image3"] = self.image3
                dic["image0"] = self.image0
                dic["videotime"] = self.videotime
                return dic
            }
            
        }
        
        var allNum:Int?
        var maxResult:Int?
        var currentPage:Int?
        var allPages:Int?
        var contentlist:[Contentlist]?
        
        required init?(json:JSON) {
            self.allNum = json["allNum"].int
            self.maxResult = json["maxResult"].int
            self.currentPage = json["currentPage"].int
            self.allPages = json["allPages"].int
            self.contentlist = json["contentlist"].toObjectArray(Contentlist) 
        }
        
        init(){ }
        
        func toDictionary()->Dictionary<String,AnyObject>{
            var dic = [String:AnyObject]()
            dic["allNum"] = self.allNum 
            dic["maxResult"] = self.maxResult 
            dic["currentPage"] = self.currentPage 
            dic["allPages"] = self.allPages 
            dic["contentlist"] = TTparseObjArrayToAnyObjArray(self.contentlist)
            return dic 
        }
        
    }
    
    var ret_code:Int?
    var pagebean:Pagebean?
    
    required init?(json:JSON) {
        self.ret_code = json["ret_code"].int
        self.pagebean = json["pagebean"].toObject(Pagebean) 
    }
    
    init(){ }
    
    func toDictionary()->Dictionary<String,AnyObject>{
        var dic = [String:AnyObject]()
        dic["ret_code"] = self.ret_code 
        dic["pagebean"] = self.pagebean?.toDictionary() 
        return dic 
    }
    
}

