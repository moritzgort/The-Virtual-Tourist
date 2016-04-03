//
//  VTMapVC.swift
//  The Virtual Tourist
//
//  Created by Moritz Gort on 24/03/16.
//  Copyright © 2016 Gabriele Gort. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import CoreData

class VTMapVC: UIViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var longPress: UILongPressGestureRecognizer!
    var currentLocation: Pin? = nil
    var currentPin : Pin? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        longPress = UILongPressGestureRecognizer(target: self, action: #selector(VTMapVC.longPress(_:)))
        self.mapView.addGestureRecognizer(longPress)
        self.mapView.delegate = self
        
        do {
            try self.fetchController.performFetch()
        } catch _ {}
        
        self.fetchController.delegate = self
        if let fetch = self.fetchController.fetchedObjects as? [Location] {
            for pin in fetch {
                let toAdd = Pin(latitude: pin.latitude as Double,  longitude: pin.longitude as Double)
                toAdd.location = pin
                self.mapView.addAnnotation(toAdd)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.currentPin = nil
    }
    
    lazy var fetchController: NSFetchedResultsController = {
        let request = NSFetchRequest(entityName: "Location")
        request.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    var sharedContext: NSManagedObjectContext {
        return CDManager.sharedInstance().stack.managedObjectContext
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject object: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case NSFetchedResultsChangeType.Insert:
            if let location: Location = object as? Location {
                let thisLocation = Pin(latitude: location.latitude as Double, longitude: location.longitude as Double)
                thisLocation.location = location
                self.mapView.removeAnnotation(thisLocation)
                self.mapView.addAnnotation(thisLocation)
            }
            break
        case NSFetchedResultsChangeType.Delete:
            if let location: Location = object as? Location {
                for annotation in self.mapView.annotations {
                    if let pin: Pin = annotation as? Pin {
                        if pin.coordinate.latitude == location.latitude && pin.coordinate.longitude == location.longitude {
                            self.mapView.removeAnnotation(pin)
                        }
                    }
                }
            }
            break
        default:
            break
        }
    }
    
    func locationDetailer() {
        dispatch_async(dispatch_get_main_queue()) {
            let coordinate = self.currentLocation!.coordinate
            let location = Location(latitude: coordinate.latitude, longitude: coordinate.longitude, context: self.sharedContext)
            CDManager.sharedInstance().save()
            self.currentLocation!.location = location
            FlickrImageDelegate.sharedInstance().searchImages(location)
            let cCoordinate = self.currentLocation!.coordinate
            let cLocation = CLLocation(latitude: cCoordinate.latitude, longitude: cCoordinate.longitude)
            CLGeocoder().reverseGeocodeLocation(cLocation) {placemarks, error in
                if error != nil {
                    print(error)
                    return
                }
                
                if placemarks!.count > 0 {
                    let place = placemarks![0]
                    
                    if place.locality != nil {
                        dispatch_async(dispatch_get_main_queue()) {
                            _ = LocationDetail(location: location, locationName: place.locality!, context: self.sharedContext)
                            CDManager.sharedInstance().save()
                        }
                    }
                }
            }
            self.currentLocation = nil
        }
    }
    
    func setPin(recognizer: UIGestureRecognizer) {
        let selection = recognizer.locationInView(self.mapView)
        let selectionCoordinate = self.mapView.convertPoint(selection, toCoordinateFromView: self.mapView)
        self.currentLocation = Pin(latitude: selectionCoordinate.latitude, longitude: selectionCoordinate.longitude)
        self.mapView.addAnnotation(self.currentLocation!)
    }
    
    func longPress(recognizer: UIGestureRecognizer) {
        if (recognizer.state == UIGestureRecognizerState.Ended) {
            self.locationDetailer()
            return
        } else if (recognizer.state == UIGestureRecognizerState.Changed) {
            self.changeLocation(recognizer)
        } else {
            self.setPin(recognizer)
        }
    }
    
    func changeLocation(recognizer: UIGestureRecognizer) {
        self.mapView.removeAnnotation(self.currentLocation!)
        self.currentLocation?.coordinate = self.mapView.convertPoint(recognizer.locationInView(self.mapView), toCoordinateFromView: self.mapView)
        self.mapView.addAnnotation(self.currentLocation!)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToGallery" {
            if let vc = segue.destinationViewController as? VTGalleryVC {
                vc.pin = self.currentPin
            }
        }
    }
}
