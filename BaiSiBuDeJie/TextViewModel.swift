//
//  TextViewModel.swift
//  BaiSiBuDeJie
//
//  Created by tanson on 16/3/23.
//  Copyright © 2016年 tanson. All rights reserved.
//

import Foundation
import NetKit
import Alamofire

class TextViewModel: NSObject {
    
    typealias ImageDataReturnHandel = (data:DataModel.Pagebean?)->Void
    
    func getImageData(page:Int,handel:ImageDataReturnHandel){
        Alamofire.request(DataAPI.GetTextJoy(page: page)).responseObject { (response, object:DataModel?, error) -> () in
            if let dataObj = object{
                handel(data: dataObj.pagebean)
            }else{
                print(error)
            }
        }
    }
    
}