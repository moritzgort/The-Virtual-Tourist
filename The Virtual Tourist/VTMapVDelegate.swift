//
//  VTMapVDelegate.swift
//  The Virtual Tourist
//
//  Created by Moritz Gort on 24/03/16.
//  Copyright © 2016 Gabriele Gort. All rights reserved.
//

import Foundation
import MapKit
import UIKit

extension VTMapVC: MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let pin = annotation as? Pin {
            let reuse = "pin"
            var view: MKPinAnnotationView
            if let finishedView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuse) as? MKPinAnnotationView {
                finishedView.annotation = pin
                view = finishedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuse)
            }
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        self.currentPin = view.annotation as? Pin
        self.performSegueWithIdentifier("goToGallery", sender: self)
    }
}