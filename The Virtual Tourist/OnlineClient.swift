//
//  OnlineClient.swift
//  The Virtual Tourist
//
//  Created by Moritz Gort on 26/03/16.
//  Copyright © 2016 Gabriele Gort. All rights reserved.
//

import Foundation

let DEBUG = false

public class OnlineClient: NSObject {
    struct Constants {
        static let DateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
    }
    
    var session: NSURLSession
    var delegate: OnlineProtocol!

    override init() {
        session = NSURLSession.sharedSession()
    }
    
    convenience init(delegate: OnlineProtocol) {
        self.init()
        self.delegate = delegate
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("Error")
    }
    
    class func errorResponse(data:  NSData?, response: NSURLResponse?, error: NSError?) -> NSError {
        if let result = try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as? [String: AnyObject] {
            if let error = result!["error"] as? String {
                return NSError(domain: "Error", code: 1, userInfo: [NSLocalizedDescriptionKey: error])
            }
        }
        return error!
    }
    
    class func getParams(params: [String:AnyObject]) -> String {
        var url = [String]()
        for (key, value) in params {
            let str = "\(value)"
            let par = str.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            url += [key + "=" + "\(par!)"]
        }
        return (!url.isEmpty ? "?" : "") + url.joinWithSeparator("&")
    }
    
    class func delieverJSON(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        let result: AnyObject?
        do {
            result = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch {
            result = nil
        }
        if result != nil {
            completionHandler(result: result, error: nil)
        } else {
            let error: NSError = NSError(domain: "Error", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error"])
            completionHandler(result: nil, error: error)
        }
    }
    
    func taskMethod(link: String, method: String, params: [String: AnyObject], json: [String: AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        let thisJSON = self.delegate.getJSON(json)
        let request = NSMutableURLRequest(URL: NSURL(string: self.delegate.getURL() + method + OnlineClient.getParams(params))!)
        self.delegate.addRequest(request)
        request.HTTPMethod = link
        var error: NSError? = nil
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(thisJSON, options: [])
        } catch let thisError as NSError{
            error = thisError
            request.HTTPBody = nil
        }
        
        if (DEBUG && error == nil) {
            print(NSString(data: request.HTTPBody!, encoding: NSUTF8StringEncoding))
        }
        
        let task = session.dataTaskWithRequest(request) { data, response, fetchError in let new = self.delegate.getResponse(data!)
            if (DEBUG) {
                print(NSString(data: new, encoding: NSUTF8StringEncoding))
            }
            if let thisError = fetchError {
                let newErr = OnlineClient.errorResponse(new, response: response, error: thisError)
                completionHandler(result: nil, error: newErr)
            } else {
                OnlineClient.delieverJSON(new, completionHandler: completionHandler)
            }
        }
        task.resume()
        return task
    }
    
    //MARK: Task For...
    func taskForPOSTMethod(method: String, params: [String: AnyObject], json: [String: AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        return taskMethod("POST", method: method, params: params, json: json, completionHandler: completionHandler)
    }
    
    func taskForPUTMethod(method: String, params: [String: AnyObject], json: [String: AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        return taskMethod("PUT", method: method, params: params, json: json, completionHandler: completionHandler)
    }
    
    func taskForGETMethod(method: String, params: [String: AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: NSURL(string: self.delegate.getURL() + method + OnlineClient.getParams(params))!)
        self.delegate.addRequest(request)
        let task = session.dataTaskWithRequest(request) {data, response, error in let new = self.delegate.getResponse(data!)
            if let newErr = error {
                completionHandler(result: nil, error: (OnlineClient.errorResponse(new, response: response, error: newErr)))
            } else {
                OnlineClient.delieverJSON(new, completionHandler: completionHandler)
            }
        }
        task.resume()
        return task
    }
}