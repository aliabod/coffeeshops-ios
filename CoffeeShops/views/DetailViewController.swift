//
//  DetailViewController.swift
//  CoffeeShops
//
//  ALI ABOD - 201267800
//
//  Created by Ali Abod on 24/11/2019.
//  Copyright © 2019 Ali Abod. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var coffeeShop: CoffeeShop!
    
    // phone button action on detail page
    @IBAction func phoneButton(_ sender: Any) {
        guard let phoneNumber = coffeeShop.details?.phoneNumber
            else { return }
            let noSpacePhoneNumber = phoneNumber.replacingOccurrences(of: " ", with: "")
            let url: NSURL = URL(string: "TEL://\(noSpacePhoneNumber)")! as NSURL
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    
    // web button action on detail page
    @IBAction func webButton(_ sender: Any) {
        guard let urlString = coffeeShop.details?.url,
            let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var webButton: UIButton!
    @IBOutlet weak var openingHoursTextView: UITextView!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = coffeeShop.name
        phoneButton.isEnabled = coffeeShop.details?.phoneNumber != nil
        webButton.isEnabled = coffeeShop.details?.url != nil
        
        // get and set coffeeshop image
        if let coffeeshopImage = coffeeShop.details?.image {
            imageView.image = coffeeshopImage
        } else if let photoUrl = coffeeShop.details?.photoUrl {
            URLSession.shared.getData(url: photoUrl) { data in
                guard let data = data,
                    let image = UIImage(data: data)
                    else { return }
                self.coffeeShop.details?.image = image
                self.imageView.image = image
            }
        }
        // set opening hours textview text
        openingHoursTextView.text = coffeeShop.details?.openingHours
        phoneNumberLabel.text = (coffeeShop.details?.phoneNumber) ?? ""


    }
    
}
