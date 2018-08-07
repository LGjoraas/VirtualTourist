//
//  Photo+Extensions.swift
//  VirtualTourist
//
//  Created by Lindsey Gjoraas on 7/29/18.
//  Copyright © 2018 Developed by Gjoraas. All rights reserved.
//


import Foundation
import CoreData

extension Photo {
    
    static let name = "Photo"
    
    convenience init(imageUrl: String, forPin: Pin, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: Photo.name, in: context) {
            self.init(entity: ent, insertInto: context)
            self.imageURL = imageUrl
            self.pin = forPin
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
