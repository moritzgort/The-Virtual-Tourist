//
//  CDStack.swift
//  The Virtual Tourist
//
//  Created by Moritz Gort on 25/03/16.
//  Copyright © 2016 Gabriele Gort. All rights reserved.
//

import Foundation
import CoreData

public final class CDStack: CustomStringConvertible {
    
    public let cDModel: CDModel
    public let managedObjectContext: NSManagedObjectContext
    public let persistentStoreCoordinator: NSPersistentStoreCoordinator
    
    public init(model: CDModel, type: String = NSSQLiteStoreType, options: [NSObject: AnyObject]? = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true], cType: NSManagedObjectContextConcurrencyType = .MainQueueConcurrencyType) {
        self.cDModel = model
        self.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model.managedObjectModel)
        let storedURL: NSURL? = (type == NSInMemoryStoreType) ? nil: cDModel.saveURL
        
        do {
            try self.persistentStoreCoordinator.addPersistentStoreWithType(type, configuration: nil, URL: storedURL, options: options)
        } catch _ {}
        
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: cType)
        self.managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
    }
    
    public func managedObjContext(cType: NSManagedObjectContextConcurrencyType = .MainQueueConcurrencyType, mergePolicy: NSMergePolicyType = .MergeByPropertyObjectTrumpMergePolicyType) -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: cType)
        context.parentContext = managedObjectContext
        context.mergePolicy = NSMergePolicy(mergeType: mergePolicy)
        return context
    }
    
    public var description: String{
        get { return "<\(String(CDStack.self)): model=\(cDModel)>" }
    }
}