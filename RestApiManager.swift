//
//  RestApiManager.swift
//  FCApp
//
//  Created by Cong Can NGO on 5/21/16.
//  Copyright © 2016 vns. All rights reserved.
//

import UIKit
import SwiftyJSON

typealias ServiceResponse = (jsonData : JSON?, error: NSError?) -> Void

class RestApiManager: NSObject {

    static let sharedInstance = RestApiManager()
        
    func makeHTTPGetRequest(path: String, params: [String: AnyObject]?,  onCompletion: ServiceResponse) {
        
        
        let urlComponents = NSURLComponents(string: path)!
        
        var queryItems = Array<NSURLQueryItem>()
        
        if let requiredParams  =  params {
            for (key,value) in requiredParams {
                queryItems.append(NSURLQueryItem(name: key, value: value as? String))
                
                print("\(key) = \(value)")
            }
        }
      
        urlComponents.queryItems = queryItems
        let URL = urlComponents.URL
        
        print("URL  = \(URL)")

        
//        let URL = NSURL(string: path.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!
        let request = NSMutableURLRequest(URL:URL!)
        
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if(error == nil && data != nil){
                if let json:JSON = JSON(data: data!){
                    
                    onCompletion(jsonData: json, error: error)
                    
                    print("\n jsonData:\n\(json)")

                    return
                }
                

            }

            onCompletion(jsonData: nil, error: error)
        })
        task.resume()
    }
    
    func makeHTTPPostRequest(path: String, body: [String: AnyObject], onCompletion: ServiceResponse) {
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)

        // Set the method to POST
        request.HTTPMethod = "POST"
        
        // Set the POST body for the request
//       request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(body, options: [])

//        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(body, options: nil, error: &err)
        let bodyData = body.stringFromHttpParameters()
        print("bodyData -> \(bodyData)")
        
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
            if(error == nil && data != nil){
                let json:JSON = JSON(data: data!)
                print("\n jsonData:\n\(json)")
                onCompletion(jsonData: json, error: error)

            } else {
                onCompletion(jsonData: nil, error: error)
            }
        })
        task.resume()
    }
    
}

extension String {
    
    /// Percent escapes values to be added to a URL query as specified in RFC 3986
    ///
    /// This percent-escapes all characters besides the alphanumeric character set and "-", ".", "_", and "~".
    ///
    /// http://www.ietf.org/rfc/rfc3986.txt
    ///
    /// :returns: Returns percent-escaped string.
    
    func stringByAddingPercentEncodingForURLQueryValue() -> String? {
        let allowedCharacters = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        
        return self.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacters)
    }
    
}



extension Dictionary {
    
    /// Build string representation of HTTP parameter dictionary of keys and objects
    ///
    /// This percent escapes in compliance with RFC 3986
    ///
    /// http://www.ietf.org/rfc/rfc3986.txt
    ///
    /// :returns: String representation in the form of key1=value1&key2=value2 where the keys and values are percent escaped
    
    func stringFromHttpParameters() -> String {
        let parameterArray = self.map { (key, value) -> String in
            let percentEscapedKey = (key as! String).stringByAddingPercentEncodingForURLQueryValue()!
            let percentEscapedValue = (value as! String).stringByAddingPercentEncodingForURLQueryValue()!
            return "\(percentEscapedKey)=\(percentEscapedValue)"
        }
        
        return parameterArray.joinWithSeparator("&")
    }
    
}

