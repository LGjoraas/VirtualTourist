//
//  Pin+Extensions.swift
//  VirtualTourist
//
//  Created by Ryan Gjoraas on 7/29/18.
//  Copyright © 2018 Developed by Gjoraas. All rights reserved.
//


import Foundation
import CoreData

extension Pin {
    
    static let name = "Pin"
    
    convenience init(latitude: String, longitude: String, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: Pin.name, in: context) {
            self.init(entity: ent, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
