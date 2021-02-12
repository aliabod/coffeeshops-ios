//
//  urls.swift
//  CoffeeShops
//
//  Created by Ali Abod on 19/11/2019.
//  Copyright © 2019 Ali Abod. All rights reserved.
//

import Foundation

// API URLs
struct urls {
    static let getCoffeeShops = "https://dentistry.liverpool.ac.uk/_ajax/coffee/"
    static func getCoffeeShopDetails(id: String) -> String {
        return "https://dentistry.liverpool.ac.uk/_ajax/coffee/info/?id=\(id)"
    }
}

