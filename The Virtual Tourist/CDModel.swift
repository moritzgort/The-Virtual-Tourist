//
//  CDModel.swift
//  Virtual Tourist Udacity
//
//  Created by Moritz Gort on 10/03/16.
//  Copyright © 2016 Gabriele Gort. All rights reserved.
//

import Foundation
import CoreData

public typealias ContextSaveResults = (success: Bool, error: NSError?)

public struct CDModel: CustomStringConvertible {
    public let title: String
    public let bundle: NSBundle
    public let saveDirectory: NSURL
    
    public var saveURL: NSURL {
        get {
            return saveDirectory.URLByAppendingPathComponent(databaseFileName)
        }
    }
    
    public var modelURL: NSURL {
        get {
            return bundle.URLForResource(title, withExtension: "momd")!
        }
    }
    
    public var databaseFileName: String {
        get {
            return title + ".sqlite"
        }
    }
    
    public var managedObjectModel: NSManagedObjectModel {
        get {
            return NSManagedObjectModel(contentsOfURL: modelURL)!
        }
    }
    
    public var needsMigration: Bool {
        get {
            do {
                let sourceMetaData = try NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(nil, URL: saveURL)
                return !managedObjectModel.isConfiguration(nil, compatibleWithStoreMetadata: sourceMetaData)
            } catch {
                print("\(String(CDModel.self)) ERROR: [\(#line)] \(#function) Failure checking persistent store coordinator meta data: \(error)")
            }
            return false
        }
    }
    
    public init(name: String, bundle: NSBundle = NSBundle.mainBundle(), storeDirectoryURL: NSURL = documentsDirectoryURL()) {
        self.title = name
        self.bundle = bundle
        self.saveDirectory = storeDirectoryURL
    }
    
    public func removeExistingModelStore() -> (success: Bool, error: NSError?) {
        let fileManager = NSFileManager.defaultManager()
        
        if let storePath = saveURL.path {
            if fileManager.fileExistsAtPath(storePath) {
                do {
                    try fileManager.removeItemAtURL(saveURL)
                    return (true, nil)
                } catch {
                    return (false, error as NSError)
                }
            }
        }
        return (false, nil)
    }
    
    public var description: String {
        get {
            return "<\(String(CDModel.self)): name=\(title), needsMigration=\(needsMigration), databaseFileName=\(databaseFileName), modelURL=\(modelURL), storeURL=\(saveURL)>"
        }
    }
}

private func documentsDirectoryURL() -> NSURL {
    let url: NSURL?
    do {
        url = try NSFileManager.defaultManager().URLForDirectory(.DocumentationDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
    } catch {
        Swift.print("Error findin documents directory: \(error)")
        fatalError()
    }
    return url!
}

public func saveContext(context: NSManagedObjectContext, completion: (ContextSaveResults) -> Void) {
    if !context.hasChanges {
        completion((true, nil))
        return
    }
    
    context.performBlock { () -> Void in
        
        do {
            try context.save()
            completion((true, nil))
        } catch {
            print("Error: [\(#line)] \(#function) Could not save managed object context: \(error)")
            completion((true, error as NSError))
        }
        
        
    }
}