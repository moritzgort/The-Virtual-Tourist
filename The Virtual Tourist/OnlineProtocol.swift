//
//  OnlineProtocol.swift
//  The Virtual Tourist
//
//  Created by Moritz Gort on 28/03/16.
//  Copyright © 2016 Gabriele Gort. All rights reserved.
//

import Foundation

public protocol OnlineProtocol {
    func getURL() -> String
    func addRequest(request: NSMutableURLRequest)
    func getJSON(json: [String:AnyObject]) -> [String:AnyObject]
    func getResponse(data: NSData) -> NSData
}