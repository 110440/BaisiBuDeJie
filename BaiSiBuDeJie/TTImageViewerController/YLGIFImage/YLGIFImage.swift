//
//  YLGIFImage.swift
//  YLGIFImage
//
//  Created by Yong Li on 6/8/14.
//  Copyright (c) 2014 Yong Li. All rights reserved.
//

import UIKit
import ImageIO
import MobileCoreServices

public
class YLGIFImage : UIImage {

    private lazy var readFrameQueue:dispatch_queue_t = dispatch_queue_create("com.ronnie.gifreadframe", DISPATCH_QUEUE_SERIAL)

    public var frameScale:CGFloat = 1.0
    private var _cgImgSource:CGImageSource? = nil
    var totalDuration: NSTimeInterval = 0.0
    var frameDurations = [AnyObject]()
    var loopCount: UInt = 1
    var frameImages:[AnyObject] = [AnyObject]()
    var data:NSData?

    struct YLGIFGlobalSetting {
        static var prefetchNumber:UInt = 2
    }

    class var prefetchNum: UInt {
        return YLGIFGlobalSetting.prefetchNumber
    }

    class func setPrefetchNum(number:UInt) {
        YLGIFGlobalSetting.prefetchNumber = number
    }

    convenience override init?(contentsOfFile path: String) {
        let data = NSData(contentsOfURL: NSURL(string: path)!)
        self.init(data: data!)
    }

    convenience override init?(data: NSData)  {
        self.init(data: data, scale: 1.0)
    }

    override init?(data: NSData, scale: CGFloat) {
        
        let cgImgSource = CGImageSourceCreateWithData(data, nil)
        if YLGIFImage.isCGImageSourceContainAnimatedGIF(cgImgSource) {
            self.data = data
            let cgimage = CGImageSourceCreateImageAtIndex(cgImgSource!, 0, nil)
            super.init(CGImage: cgimage!, scale: scale, orientation:.Up)
            createSelf(cgImgSource, scale: scale)
        } else {
            super.init(data: data, scale: scale)
        }
    }

    required convenience public init(imageLiteral name: String) {
        fatalError("init(imageLiteral:) has not been implemented")
    }
    
    private func createSelf(cgImageSource: CGImageSource!, scale: CGFloat) -> Void {
        _cgImgSource = cgImageSource
        let imageProperties:NSDictionary = CGImageSourceCopyProperties(_cgImgSource!, nil)!
        let gifProperties: NSDictionary? = imageProperties[kCGImagePropertyGIFDictionary as String] as? NSDictionary
        if let property = gifProperties {
            self.loopCount = property[kCGImagePropertyGIFLoopCount as String] as! UInt
        }
        let numOfFrames = CGImageSourceGetCount(cgImageSource)
        for i in 0..<numOfFrames {
            // get frame duration
            let frameDuration = YLGIFImage.getCGImageSourceGifFrameDelay(cgImageSource, index: UInt(i))
            self.frameDurations.append(NSNumber(double: frameDuration))
            self.totalDuration += frameDuration

            //Log("dura = \(frameDuration)")

            if i < Int(YLGIFImage.prefetchNum) {
                // get frame
                let cgimage = CGImageSourceCreateImageAtIndex(cgImageSource, i, nil)
                let image: UIImage = UIImage(CGImage: cgimage!)
                self.frameImages.append(image)
                
                //Log("\(i): frame = \(image)")
            } else {
                self.frameImages.append(NSNull())
            }
        }
        //Log("\(self.frameImages.count)")
    }

    func getFrame(index: UInt) -> UIImage? {
        if Int(index) >= self.frameImages.count {
            return nil
        }
        let image:UIImage? = self.frameImages[Int(index)] as? UIImage
        if self.frameImages.count > Int(YLGIFImage.prefetchNum) {
            if index != 0 {
                self.frameImages[Int(index)] = NSNull()
            }

            for i in index+1...index+YLGIFImage.prefetchNum {
                let idx = Int(i)%self.frameImages.count
                if self.frameImages[idx] is NSNull {
                    dispatch_async(self.readFrameQueue){[weak self] in
                        guard let wself = self else {return}
                        let cgImg = CGImageSourceCreateImageAtIndex(wself._cgImgSource!, idx, nil)
                        let uiImage = UIImage(CGImage: cgImg!)
                        if wself.frameScale != 1.0 {
                            let newSize = CGSize(width:wself.size.width * wself.frameScale, height: wself.size.height * wself.frameScale)
                            wself.frameImages[idx] = uiImage.imageByReSize(newSize)
                        }else{
                            wself.frameImages[idx] = uiImage
                        }
                    }
                }
            }
        }
        return image
    }

    private class func isCGImageSourceContainAnimatedGIF(cgImageSource: CGImageSource!) -> Bool {
        let isGIF = UTTypeConformsTo(CGImageSourceGetType(cgImageSource)!, kUTTypeGIF)
        let imgCount = CGImageSourceGetCount(cgImageSource)
        return isGIF && imgCount > 1
    }

    private class func getCGImageSourceGifFrameDelay(imageSource: CGImageSourceRef, index: UInt) -> NSTimeInterval {
        var delay = 0.0
        let imgProperties:NSDictionary = CGImageSourceCopyPropertiesAtIndex(imageSource, Int(index), nil)!
        let gifProperties:NSDictionary? = imgProperties[kCGImagePropertyGIFDictionary as String] as? NSDictionary
        if let property = gifProperties {
            delay = property[kCGImagePropertyGIFUnclampedDelayTime as String] as! Double
            if delay <= 0 {
                delay = property[kCGImagePropertyGIFDelayTime as String] as! Double
            }
        }
        return delay
    }
    
    // coding
    required public init?(coder aDecoder: NSCoder) {
        
        guard let originData = aDecoder.decodeObjectForKey("originData") as? NSData else{
            self.data = nil
            super.init(coder: aDecoder)
            return
        }
        guard let scale = aDecoder.decodeObjectForKey("frameScale") as? NSNumber else{
            self.data = nil
            super.init(coder: aDecoder)
            return
        }
        
        self.frameScale = CGFloat(scale.floatValue)
        self.data = originData
        let cgImgSource = CGImageSourceCreateWithData(originData, nil)
        super.init(coder: aDecoder)
        createSelf(cgImgSource, scale: 1)
    }
    
    override public func encodeWithCoder(aCoder: NSCoder) {
        if self.data != nil{
            aCoder.encodeObject(self.data, forKey: "originData")
            aCoder.encodeObject(NSNumber(float:Float(self.frameScale) ), forKey: "frameScale")
        }else{
            super.encodeWithCoder(aCoder)
        }
    }
    
    public func imageByCopy()->UIImage?{
        
        guard let originData = self.data else {return nil}
        let newImage = YLGIFImage(data:originData)
        newImage?.frameScale = self.frameScale
        return newImage
    }
}

//extension
extension UIImage{
    
    private func imageByReSize(size:CGSize)->UIImage{
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        self.drawInRect(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}