//
//  Pin.swift
//  The Virtual Tourist
//
//  Created by Moritz Gort on 24/03/16.
//  Copyright © 2016 Gabriele Gort. All rights reserved.
//

import Foundation
import MapKit

public class Pin: NSObject, MKAnnotation {
    public var title: String?
    public var subtitle: String?
    public var coordinate: CLLocationCoordinate2D
    public var location: Location?
    
    init(latitude: Double, longitude: Double) {
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        super.init()
    }
}