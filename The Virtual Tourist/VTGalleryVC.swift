//
//  VTGalleryVC.swift
//  The Virtual Tourist
//
//  Created by Moritz Gort on 24/03/16.
//  Copyright © 2016 Gabriele Gort. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import CoreData

class VTGalleryVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate, Delegate, FinishedDownloadDelegate {

    @IBOutlet weak var newImageSetButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var pin: Pin!
    
    var selectedImages = [NSIndexPath]()
    var insertImages: [NSIndexPath]!
    var deleteImages: [NSIndexPath]!
    var updateImages: [NSIndexPath]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if FlickrImageDelegate.sharedInstance().loading(pin.location!) {
            FlickrImageDelegate.sharedInstance().addDelegate(pin.location!, delegate: self)
        } else {
            self.fetch()
            if self.pin.location!.isLoading() {
                for next in pin.location!.myImages {
                    if let downloader = ImageDownload.sharedInstance().downloading[next.description.hashValue] as? ImageLoader {
                        downloader.finishedDownloadDelegate.append(self)
                    }
                }
            }
        }
        
        if let details = self.pin.location!.details {
            self.navigationItem.title = details.locationName
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotation(self.pin)
        self.navigationItem.backBarButtonItem?.title = "Back"
        let coordinateRegion: MKCoordinateRegion = MKCoordinateRegion(center: self.pin.coordinate, span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0))
        self.mapView.setRegion(coordinateRegion, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let collectionLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionLayout.minimumLineSpacing = 0
        collectionLayout.minimumInteritemSpacing = 0
        let length = floor(self.collectionView.frame.size.width/3)
        collectionLayout.itemSize = CGSize(width: length, height: length)
        
        collectionView.collectionViewLayout = collectionLayout
    }
    
    @IBAction func newImageSetButonPressed(sender: UIBarButtonItem) {
        for myImage in self.pin.location!.myImages {
            myImage.location = nil
            myImage.ownImage = nil
            self.sharedContext.deleteObject(myImage)
        }
        self.imagesForLocation()
        CDManager.sharedInstance().save()
    }
    
    func imagesForLocation() {
        FlickrImageDelegate.sharedInstance().searchImages(self.pin.location!)
        self.view.layoutIfNeeded()
        FlickrImageDelegate.sharedInstance().addDelegate(pin.location!, delegate: self)
    }
    
    func setupCell(cell: PhotoCVCell, indexPath: NSIndexPath) {
        cell.downloadedPhoto = self.fetchResultsC.objectAtIndexPath(indexPath) as! Image
        cell.imageCell.image = ((self.fetchResultsC.objectAtIndexPath(indexPath) as! Image).ownImage)
//        print("path: \(cell.downloadedPhoto.imagePath), img: \(cell.downloadedPhoto.ownImage)")
//        cell.downloadedPhoto.ownImage = self.fetchResultsC.objectAtIndexPath(indexPath).ownImage
//        print("path: \(cell.downloadedPhoto.imagePath), img: \(cell.downloadedPhoto.ownImage)")
//        print(cell.downloadedPhoto)
    }
    
    lazy var fetchResultsC: NSFetchedResultsController = {
        let request = NSFetchRequest(entityName: "Image")
        request.sortDescriptors = [NSSortDescriptor(key: "imagePath", ascending: true)]
        request.predicate = NSPredicate(format: "location == %@", self.pin.location!)
        
        let fetchController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: "images")
        fetchController.delegate = self
        return fetchController
    }()
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CDManager.sharedInstance().stack.managedObjectContext
    }()
    
    func fetch() {
        var error: NSError?
        NSFetchedResultsController.deleteCacheWithName("images")
        do {
            try self.fetchResultsC.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        if let _ = error {
            print(error)
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchResultsC.sections?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let info = self.fetchResultsC.sections![section]
        if let photos = self.pin!.location?.myImages where photos.count == 0 && self.isViewLoaded() && self.view.window != nil && self.newImageSetButton.enabled && !FlickrImageDelegate.sharedInstance().loading(pin.location!) {
            dispatch_async(dispatch_get_main_queue()) {
                self.imagesForLocation()
            }
        }
        return info.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let imageCell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! PhotoCVCell
        //imageCell.imageCell.image = UIImage(named: "Cabin.png")
        self.setupCell(imageCell, indexPath: indexPath)
        return imageCell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let imageCell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCVCell
        if let index = selectedImages.indexOf(indexPath) {
            selectedImages.removeAtIndex(index)
        } else {
            selectedImages.append(indexPath)
        }
        self.setupCell(imageCell, indexPath: indexPath)
        imageCell.imageCell.image = (self.fetchResultsC.objectAtIndexPath(indexPath) as! Image).ownImage
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        insertImages = [NSIndexPath]()
        deleteImages = [NSIndexPath]()
        updateImages = [NSIndexPath]()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            self.insertImages.append(newIndexPath!)
            break
        case .Delete:
            self.deleteImages.append(indexPath!)
            break
        case .Update:
            self.updateImages.append(indexPath!)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        if self.insertImages.count > 0 {
            self.collectionView.insertItemsAtIndexPaths(self.insertImages)
        }
        if self.deleteImages.count > 0 {
            self.collectionView.deleteItemsAtIndexPaths(self.deleteImages)
        }
        if self.updateImages.count > 0 {
            self.collectionView.reloadItemsAtIndexPaths(self.updateImages)
        }
    }
    
    func searchedForLocationImages(success: Bool, location: Location, images: [Image]?, error: String?) {
        for next in pin.location!.myImages {
            if let downloader = ImageDownload.sharedInstance().downloading[next.description.hashValue] as? ImageLoader {
                downloader.finishedDownloadDelegate.append(self)
            }
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.fetch()
            self.collectionView.reloadData()
            self.collectionView.layoutIfNeeded()
            self.view.layoutIfNeeded()
        }
    }
    
    func finishedLoad() {}
}
