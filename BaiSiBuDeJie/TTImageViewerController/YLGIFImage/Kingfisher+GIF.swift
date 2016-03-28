//
//  Kingfisher+GIF.swift
//  joyEveryDay
//
//  Created by tanson on 16/3/26.
//  Copyright © 2016年 tanson. All rights reserved.
//

import Foundation
import Kingfisher
import UIKit


private func dispatch_async_safely_to_main_queue(block: ()->()) {
    dispatch_async_safely_to_queue(dispatch_get_main_queue(), block)
}

private func dispatch_async_safely_to_queue(queue: dispatch_queue_t, _ block: ()->()) {
    if queue === dispatch_get_main_queue() && NSThread.isMainThread() {
        block()
    } else {
        dispatch_async(queue) {
            block()
        }
    }
}

extension UIImageView{
    
    func kf_setImageWithURL_tt(URL: NSURL, placeholderImage: Image?, optionsInfo: KingfisherOptionsInfo?, progressBlock: DownloadProgressBlock?, completionHandler: CompletionHandler?){
        
        self.kf_setImageWithURL(URL, placeholderImage: placeholderImage, optionsInfo: optionsInfo, progressBlock: progressBlock) { (image, error, cacheType, imageURL) -> () in

            guard let _ = image?.images else {
                completionHandler?(image:image, error:error, cacheType: cacheType, imageURL: imageURL)
                return
            }
            
            let imageCache = KingfisherManager.sharedManager.cache
            imageCache.removeImageForKey((imageURL?.absoluteString)!, fromDisk: false, completionHandler: nil)
            
            if cacheType == CacheType.Memory{
                
                dispatch_async_safely_to_main_queue(){
                    self.stopAnimating()
                    
                    let YLimage = (image as? YLGIFImage)
                    let imageCopy = (YLimage == nil) ? image!:YLimage!.imageByCopy()
                    self.image = imageCopy
                    self.startAnimating()
                    completionHandler?(image:image!, error:error, cacheType: cacheType, imageURL: imageURL)
                }

            }else{
                
                let filePath = imageCache.cachePathForKey(imageURL!.absoluteString)
                guard let imageData = NSData(contentsOfFile: filePath) else{
                    print("找不到本地GIF文件\(filePath)")
                    completionHandler?(image:image, error:error, cacheType: cacheType, imageURL: imageURL)
                    return
                }
                
                let gifImage = YLGIFImage(data: imageData)
                
                dispatch_async_safely_to_main_queue(){
                    self.stopAnimating()
                    self.image = gifImage
                    self.startAnimating()
                    completionHandler?(image:gifImage, error:error, cacheType: cacheType, imageURL: imageURL)
                }
                
                imageCache.storeImage(gifImage!, forKey:imageURL!.absoluteString, toDisk: false, completionHandler:nil)
            }
            
            
        }
    }
}