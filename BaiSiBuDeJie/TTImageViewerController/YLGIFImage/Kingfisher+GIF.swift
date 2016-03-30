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
import ImageIO
import MobileCoreServices

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

private func ImageGIFRepresentation(image: Image,repeatCount: Int = 0 ) -> NSData? {
    guard let images = image.images else {
        return nil
    }
    
    let frameCount = images.count
    let gifDuration = image.duration / Double(frameCount)
    
    let frameProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: gifDuration]]
    let imageProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: repeatCount]]
    
    let data = NSMutableData()
    
    guard let destination = CGImageDestinationCreateWithData(data, kUTTypeGIF, frameCount, nil) else {
        return nil
    }
    CGImageDestinationSetProperties(destination, imageProperties)
    
    for image in images {
        CGImageDestinationAddImage(destination, image.CGImage!, frameProperties)
    }
    return CGImageDestinationFinalize(destination) ? NSData(data: data) : nil
}


private var ttImageTaskKey: Void?

extension UIImageView{
    
    private var tt_imageTask: RetrieveImageTask? {
        return objc_getAssociatedObject(self, &ttImageTaskKey) as? RetrieveImageTask
    }
    
    private func tt_setImageTask(task: RetrieveImageTask?) {
        objc_setAssociatedObject(self, &ttImageTaskKey, task, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func tt_setImageWithURL(URL: NSURL, placeholderImage: Image?, optionsInfo: KingfisherOptionsInfo?, progressBlock: DownloadProgressBlock?, completionHandler: CompletionHandler?){
        
        self.tt_imageTask?.cancel()

        let task = self.kf_setImageWithURL(URL, placeholderImage: placeholderImage, optionsInfo: optionsInfo, progressBlock: progressBlock) { (image, error, cacheType, imageURL) -> () in

            guard let _ = image?.images else {
                completionHandler?(image:image, error:error, cacheType: cacheType, imageURL: imageURL)
                return
            }
            
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
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { [weak self]() -> Void in
                    
                    let imageCache = KingfisherManager.sharedManager.cache
                    let filePath = imageCache.cachePathForKey(imageURL!.absoluteString)
                    
                    var imageData = NSData(contentsOfFile: filePath)
                    if  imageData == nil {
                        print("找不到本地GIF文件\(filePath)")
                        imageData = ImageGIFRepresentation(image!)
                        
                        if imageData == nil {

                            dispatch_async_safely_to_main_queue(){
                                print("GIF Representation failed ")
                                completionHandler?(image:image, error:error, cacheType: cacheType, imageURL: imageURL)
                            }
                            return
                        }
                    }
                    
                    let gifImage = YLGIFImage(data: imageData!)
                    
                    dispatch_async_safely_to_main_queue(){
                        self?.stopAnimating()
                        self?.image = gifImage
                        self?.startAnimating()
                        completionHandler?(image:gifImage, error:error, cacheType: cacheType, imageURL: imageURL)
                    }
                    
                    imageCache.storeImage(gifImage!, forKey:imageURL!.absoluteString, toDisk: false, completionHandler:nil)
                })
                
            }
        }
        self.tt_setImageTask(task)
    }
}