//
//  FlickrImageDelegate.swift
//  The Virtual Tourist
//
//  Created by Moritz Gort on 24/03/16.
//  Copyright © 2016 Gabriele Gort. All rights reserved.
//

import Foundation

public class FlickrImageDelegate: Delegate {
    class func sharedInstance() -> FlickrImageDelegate {
        struct Static {
            static let instance = FlickrImageDelegate()
        }
        return Static.instance
    }
    
    var loading: Set<Location> = Set()
    var flickrDelegates:[Location: Delegate] = [Location:Delegate]()
    
    public func searchedForLocationImages(success: Bool, location: Location, images: [Image]?, error: String?) {
        self.loading.remove(location)
        if let flickrDelegate = flickrDelegates[location] {
            flickrDelegate.searchedForLocationImages(success, location: location, images: images, error: error)
        }
        self.flickrDelegates.removeValueForKey(location)
    }
    
    public func searchImages(location: Location) {
        self.loading.insert(location)
        Client.sharedInstance().getPhotosFromFlickrSearch(location, delegate: self)
    }
    
    //MARK: optional?
    public func loading(location: Location) -> Bool {
        return self.loading.contains(location)
    }
    
    public func addDelegate(location: Location, delegate: Delegate) {
        flickrDelegates[location] = delegate
    }
}