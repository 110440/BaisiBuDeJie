//
//  ImageCell.swift
//  BaiSiBuDeJie
//
//  Created by tanson on 16/3/23.
//  Copyright © 2016年 tanson. All rights reserved.
//

import UIKit
import Kingfisher
import JWAnimatedImage


class ImageCell: UITableViewCell ,ImageDownloaderDelegate {

    var action:(()->Void)?
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titlelab: UILabel!
    @IBOutlet weak var contentLab: UILabel!
    
    @IBOutlet weak var timeLab: UILabel!
    @IBOutlet weak var imageV: UIImageView!
    
    @IBOutlet weak var imageVWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageVHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.imageV.userInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: "tap")
        tap.numberOfTapsRequired = 1
        self.imageV.addGestureRecognizer(tap)
        
        
        //限定内存
        let imageCache = ImageCache(name: "BaisiBuDeJie_imageCache")
        imageCache.maxMemoryCost = (200 * 300) * 20 //长宽为200X300的图片30张
        KingfisherManager.sharedManager.cache = imageCache
    }
    
    func tap(){
        self.action?()
    }

    
    func setData(data:DataModel.Pagebean.Contentlist){
        
        if let iconUrl = data.profile_image{
            self.iconView.kf_setImageWithURL(NSURL(string:iconUrl)!)
        }
        self.titlelab.text = data.name
        self.contentLab.text = data.text?.stringByReplacingOccurrencesOfString("\n", withString: "")
        self.timeLab.text = data.create_time
    
        if let imageURLStr = data.image0{
            let placeImg = UIImage(named: "place.png")
            self.imageV.image = placeImg
            
            //self.imageV.yy_setImageWithURL(NSURL(string:imageURLStr), placeholder: placeImg, options: [.ProgressiveBlur,.SetImageWithFadeAnimation], completion: nil)

            self.imageV.kf_setImageWithURL_tt(NSURL(string:imageURLStr)!, placeholderImage: placeImg, optionsInfo: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
//                if let image = image as? YLGIFImage {
//                    let size = image.size ?? CGSizeZero
//                    let maxSize = CGSize(width: 180, height: 200)
//                    let scalew = maxSize.width / size.width
//                    let scaleh = maxSize.height / size.height
//                    let scale = min(scalew,scaleh)
//                    image.frameScale = scale
//                }
            })
            
        }else{
            self.imageV.image = nil
            self.imageV.heightConstant = 0
            self.imageV.topConstant = 0
        }
    }
    
    //


}
