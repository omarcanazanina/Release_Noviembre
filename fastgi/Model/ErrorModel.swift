//
//  ErrorModel.swift
//  fastgi
//
//  Created by Hegaro on 04/11/2020.
//

import Foundation

struct ErrorR : Codable {
    var name : String
    var message: String
}

//error de token recarga
struct ErrorRecarga : Codable{
    var name: String
    var message: String
}

//error de token UpadteUser
struct ErrorUpdateUser : Codable{
    var name: String
    var message: String
}
