//
//  Convenience.swift
//  The Virtual Tourist
//
//  Created by Moritz Gort on 25/03/16.
//  Copyright © 2016 Gabriele Gort. All rights reserved.
//

import Foundation
import CoreData

let MAX_PHOTOS = 39

extension Client {
    
    public func getPhotosFromFlickrSearch(pin:Location, delegate:Delegate?) {
        self.flickrImages(pin) { success, result, errorString in
            print("Flickr search done")
            if success {
                print("search successful")
                let imgs = [Image]()
                var urls:[NSURL] = [NSURL]()
                for nextPhoto in result! {
                    if urls.count >= MAX_PHOTOS {
                        break
                    }
                    let imgUrlStr = nextPhoto["url_m"] as? String
                    
                    if let imgURL = NSURL(string: imgUrlStr!) {
                        urls.append(imgURL)
                    }
                }
                
                if let pinLocation = self.sharedContext.objectWithID(pin.objectID) as? Location {
                    _ = urls.map({ Image(location: pinLocation, imageURL: $0, context: self.sharedContext)})
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Client.mergeChanges(_:)), name: NSManagedObjectContextDidSaveNotification, object: self.sharedContext)
                    saveContext(self.sharedContext) { success in
                        dispatch_async(dispatch_get_main_queue()) {
                            delegate?.searchedForLocationImages(true, location: pin, images: imgs, error: nil)
                        }
                    }
                }
                
            } else {
                delegate?.searchedForLocationImages(false, location: pin, images: nil, error: errorString)
            }
        }
    }
    
    public func mergeChanges(notification: NSNotification) {
        let mainContext: NSManagedObjectContext = CDManager.sharedInstance().stack.managedObjectContext
        dispatch_async(dispatch_get_main_queue()) {
            mainContext.mergeChangesFromContextDidSaveNotification(notification)
            CDManager.sharedInstance().save()
        }
    }
    
    private func boundingBox(pin: Location) -> String {
        let latitude = pin.latitude as Double
        let longitude = pin.longitude as Double
        
        let bllon = max(longitude - Client.Constants.BOUNDING_BOX_HALF_WIDTH, Client.Constants.LON_MIN)
        let bllat = max(latitude - Client.Constants.BOUNDING_BOX_HALF_HEIGHT, Client.Constants.LAT_MIN)
        let trlon = min(longitude + Client.Constants.BOUNDING_BOX_HALF_HEIGHT, Client.Constants.LON_MAX)
        let trlat = min(latitude + Client.Constants.BOUNDING_BOX_HALF_HEIGHT, Client.Constants.LAT_MAX)
        
        return "\(bllon), \(bllat), \(trlon), \(trlat)"
    }
    
    public func flickrImages(pin: Location, completionHandler:(success: Bool, result: [[String: AnyObject]]?, errorString: String?) -> Void) {
        let parameters = [
            Client.ParameterKeys.METHOD : Client.Methods.SEARCH,
            Client.ParameterKeys.API_KEY : FLICKR_API_KEY,
            Client.ParameterKeys.BBOX : self.boundingBox(pin),
            Client.ParameterKeys.SAFE_SEARCH : Client.Constants.SAFE_SEARCH,
            Client.ParameterKeys.EXTRAS : Client.Constants.EXTRAS,
            Client.ParameterKeys.FORMAT : Client.Constants.DATA_FORMAT,
            Client.ParameterKeys.NO_JSON_CALLBACK : Client.Constants.NO_JSON_CALLBACK
        ]
        self.onlineClient?.taskForGETMethod("", params: parameters) { JSONResult, error in if let _ = error {
            completionHandler(success: false, result: nil, errorString: "Can not find photos for location")
        } else {
            if let photosDictionary = JSONResult.valueForKey("photos") as? [String: AnyObject] {
                if let totalPages = photosDictionary["pages"] as? Int {
                    let randomNumber = Int(arc4random_uniform(UInt32(min(totalPages, 40)))) + 1
                    self.getFlickrImgs(parameters, number: randomNumber, completionHandler: completionHandler)
                } else {
                    completionHandler(success: false, result: nil, errorString: "No pages")
                }
            } else {
                completionHandler(success: false, result: nil, errorString: "No pages")
            }
            }
        }
    }
    
    private func getFlickrImgs(methodArguments: [String: AnyObject], number: Int, completionHandler: (success: Bool, result: [[String: AnyObject]]?, errorString: String?) -> Void) {
        var pageDictionary = methodArguments
        pageDictionary["page"] = number
        self.onlineClient?.taskForGETMethod("", params: pageDictionary) {JSONResult, error in if let _ = error {
            completionHandler(success: false, result: nil, errorString: "No photos")
        } else {
            if let photosDictionary = JSONResult.valueForKey("photos") as? [String:AnyObject] {
                var totalPhotosVal = 0
                if let totalPhotos = photosDictionary["total"] as? String {
                    totalPhotosVal = (totalPhotos as NSString).integerValue
                }
                
                if totalPhotosVal > 0 {
                    if let photosArray = photosDictionary["photo"] as? [[String: AnyObject]] {
                        if photosArray.count > 0 {
                            completionHandler(success: true, result: photosArray, errorString: nil)
                        } else {
                            completionHandler(success: false, result: nil, errorString: "Error")
                        }
                    } else {
                        completionHandler(success: false, result: nil, errorString: "Error")
                    }
                } else {
                    completionHandler(success: false, result: nil, errorString: "Error")
                }
            } else {
                completionHandler(success: false, result: nil, errorString: "Error")
            }
            }
        }
    }
}