//
//  coffeeShop.swift
//  CoffeeShops
//
//  Created by Ali Abod on 19/11/2019.
//  Copyright © 2019 Ali Abod. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

// stores array of coffee shop objects
class CoffeeShops: Decodable {
    var data: [CoffeeShop]
    init(data: [CoffeeShop]) {
        self.data = data
    }
}

// coffee shop object
class CoffeeShop: Decodable {
    
    var distance: String = ""
    let id: String
    let name: String
    let latitude: String
    let longitude: String
    var details: CoffeeShopDetails? = nil
    var location: CLLocation {
        return CLLocation(latitude: Double(latitude)!, longitude: Double(longitude)!)
    }
    // map annotation pin
    var annotation: MyAnnotation {
        return MyAnnotation(
            id: id,
            title: name,
            coordinate: CLLocationCoordinate2D(
                latitude: Double(latitude)!,
                longitude: Double(longitude)!
            )
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case latitude = "latitude"
        case longitude = "longitude"
    }

}

// coffee shop information
class CoffeeShopDetails: Decodable, Encodable {
    
    let url: String?
    let photoUrl: String?
    let phoneNumber: String?
    var openingHours: String?
    var image: UIImage?
    var openingHoursDic: [String:String]?
    
    required init(from decoder: Decoder) throws {
        let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
        let dataContainer = try valueContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        url = try dataContainer.decodeIfPresent(String.self, forKey: .url)
        photoUrl = try dataContainer.decodeIfPresent(String.self, forKey: .photoUrl)
        phoneNumber = try dataContainer.decodeIfPresent(String.self, forKey: .phoneNumber)
        openingHoursDic = try dataContainer.decodeIfPresent([String:String].self, forKey: .openingHours)
        
        // creating a string for opening hours in order
        if let openingHoursDic = openingHoursDic {
            self.openingHoursDic = openingHoursDic
            self.openingHours = ""
            openingHoursAppend(day: "monday")
            openingHoursAppend(day: "tuesday")
            openingHoursAppend(day: "wednesday")
            openingHoursAppend(day: "thursday")
            openingHoursAppend(day: "friday")
            openingHoursAppend(day: "saturday")
            openingHoursAppend(day: "sunday")

        }
    }
    
    // function that appends to opening hours string, takes key as parameter
    func openingHoursAppend(day: String) {
        self.openingHours! += day.capitalized
        self.openingHours! += ": "
        self.openingHours! += self.openingHoursDic?[day] ?? "No data available"
        self.openingHours! += "\n"
    }
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
        case url = "url"
        case photoUrl = "photo_url"
        case phoneNumber = "phone_number"
        case openingHours = "opening_hours"
    }
    
    // reencodes data, not used
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var data = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        try data.encode(url, forKey: .url)
        try data.encode(phoneNumber, forKey: .phoneNumber)
        try data.encode(photoUrl, forKey: .photoUrl)
        try data.encode(openingHoursDic, forKey: .openingHours)
    }
}

