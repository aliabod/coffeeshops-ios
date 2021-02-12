//
//  SessionHandler.swift
//  CoffeeShops
//
//  Created by Ali Abod on 19/11/2019.
//  Copyright © 2019 Ali Abod. All rights reserved.
//

import Foundation

extension URLSession {
    // function that gets and returns data from a URL/API
    func getData(url: String, completionHandler: ((_ data: Data?) -> Void)?) {
        guard let url = URL(string: url) else { return }
        let request = NSURLRequest(url: url)
        self.dataTask(with: request as URLRequest) { data, response, error in
            DispatchQueue.main.async {
                guard error == nil,
                    let data = data else {
                        completionHandler?(nil)
                        return
                }
                completionHandler?(data)
            }
        }.resume()
    }
}
