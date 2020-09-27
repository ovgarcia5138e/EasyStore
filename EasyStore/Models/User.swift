//
//  User.swift
//  EasyStore
//
//  Created by Oscar Garcia Vazquez on 9/26/20.
//  Copyright © 2020 Oscar Garcia Vazquez. All rights reserved.
//

import Foundation

struct currentUser {
    static var user : CompleteUserResponse?
    
//    init(user : CompleteUserResponse) {
//        currentUser.user = user
//    }
}
struct completeUser : Codable {
    let firstName : String
    let lastName : String
    let picture : URL?
    let dob : String
    let gender: String
    let email : String
}

struct CompleteUserResponse : Codable {
    let user : completeUser?
    let token : String?
}

struct User{
    let firstName : String
    let lastName : String
    let dob : String
    let gender: String
    let password : String
    let email : String
    
    init(first : String, dob : String, email : String, gender : String, last : String, pw : String) {
        self.firstName = first
        self.lastName = last
        self.dob = dob
        self.gender = gender
        self.email = email
        self.password = pw
    }
}

struct successfulResponse : Codable {
    let firstName : String
    let lastName : String
    let dob : String
    let gender: String
    let email : String
    let id : String
}

struct userResponse : Codable {
    let user : successfulResponse
    let token : String
}
