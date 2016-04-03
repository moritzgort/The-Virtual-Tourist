//
//  ImageMemory.swift
//  The Virtual Tourist
//
//  Created by Moritz Gort on 25/03/16.
//  Copyright © 2016 Gabriele Gort. All rights reserved.
//

import Foundation
import UIKit

class ImageMemory {
    private var imgInCache = NSCache()
    
    class func sharedInstance() -> ImageMemory {
        struct Static {
            static let instance = ImageMemory()
        }
        return Static.instance
    }
    
    func imageForIdentifier(identifier: String?) -> UIImage? {
        let id = identifier
        print(identifier)
        
        let directory = directoryForID(id!)
        print(directory)
        if let img = imgInCache.objectForKey(id!) as? UIImage {
            return img
        }
        if let img = NSData(contentsOfFile: directory) {
            //print("thats the img: \(img)")
            return UIImage(data: img)
        }
        return nil
    }
    
    func saveImg(img: UIImage?, identifier: String) {
        let directory = directoryForID(identifier)
        if img == nil {
            imgInCache.removeObjectForKey(directory)
            do {
                try NSFileManager.defaultManager().removeItemAtPath(directory)
            } catch _ {}
            return
        }
        imgInCache.setObject(img!, forKey: directory)
        let imgData = UIImagePNGRepresentation(img!)!
        imgData.writeToFile(directory, atomically: true)
    }
    
    func directoryForID(identifier: String) -> String {
        let directoryPath: NSURL = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentationDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first!
        return (directoryPath.URLByAppendingPathComponent(identifier).path!)
    }
}