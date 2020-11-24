//
//  CountriesLoader.swift
//  MedlyApp
//
//  Created by Anthony Frizalone on 11/19/20.
//

import UIKit

let COUNTRIES_LAST_SAVE_DATE_DEFAULTS_STRING = "last_countries_save"
let COUNTRIES_LAST_SAVE_TIME_ELAPSED_DIFFERENCE : Double = 60*60*24

let COUNTRY_REQUIRED_FIELDS = ["name", "alpha2Code", "capital", "population", "timezones"]

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
        var url = CountriesLoader.countriesURL
        
        url.append("?fields=")
        
        var i = 0
        for field in COUNTRY_REQUIRED_FIELDS {
            url.append(field)
            
            if i != COUNTRY_REQUIRED_FIELDS.count - 1 {
                url.append(";")
            }
            
            i += 1
        }
        
        print(url)
        
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil

        let session = URLSession.init(configuration: config)
        
        let task = session.dataTask(with: URLRequest(url: URL(string: url)!), completionHandler: {(data, response, error) in
            if let error = error {
                let savedCountries = getSavedCountries()
                if savedCountries != nil {
                    success(savedCountries!)
                    showOfflineModeAlert()
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
                    showOfflineModeAlert()
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
                    showOfflineModeAlert()
                } else {
                    failure(nil)
                }
            }
        })
        task.resume()
    }
    
    class func writeCountriesData(countries: [Country]) {
        if let lastSaveDate = UserDefaults.standard.object(forKey: COUNTRIES_LAST_SAVE_DATE_DEFAULTS_STRING) as? Date {
            if Date().timeIntervalSince(lastSaveDate) < COUNTRIES_LAST_SAVE_TIME_ELAPSED_DIFFERENCE {
                return
            }
            UserDefaults.standard.setValue(Date(), forKey: COUNTRIES_LAST_SAVE_DATE_DEFAULTS_STRING)
        } else {
            UserDefaults.standard.setValue(Date(), forKey: COUNTRIES_LAST_SAVE_DATE_DEFAULTS_STRING)
        }
        
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
    
    class func showOfflineModeAlert(){
        return
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Flags Unavailable", message: "You are in offline mode; country flag icons are unavailable.", preferredStyle: .alert)
            let action = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alertController.addAction(action)
            UIApplication.shared.windows[0].rootViewController!.present(alertController, animated: true)
        }
    }
}
