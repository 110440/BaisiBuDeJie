//
//  TTImageViewerCell2TableViewCell.swift
//  TestAnimations
//
//  Created by tanson on 16/3/19.
//  Copyright © 2016年 tanson. All rights reserved.
//

import UIKit
import Kingfisher

class TTImageViewerCell: UICollectionViewCell {

    var action:(()->Void)?
    
    lazy var scrollView:ZoomImageScrollView = {
        let view = ZoomImageScrollView(frame:CGRect(x:tt_pageSpace, y: 0, width: self.bounds.size.width-tt_pageSpace*2, height: self.bounds.size.height))
        return view
    }()
    
    var progressLab:UILabel = {
        let lab = UILabel()
        lab.textColor = UIColor.redColor()
        return lab
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.scrollView)
        self.scrollView.clickAction = {[weak self] in
            self?.action?()
        }
        self.contentView.addSubview(self.progressLab)
        self.progressLab.center = self.contentView.center
    }

    func setImageCellItem(item:TTImageViewerItem){

        self.scrollView.setImage(item.thumbImageView.image!,size: item.originSize)
        
        if let url = item.originURL{
            
            self.scrollView.imageView.kf_setImageWithURL(url, placeholderImage: nil, optionsInfo: nil, progressBlock: { [weak self](receivedSize, totalSize) in
                    let progress = Float(receivedSize) / Float(totalSize)
                    self?.progressLab.text = String(progress)
                    self?.progressLab.hidden = false
                    self?.progressLab.sizeToFit()
                }, completionHandler: { [weak self](image, error, cacheType, imageURL) in
                    self?.progressLab.hidden = true
                    self?.scrollView.setImage(image!,size: item.originSize)
            })
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
