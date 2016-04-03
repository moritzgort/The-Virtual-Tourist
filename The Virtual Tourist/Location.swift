//
//  Location.swift
//  The Virtual Tourist
//
//  Created by Moritz Gort on 24/03/16.
//  Copyright © 2016 Gabriele Gort. All rights reserved.
//

import Foundation
import CoreData

@objc(Location)

public class Location: NSManagedObject {
    
    @NSManaged public var latitude: NSNumber
    @NSManaged public var longitude: NSNumber
    @NSManaged public var myImages: [Image]
    @NSManaged public var details: LocationDetail?
    
    override public var description: String {
        get {
            return "latitude:\(self.latitude)::longitude:\(self.longitude)"
        }
    }
    
    override public var hashValue: Int {
        get {
            return self.description.hashValue
        }
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    convenience init(latitude: NSNumber, longitude: NSNumber, context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func isLoading() -> Bool {
        var isLoading = false
        for next in self.myImages {
            if let downloader = ImageDownload.sharedInstance().downloading[next.description.hashValue] as? ImageLoader {
                if downloader.isLoading() {
                    isLoading = true
                    break
                }
            }
        }
        return isLoading
    }
}