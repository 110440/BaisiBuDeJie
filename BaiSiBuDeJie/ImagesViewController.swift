//
//  ViewController.swift
//  BaiSiBuDeJie
//
//  Created by tanson on 16/3/23.
//  Copyright © 2016年 tanson. All rights reserved.
//

import UIKit

class ImagesViewController: UITableViewController {

    var curPage = 1
    var gettingData = false
    
    typealias imageItem = DataModel.Pagebean.Contentlist
    var imageItemList = [imageItem]()
    
    var viewModel:ImageViewModel = {
       let vm = ImageViewModel()
        return vm
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100

        self.getNewData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    //TableView Delegate
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.imageItemList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ImageCell", forIndexPath: indexPath) as! ImageCell
        let placeImg = UIImage(named: "place.png")
        cell.imageV.image = placeImg
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? ImageCell else{return}
        let imageData = self.imageItemList[indexPath.row]
        cell.setData(imageData)
        cell.action = {
            let url = NSURL(string: imageData.image3! )
            let imageViewerItem = TTImageViewerItem(thumbImageView: cell.imageV, originSize: cell.imageV.image!.size, originURL: url)
            let imageViewer = TTImageViewerController(items: [imageViewerItem], showPageIndex: 0)
            imageViewer.imageViewContentMode = ZoomImageScrollViewContentMode.ScaleToFillForWidth
            self.presentViewController(imageViewer, animated: true, completion: nil)
        }
    }
    
    override func  scrollViewDidScroll(scrollView: UIScrollView) {
        
        //if  scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height * 0.8
        if  scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height + 100
        {
            self.getNewData()
        }
    }
    
    private func getNewData(){
        
        if self.gettingData { return }
        self.gettingData = true
        
        self.viewModel.getImageData(self.curPage) { data in
            
            if let imageData = data{
                
                self.imageItemList += imageData.contentlist ?? []

                dispatch_async(dispatch_get_main_queue()) {
                    //self.tableView.insertRowsAtIndexPaths(newIndexPaths, withRowAnimation: .None)
                    self.tableView.reloadData()
                    self.gettingData = false
                    self.title = "图片(第 \(self.curPage-1) 页)"
                }
                self.curPage++
            }
            
        }
        
    }

}

