//
//  SpaceServices.swift
//  EasyStore
//
//  Created by Oscar Garcia Vazquez on 9/26/20.
//  Copyright © 2020 Oscar Garcia Vazquez. All rights reserved.
//

import Foundation


struct SpaceServices {
    static let shared = SpaceServices()
    
    func uploadSpace(token : String, space : storageSpace) {
        
        let spaceJSON : [String : Any] = ["address" : space.address,
                                          "maxRenters" : space.maxRenters,
                                          "type" : space.LocationType,
                                          "width" : space.width,
                                          "height" : space.height,
                                          "length" : space.length,
                                          "dailyRate" : space.dailyRate]
        let jsonData = try? JSONSerialization.data(withJSONObject: spaceJSON)
        
        let url = "http://05f6aa9b0394.ngrok.io/rentals/properties"
        
        if let url = URL(string: url) {
            var request = URLRequest(url: url)
            
            request.addValue("Bearer \(token)", forHTTPHeaderField: "authorization")
            request.addValue("application/json", forHTTPHeaderField: "content-type")
            request.httpMethod = "POST"
            request.httpBody = jsonData
            
            let session = URLSession(configuration: .default,
                                     delegate: nil,
                                     delegateQueue: nil)
            
            let task = session.dataTask(with: request) { (data, response, error) in
                DispatchQueue.main.async {
                    if error != nil {
                        return
                    }
                    
                    do {
                        if let data = data {
                            let decoder = JSONDecoder()
                            let answer = try decoder.decode(storageResponse.self, from: data)
                            print(answer)
                        }
                        
                    } catch let err {
                        print(err)
                    }
                }
                
            }
            task.resume()
        }
    }
    
    func getSpaces(token : String, lat : String, long : String, completion: @escaping(locations) -> Void) {
        let url = "http://05f6aa9b0394.ngrok.io/rentals/search?location=\(lat),\(long)"
        
        if let url = URL(string: url) {
            let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
            var request = URLRequest(url: url)
            
            request.addValue("Bearer \(token)", forHTTPHeaderField: "authorization")
            request.httpMethod = "GET"
            
            let task = session.dataTask(with: request) { (data, response, error) in
                
                DispatchQueue.main.async {
                    if error != nil {
                        return
                    }
                    
                    do {
                        if let data = data {
                            let decoder = JSONDecoder()
                            let location = try decoder.decode(locations.self, from: data)
                            
                            for lco in location.locations {
                                print("\(lco.latitude) \(lco.longitude)")
                            }
                            completion(location)
                        }
                    } catch let err {
                        print(err)
                    }
                }
            }
            task.resume()
        }
    }
}
