//
//  ViewController.swift
//  MedlyApp
//
//  Created by Anthony Frizalone on 11/19/20.
//

import UIKit
import AlamofireImage

class MedlyViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet var failedToLoadLabel: UILabel!
    @IBOutlet var forwardBackwardSegmentedControl: UISegmentedControl!
    @IBOutlet var networkActivityIndicator: UIActivityIndicatorView!
    
    var allCountries = [Country]()
    var searchedCountries = [Country]()
    var indexedCountries = [Character: [Country]]()
    var indexedCountriesFirstLetter = [Character]()
    var indexedCountriesFirstLetterReversed = [Character]()
    
    var searchTerm : String?

    var reverseCountries = false {
        didSet {
            tableView.reloadData()
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(CountryTableViewCell.self, forCellReuseIdentifier: "country_cell")
        failedToLoadLabel.isHidden = true
        
        searchBar.showsCancelButton = true
        
        beginCountryLoad()
    }
    
    @IBAction func reverseCountries(_ sender: UISegmentedControl){
        if sender.selectedSegmentIndex == 0 {
            reverseCountries = false
            if searchTerm?.count ?? 0 > 0 {
                searchedCountries = searchedCountries.sorted(by: { $0.name ?? "" < $1.name ?? "" })
            }
        } else {
            reverseCountries = true
            if searchTerm?.count ?? 0 > 0 {
                searchedCountries = searchedCountries.sorted(by: { $0.name ?? "" > $1.name ?? "" })
            }
        }
    }
    
    func beginCountryLoad(){
        networkActivityIndicator.isHidden = false
        CountriesLoader.getCountries(success: { [weak self] (countries: [Country]) in
            DispatchQueue.main.async {
                self?.allCountries = countries
                self?.separateCountries(countries: countries)
                self?.tableView.reloadData()
                
                self?.tableView.isHidden = false
                self?.failedToLoadLabel.isHidden = true
                
                self?.networkActivityIndicator.isHidden = true
            }
        }, failure: { [weak self] (error: Error?) in
            DispatchQueue.main.async {
                self?.tableView.isHidden = true
                self?.failedToLoadLabel.isHidden = false
                self?.networkActivityIndicator.isHidden = true
            }
        })
    }
    
    func separateCountries(countries: [Country]){
        let sortedCountries = countries.sorted(by: { $0.name ?? "" < $1.name ?? "" })
        
        for country in sortedCountries {
            guard let firstLetter = country.name?.first else { continue }
            if indexedCountries[firstLetter] == nil {
                indexedCountries[firstLetter] = [Country]()
                indexedCountriesFirstLetter.append(firstLetter)
            }
            indexedCountries[firstLetter]?.append(country)
        }
        
        indexedCountriesFirstLetter = indexedCountriesFirstLetter.sorted()
        indexedCountriesFirstLetterReversed = indexedCountriesFirstLetter.sorted(by: { $0 > $1 })
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTerm = searchText
        
        var foundCountries = [Country]()
        for country in allCountries {
            if country.name?.contains(searchText) == true {
                foundCountries.append(country)
            }
        }
        
        foundCountries.sort(by: { $0.name ?? "" < $1.name ?? "" })
        
        searchedCountries = foundCountries
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.searchTextField.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.searchTextField.resignFirstResponder()
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if searchTerm?.count ?? 0 > 0 {
            return 1
        }
        
        return indexedCountriesFirstLetter.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchTerm?.count ?? 0 > 0 {
            return searchedCountries.count
        }
        
        var firstLetter = indexedCountriesFirstLetter[section]
        if reverseCountries {
            firstLetter = indexedCountriesFirstLetterReversed[section]
        }
        return indexedCountries[firstLetter]?.count ?? 0
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if searchTerm?.count ?? 0 > 0 {
            return []
        }
        
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
        if searchTerm?.count ?? 0 > 0 {
            return nil
        }
        
        if reverseCountries {
            return String(indexedCountriesFirstLetterReversed[section])
        } else {
            return String(indexedCountriesFirstLetter[section])
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "country_cell")!
        
        var country : Country?
        
        if searchTerm?.count ?? 0 > 0 {
            country = searchedCountries[indexPath.row]
        } else {
            if reverseCountries == false {
                let firstLetter = indexedCountriesFirstLetter[indexPath.section]
                country = indexedCountries[firstLetter]?[indexPath.row]
            } else if reverseCountries == true {
                let firstLetter = indexedCountriesFirstLetterReversed[indexPath.section]
                country = indexedCountries[firstLetter]?.sorted(by: { $0.name ?? "" > $1.name ?? "" })[indexPath.row]
            }
        }
        
        cell.textLabel?.font = cell.textLabel!.font.withSize(22.0)
        cell.detailTextLabel?.font = cell.textLabel!.font.withSize(14.0)
        
        cell.textLabel?.text = country?.name
        cell.detailTextLabel?.text = country?.capital
        
        if let countryCode = country?.alpha2Code {
            let countryIconURL = CountriesLoaderImageHelper.getCountryIconImageURL(withCode: countryCode)
            cell.imageView?.af.setImage(withURL: URL(string: countryIconURL)!, cacheKey: nil, placeholderImage: UIImage(named: "placeholder-image"))
        } else {
            cell.imageView?.image = UIImage(named: "placeholder-image")
        }
        
        return cell
    }
    

}

