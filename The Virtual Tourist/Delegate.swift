//
//  Delegate.swift
//  The Virtual Tourist
//
//  Created by Moritz Gort on 25/03/16.
//  Copyright © 2016 Gabriele Gort. All rights reserved.
//

import Foundation

public protocol Delegate {
    func searchedForLocationImages(success: Bool, location: Location, images: [Image]?, error: String?)
}