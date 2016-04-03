//
//  ImageDownload.swift
//  The Virtual Tourist
//
//  Created by Moritz Gort on 24/03/16.
//  Copyright © 2016 Gabriele Gort. All rights reserved.
//

import Foundation

class ImageDownload: NSObject {
    
    class func sharedInstance() -> ImageDownload {
        struct Static {
            static let instance = ImageDownload()
        }
        return Static.instance
    }
    
    var downloading: [Int: AnyObject] = [Int: AnyObject]()
    var loadingQueue: NSOperationQueue
    var downloaders: Set<ImageLoader> = Set()
    
    override init() {
        loadingQueue = NSOperationQueue()
        loadingQueue.name = "Loading Queue"
        loadingQueue.maxConcurrentOperationCount = 6
        super.init()
    }
}