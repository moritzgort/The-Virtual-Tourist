//
//  ImageLoader.swift
//  The Virtual Tourist
//
//  Created by Moritz Gort on 24/03/16.
//  Copyright © 2016 Gabriele Gort. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

public class ImageLoader: NSOperation, NSURLSessionDataDelegate {
    
    var finishedDownloadDelegate:[FinishedDownloadDelegate] = [FinishedDownloadDelegate]()
    private var displayData: NSMutableData?
    private var totalData: Int = 0
    private var receivedData: Int = 0
    var image: Image
    var session: NSURLSession!
    
    public override var hashValue: Int {
        get {
            return self.image.flickrURL.path!.hashValue
        }
    }
    
    init(image: Image) {
        self.image = image
        super.init()
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        session = NSURLSession(configuration: config, delegate: self, delegateQueue: ImageDownload.sharedInstance().loadingQueue)
        
        ImageDownload.sharedInstance().downloading[self.image.description.hashValue] = self
        
        objc_sync_enter(ImageDownload.sharedInstance().downloaders)
        ImageDownload.sharedInstance().downloaders.insert(self)
        objc_sync_exit(ImageDownload.sharedInstance().downloaders)
        
        if ImageDownload.sharedInstance().downloaders.count <= ImageDownload.sharedInstance().loadingQueue.maxConcurrentOperationCount {
            ImageDownload.sharedInstance().loadingQueue.addOperation(self)
        }
    }
    
    public override func main() {
        let req = NSURLRequest(URL: self.image.flickrURL)
        let data = self.session.dataTaskWithRequest(req)
        data.resume()
    }
    
    public func isLoading() -> Bool {
        return ImageDownload.sharedInstance().downloading.indexForKey(self.image.description.hashValue) != nil
    }
    
    override public func cancel() {
        super.cancel()
        self.finishedDownloadDelegate.removeAll()
        self.totalData = 0
        self.receivedData = 0
        self.displayData = nil
        self.session = nil
        ImageDownload.sharedInstance().downloading.removeValueForKey(self.image.description.hashValue)
    }
    
    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        if self.cancelled { return }
        self.receivedData = 0
        self.totalData = Int(response.expectedContentLength)
        self.displayData = NSMutableData(capacity: self.totalData)
        completionHandler(NSURLSessionResponseDisposition.Allow)
    }
    
    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        if self.cancelled { return }
        self.displayData?.appendData(data)
        self.receivedData += data.length
    }
    
    public func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if let error = error {
            print(error)
        }
        
        if let data = self.displayData {
            let img = UIImage(data: data)
            self.image.ownImage = img!
        }
        
        objc_sync_enter( ImageDownload.sharedInstance().downloaders)
        ImageDownload.sharedInstance().downloaders.remove(self)
        let pendingWorkers = ImageDownload.sharedInstance().downloaders.filter { !$0.finished && !$0.executing}
        if let worker = pendingWorkers.first {
            ImageDownload.sharedInstance().downloaders.insert(worker)
            ImageDownload.sharedInstance().loadingQueue.addOperation(worker)
        }
        objc_sync_exit( ImageDownload.sharedInstance().downloaders)
        
        for next in finishedDownloadDelegate {
            print("finishedDownloadDelegate")
            dispatch_async(dispatch_get_main_queue()) {
                next.finishedLoad()
            }
        }
        
        self.finishedDownloadDelegate.removeAll(keepCapacity: false)
        self.displayData = nil
        self.session = nil
    }
}