//
//  Service.swift
//  AllTrailsAtLunch
//
//  Created by Evelyn C Cordner on 6/2/20.
//  Copyright © 2020 EvelynCordner. All rights reserved.
//

import Foundation
import MapKit

let API_KEY = "AIzaSyDpEr8NpgU_ERTJw6tm1nmGrpUZozM-oQE"
fileprivate let SEARCH_RADIUS = 20000

func fetchRestaurants(search: String, location:CLLocationCoordinate2D, completion: @escaping ([Restaurant]?, Error?) -> Void) {
    var components = URLComponents(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json")!
    components.queryItems = [
        URLQueryItem(name: "key", value: "\(API_KEY)"),
        URLQueryItem(name: "location", value: "\(location.latitude),\(location.longitude)"),
        URLQueryItem(name: "radius", value: "\(SEARCH_RADIUS)"),
        URLQueryItem(name: "type", value: "restaurant"),
        URLQueryItem(name: "keyword", value: search)
    ]

    let request = URLRequest(url: components.url!)
    
    URLSession.shared.dataTask(with: request) { (data, response, error) in
        guard let data = data,
            let response = response as? HTTPURLResponse,
            (200 ..< 300) ~= response.statusCode,
            error == nil else {
                completion(nil, error)
                return
        }
        let restaurants = try? JSONDecoder().decode(GooglePlacesResult.self, from: data)
        completion(restaurants?.results, nil)
    }.resume()
}
