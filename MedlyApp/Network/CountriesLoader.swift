//
//  CountriesLoader.swift
//  MedlyApp
//
//  Created by Anthony Frizalone on 11/19/20.
//

import Foundation

class CountriesLoader {
    
    static var countriesURLPath = "CountriesURL"
    static var countryImageURLPath = "CountryIconURL"
    
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
    
    class func getCountryImageURL(code: String) -> String {
        return CountriesLoader.countryIconURL.replacingOccurrences(of: "[CODE]", with: code)
    }
    
    class func getCountries(success:@escaping (_ movies: [Country]) -> Void, failure:@escaping (_ error: Error?) -> Void){
        let url = CountriesLoader.countriesURL
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: URL(string: url)!), completionHandler: {(data, response, error) in
            if let error = error {
                failure(error)
                return;
            }
            
            guard let unwrappedData = data else {
                print("data wasn't loaded")
                return;
            }
            do {
                let dict = try JSONSerialization.jsonObject(with: unwrappedData, options: []) as! [[String: Any]]
                var allCountries = [Country]()
                for result in dict {
                    let newCountry = Country(someName: (result["name"] as? String) ?? "", someCode: (result["alpha2Code"] as? String) ?? "", someCapital: (result["capital"] as? String) ?? "")
                    allCountries.append(newCountry)
                }
                success(allCountries)
            } catch {
                print("failed to deal with json")
                failure(nil)
            }
        })
        task.resume()
    }
    
}
