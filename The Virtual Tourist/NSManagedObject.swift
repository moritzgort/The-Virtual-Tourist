//
//  NSManagedObject.swift
//  The Virtual Tourist
//
//  Created by Moritz Gort on 24/03/16.
//  Copyright © 2016 Gabriele Gort. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
    
    class func entityName() -> String {
        let fullName = NSStringFromClass(object_getClass(self))
        let name = fullName.characters.split{$0 == "."}.map {String($0)}
        return name.last!
    }
    
    convenience init(context: NSManagedObjectContext) {
        let name = self.dynamicType.entityName()
        let entity = NSEntityDescription.entityForName(name, inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
    }
}