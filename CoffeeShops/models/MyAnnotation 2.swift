//
//  MyAnnotation.swift
//  CoffeeShops
//
//  Created by Ali Abod on 23/11/2019.
//  Copyright © 2019 Ali Abod. All rights reserved.
//

import Foundation
import MapKit

// annotation class containing details required for individual annotations
class MyAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let id: String
    var title: String?
    
    init(id: String, title: String, coordinate: CLLocationCoordinate2D) {
        self.id = id
        self.title = title
        self.coordinate = coordinate
        super.init()
    }
}
