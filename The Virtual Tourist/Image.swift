//
//  Image.swift
//  The Virtual Tourist
//
//  Created by Moritz Gort on 24/03/16.
//  Copyright © 2016 Gabriele Gort. All rights reserved.
//

import Foundation
import UIKit
import CoreData

@objc(Image)

public class Image: NSManagedObject {
    
    @NSManaged public var imagePath: String
    @NSManaged public var flickrURL: NSURL
    @NSManaged public var location: Location?
    
    override public var description: String {
        get { return self.flickrURL.path!}
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(location: Location, imageURL: NSURL, context: NSManagedObjectContext) {
        let name = self.dynamicType.entityName()
        let entity = NSEntityDescription.entityForName(name, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        self.flickrURL = imageURL
        self.imagePath = self.flickrURL.lastPathComponent!
        self.location = location
        if self.ownImage == nil {
            _ = ImageLoader(image: self)
        }
    }
    
    public override func prepareForDeletion() {
        self.ownImage = nil
    }
    
    var ownImage: UIImage? {
        get { return ImageMemory.sharedInstance().imageForIdentifier("\(self.imagePath)") }
        set { ImageMemory.sharedInstance().saveImg(newValue, identifier: "\(self.imagePath)") }
    }
}
