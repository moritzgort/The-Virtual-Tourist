//
//  CDManager.swift
//  The Virtual Tourist
//
//  Created by Moritz Gort on 25/03/16.
//  Copyright © 2016 Gabriele Gort. All rights reserved.
//

import Foundation
import CoreData

class CDManager {
    class func sharedInstance() -> CDManager {
        struct Static {
            static let instance = CDManager()
        }
        return Static.instance
    }
    
    lazy var model: CDModel = {return CDModel(name: "VirtualTourist")}()
    lazy var stack: CDStack = {return CDStack(model: self.model)}()
    
    func save() {
        if self.stack.managedObjectContext.hasChanges {
            do {
                try self.stack.managedObjectContext.save()
            } catch {
                print("Error")
                abort()
            }
        }
    }
}