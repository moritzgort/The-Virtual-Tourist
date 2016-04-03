//
//  LocationDetail.swift
//  The Virtual Tourist
//
//  Created by Moritz Gort on 24/03/16.
//  Copyright © 2016 Gabriele Gort. All rights reserved.
//

import Foundation
import CoreData
import MapKit

public class LocationDetail: NSManagedObject {
    
    @NSManaged var locationName: String
    @NSManaged var location: Location
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    convenience init(location: Location, locationName: String, context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.locationName = locationName
        self.location = location
    }
}