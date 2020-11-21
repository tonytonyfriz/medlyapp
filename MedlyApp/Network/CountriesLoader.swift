//
//  CountriesLoader.swift
//  MedlyApp
//
//  Created by Anthony Frizalone on 11/19/20.
//

import Foundation

extension String {
    func countryCodeIconURL() -> String {
        CountriesLoader.countryIconURL.replacingOccurrences(of: "[CODE]", with: self)
    }
}

class CountriesLoader {
    
    static let countriesURLPath = "CountriesURL"
    static let countryImageURLPath = "CountryIconURL"
    
    static var countriesURL: String {
        guard let filePath = Bundle.main.url(forResource: "URLs", withExtension: "plist") else { return "" }
        let data = try! Data(contentsOf: filePath)
        guard let plist = try! PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String:String] else { return "" }
        
        if let baseUrl = plist[countriesURLPath] {
            return baseUrl
        }
        
        return ""
    }
    
    static var countryIconURL: String {
        guard let filePath = Bundle.main.url(forResource: "URLs", withExtension: "plist") else { return "" }
        let data = try! Data(contentsOf: filePath)
        guard let plist = try! PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String:String] else { return "" }
        
        if let baseUrl = plist[countryImageURLPath] {
            return baseUrl
        }
        
        return ""
    }
    
    class func getCountries(success:@escaping (_ movies: [Country]) -> Void, failure:@escaping (_ error: Error?) -> Void){
        let url = CountriesLoader.countriesURL
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: URL(string: url)!), completionHandler: {(data, response, error) in
            if let error = error {
                failure(error)
                return
            }
            
            guard let unwrappedData = data else {
                print("data wasn't loaded")
                failure(nil)
                return
            }
            do {
                let loadedCountries = try JSONDecoder().decode([Country].self, from: unwrappedData)
                success(loadedCountries)
            } catch {
                print("failed to deal with json")
                failure(nil)
            }
        })
        task.resume()
    }
    
}
