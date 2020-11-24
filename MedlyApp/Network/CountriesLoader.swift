//
//  CountriesLoader.swift
//  MedlyApp
//
//  Created by Anthony Frizalone on 11/19/20.
//

import Foundation

class CountriesLoaderImageHelper {
    
    static let countryImageURLPath = "CountryIconURL"
    
    static var countryIconURL: String = {
        guard let filePath = Bundle.main.url(forResource: "URLs", withExtension: "plist") else { return "" }
        let data = try! Data(contentsOf: filePath)
        guard let plist = try! PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String:String] else { return "" }
        
        if let baseUrl = plist[countryImageURLPath] {
            return baseUrl
        }
        
        return ""
    }()
    
    class func getCountryIconImageURL(withCode code: String) -> String {
        countryIconURL.replacingOccurrences(of: "[CODE]", with: code)
    }
}

class CountriesLoader {
    
    static let countriesURLPath = "CountriesURL"
    
    static let countriesPlist = "Countries.plist"
    
    static var countriesURL: String = {
        guard let filePath = Bundle.main.url(forResource: "URLs", withExtension: "plist") else { return "" }
        let data = try! Data(contentsOf: filePath)
        guard let plist = try! PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String:String] else { return "" }
        
        if let baseUrl = plist[countriesURLPath] {
            return baseUrl
        }
        
        return ""
    }()
    
    class func getCountries(success:@escaping (_ movies: [Country]) -> Void, failure:@escaping (_ error: Error?) -> Void){
        let url = CountriesLoader.countriesURL
        
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil

        let session = URLSession.init(configuration: config)
        
        let task = session.dataTask(with: URLRequest(url: URL(string: url)!), completionHandler: {(data, response, error) in
            if let error = error {
                let savedCountries = getSavedCountries()
                if savedCountries != nil {
                   success(savedCountries!)
                } else {
                    failure(error)
                    print(error)
                }
                return
            }
            
            guard let unwrappedData = data else {
                print("data wasn't loaded")
                let savedCountries = getSavedCountries()
                if savedCountries != nil {
                   success(savedCountries!)
                } else {
                    failure(nil)
                }
                return
            }
            do {
                let loadedCountries = try JSONDecoder().decode([Country].self, from: unwrappedData)
                writeCountriesData(countries: loadedCountries)
                success(loadedCountries)
            } catch {
                print("failed to deal with json")
                let savedCountries = getSavedCountries()
                if savedCountries != nil {
                   success(savedCountries!)
                } else {
                    failure(nil)
                }
            }
        })
        task.resume()
    }
    
    class func writeCountriesData(countries: [Country]) {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml

        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(countriesPlist)

        do {
            let data = try encoder.encode(countries)
            try data.write(to: path)
        } catch {
            print(error)
        }
    }
    
    class func getSavedCountries() -> [Country]? {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(countriesPlist)
        
        if let xml = FileManager.default.contents(atPath: path.path)
        {
            let decoder = PropertyListDecoder()
            let countries = try? decoder.decode([Country].self, from: xml)
            
            return countries
        }
        
        return nil
    }
}
