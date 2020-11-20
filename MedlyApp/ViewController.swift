//
//  ViewController.swift
//  MedlyApp
//
//  Created by Anthony Frizalone on 11/19/20.
//

import UIKit
import AlamofireImage
import SDWebImage

class ViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var failedToLoadLabel: UILabel!
    
    var indexedCountries = [Character: [Country]]()
    var indexedCountriesFirstLetter = [Character]()
    var indexedCountriesFirstLetterReversed = [Character]()

    var reverseCountries = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(CountryTableViewCell.self, forCellReuseIdentifier: "country_cell")
        failedToLoadLabel.isHidden = true
        
        beginCountryLoad()
    }
    
    func beginCountryLoad(){
        CountriesLoader.getCountries(success: { [weak self] (countries: [Country]) in
            DispatchQueue.main.async {
                self?.separateCountries(countries: countries)
                self?.tableView.reloadData()
                
                self?.tableView.isHidden = false
                self?.failedToLoadLabel.isHidden = true
            }
        }, failure: { [weak self] (error: Error?) in
            DispatchQueue.main.async {
                self?.tableView.isHidden = true
                self?.failedToLoadLabel.isHidden = false
            }
        })
    }
    
    func separateCountries(countries: [Country]){
        var sortedCountries : [Country]?
        if reverseCountries {
            sortedCountries = countries.sorted(by: { $0.name ?? "" > $1.name ?? "" })
        } else {
            sortedCountries = countries
        }
        
        for country in sortedCountries! {
            guard let firstLetter = country.name?.first else { continue }
            if indexedCountries[firstLetter] == nil {
                indexedCountries[firstLetter] = [Country]()
                indexedCountriesFirstLetter.append(firstLetter)
            }
            indexedCountries[firstLetter]?.append(country)
            indexedCountriesFirstLetter = indexedCountriesFirstLetter.sorted()
            indexedCountriesFirstLetterReversed = indexedCountriesFirstLetter.sorted(by: { $0 > $1 })
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if reverseCountries == true {
            return indexedCountriesFirstLetterReversed.count
        }
        return indexedCountriesFirstLetter.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var firstLetter : Character?
        firstLetter = indexedCountriesFirstLetter[section]
        if reverseCountries {
            firstLetter = indexedCountriesFirstLetterReversed[section]
        }
        return indexedCountries[firstLetter!]?.count ?? 0
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var iterationToUse = indexedCountriesFirstLetter
        if reverseCountries {
            iterationToUse = indexedCountriesFirstLetterReversed
        }
        
        var allKeys = [String]()
        for key in iterationToUse {
            allKeys.append(String(key))
        }
        
        return allKeys
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if reverseCountries {
            return String(indexedCountriesFirstLetterReversed[section])
        } else {
            return String(indexedCountriesFirstLetter[section])
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "country_cell")!
        
        var firstLetter = indexedCountriesFirstLetter[indexPath.section]
        if reverseCountries {
            firstLetter = indexedCountriesFirstLetterReversed[indexPath.section]
        }
        let country = indexedCountries[firstLetter]?[indexPath.row]
        
        cell.textLabel?.font = cell.textLabel!.font.withSize(22.0)
        cell.detailTextLabel?.font = cell.textLabel!.font.withSize(14.0)
        
        cell.textLabel?.text = country?.name
        cell.detailTextLabel?.text = country?.capital
        
        if let countryCode = country?.alpha2Code {
            let countryIconURL = CountriesLoader.getCountryImageURL(code: countryCode)
            cell.imageView?.af.setImage(withURL: URL(string: countryIconURL)!)
        } else {
            cell.imageView?.image = UIImage(named: "placeholder-image")
        }
        
        return cell
    }
    

}

