//
//  Client.swift
//  The Virtual Tourist
//
//  Created by Moritz Gort on 25/03/16.
//  Copyright © 2016 Gabriele Gort. All rights reserved.
//

import Foundation
import CoreData

let FLICKR_API_KEY = "956b137ef192dfd744341614baff2f5f"

public class Client: NSObject, OnlineProtocol {
    var onlineClient: OnlineClient?
    
    override init() {
        super.init()
        self.onlineClient = OnlineClient(delegate: self)
    }
    
    public func getURL() -> String {
        return Client.Constants.BASE_URL
    }
    
    public func addRequest(request: NSMutableURLRequest) {
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    
    public func getJSON(jsonBody: [String: AnyObject]) -> [String: AnyObject] {
        return jsonBody
    }
    
    public func getResponse(data: NSData) -> NSData {
        return data
    }
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CDManager.sharedInstance().stack.managedObjContext(NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
    }()

    public class func sharedInstance() -> Client {
        struct ClientStruct {
            static var sharedInstance = Client()
        }
        
        return ClientStruct.sharedInstance
    }
}