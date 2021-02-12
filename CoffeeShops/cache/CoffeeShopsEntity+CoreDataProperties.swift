//
//  CoffeeShopsEntity+CoreDataProperties.swift
//  CoffeeShops
//
//  Created by Ali Abod on 30/11/2019.
//  Copyright © 2019 Ali Abod. All rights reserved.
//
//

import Foundation
import CoreData

// core data entity that stores array of CoffeeShop objects
extension CoffeeShopsEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoffeeShopsEntity> {
        return NSFetchRequest<CoffeeShopsEntity>(entityName: "CoffeeShopsEntity")
    }

    @NSManaged public var coffeeShopArrayAttribute: Data
    
}
