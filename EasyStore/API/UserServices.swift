//
//  UserServices.swift
//  EasyStore
//
//  Created by Oscar Garcia Vazquez on 9/26/20.
//  Copyright © 2020 Oscar Garcia Vazquez. All rights reserved.
//

import Foundation
import UIKit

struct UserService {
    static let shared = UserService()
    
    func loginUser(email : String, password : String, completion : @escaping(Bool) -> Void) {
        let url = "http://05f6aa9b0394.ngrok.io/auth/login"
        
        let userCredentials = ["email" : email, "password" : password]
        let jsonData = try? JSONSerialization.data(withJSONObject: userCredentials)
        
        if let url = URL(string: url) {
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "content-type")
            request.httpMethod = "POST"
            request.httpBody = jsonData
            
            let session = URLSession(configuration: .default,
                                     delegate: nil,
                                     delegateQueue: nil)
            let task = session.dataTask(with: request) {
                (data, response, error) in
                
                DispatchQueue.main.async {
                    if error != nil {
                        return
                    }
                    do {
                        if let data = data {
                            let decoder = JSONDecoder()
                            let user = try decoder.decode(CompleteUserResponse.self, from: data)
                            currentUser.user = user
                            completion(user.user == nil ? false : true)
                        }
                    } catch let err {
                        print(err)
                    }
                }
            }
            task.resume()
        }
    }
    
    func registerUser(user : User, completion : @escaping(userResponse) -> Void) {
        let json : [String : String] = ["firstName" : user.firstName,
                                        "lastName" : user.lastName,
                                        "dob" : user.dob,
                                        "gender" : user.gender,
                                        "email" : user.email,
                                        "password" : user.password]

        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        let url = URL(string: "http://05f6aa9b0394.ngrok.io/auth/register")!
        var request = URLRequest(url: url)
        
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.httpMethod = "POST"
        request.httpBody = jsonData!
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let please = try decoder.decode(userResponse.self, from: data)
                    completion(please)
                } catch let err {
                    print(err)
                }
            }
            
        }
        task.resume()
    }
    
    func uploadProfileImage(token : String, image : UIImage) {
        let url = URL(string: "http://05f6aa9b0394.ngrok.io/auth/image")!
        var request = URLRequest(url: url)
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "authorization")
        request.addValue("application/octet-stream", forHTTPHeaderField: "content-type")
        
        request.httpMethod = "POST"
        request.httpBody = image.jpegData(compressionQuality: 1)
        
        let taske = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            DispatchQueue.main.async {
                if error != nil {
                    return
                }
                
                do {
                    
                }
            }
        }
        taske.resume()
        
    }
}
