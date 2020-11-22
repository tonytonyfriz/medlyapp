//
//  Country.swift
//  MedlyApp
//
//  Created by Anthony Frizalone on 11/19/20.
//

import Foundation

class Country : Decodable {
    
    var name: String?
    var alpha2Code: String?
    var capital: String?
    
    init(someName: String, someCode: String, someCapital: String){
        name = someName
        alpha2Code = someCode
        capital = someCapital
    }
    
}
