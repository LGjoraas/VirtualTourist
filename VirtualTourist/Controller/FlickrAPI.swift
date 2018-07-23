//
//  FlickrAPI.swift
//  VirtualTourist
//
//  Created by Ryan Gjoraas on 7/23/18.
//  Copyright © 2018 Developed by Gjoraas. All rights reserved.
//

import Foundation


extension TravelLocationsMapVC {
    
// MARK: Flickr API

private func displayImageFromFlickrBySearch(_ methodParameters: [String: AnyObject]) {
    
    print(flickrURLFromParameters(methodParameters))
    
    // TODO: Make request to Flickr!
}

// MARK: Helper for Creating a URL from Parameters

private func flickrURLFromParameters(_ parameters: [String: AnyObject]) -> URL {
    
    var components = URLComponents()
    components.scheme = Constants.Flickr.APIScheme
    components.host = Constants.Flickr.APIHost
    components.path = Constants.Flickr.APIPath
    components.queryItems = [URLQueryItem]()
    
    for (key, value) in parameters {
        let queryItem = URLQueryItem(name: key, value: "\(value)")
        components.queryItems!.append(queryItem)
    }
    
    return components.url!
}
    
}
