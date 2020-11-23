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
    var population: Int?
    
    init(someName: String, someCode: String, someCapital: String, somePopulation: Int){
        name = someName
        alpha2Code = someCode
        capital = someCapital
        population = somePopulation
    }
    
}
