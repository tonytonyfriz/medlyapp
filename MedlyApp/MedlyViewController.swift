//
//  ViewController.swift
//  MedlyApp
//
//  Created by Anthony Frizalone on 11/19/20.
//

import UIKit

class MedlyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet var failedToLoadLabel: UILabel!
    @IBOutlet var forwardBackwardSegmentedControl: UISegmentedControl!
    @IBOutlet var networkActivityIndicator: UIActivityIndicatorView!
    
    enum CountriesSequence {
        case ascending
        case descending
        case byPopulation
    }
    
    var allCountries = [Country]()
    var searchedCountries = [Country]()
    var countriesByPopulation = [Country]()
    var indexedCountries = [Character: [Country]]()
    var indexedCountriesReversed = [Character: [Country]]()
    var indexedCountriesFirstLetter = [Character]()
    var indexedCountriesFirstLetterReversed = [Character]()
    
    var searchTerm : String? {
        didSet {
            updateSearchedCountries()
        }
    }

    var countriesSequence = CountriesSequence.ascending {
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
        searchBar.searchTextField.autocapitalizationType = .words
        
        beginCountryLoad()
    }
    
    @IBAction func setCountriesSequence(_ sender: UISegmentedControl){
        if allCountries.count < 1 {
            return
        }
        
        if sender.selectedSegmentIndex == 0 {
            countriesSequence = .ascending
            if searchTerm?.count ?? 0 > 0 {
                searchedCountries = searchedCountries.sorted(by: { $0.name ?? "" < $1.name ?? "" })
            }
        } else if sender.selectedSegmentIndex == 1{
            countriesSequence = .descending
            if searchTerm?.count ?? 0 > 0 {
                searchedCountries = searchedCountries.sorted(by: { $0.name ?? "" > $1.name ?? "" })
            }
        } else {
            countriesSequence = .byPopulation
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
        countriesByPopulation = countries.sorted(by: { $0.population ?? 0 > $1.population ?? 0 })
        
        for country in sortedCountries {
            guard let firstLetter = country.name?.first else { continue }
            if indexedCountries[firstLetter] == nil {
                indexedCountries[firstLetter] = [Country]()
                indexedCountriesFirstLetter.append(firstLetter)
                
                indexedCountriesReversed[firstLetter] = [Country]()
            }
            indexedCountries[firstLetter]?.append(country)
            indexedCountriesReversed[firstLetter]?.append(country)
        }
        
        for key in indexedCountriesReversed.keys {
            indexedCountriesReversed[key] = indexedCountriesReversed[key]?.sorted(by: { $0.name ?? "" > $1.name ?? "" })
        }
        
        indexedCountriesFirstLetter = indexedCountriesFirstLetter.sorted()
        indexedCountriesFirstLetterReversed = indexedCountriesFirstLetter.sorted(by: { $0 > $1 })
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTerm = searchText
    }
    
    func updateSearchedCountries(){
        var foundCountries = [Country]()
        for country in allCountries {
            if let _ = country.name?.range(of: searchTerm ?? "", options: .caseInsensitive) {
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
        searchBar.searchTextField.text = ""
        searchTerm = ""
        searchBar.searchTextField.resignFirstResponder()
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if countriesSequence == .byPopulation {
            return 1
        }
        
        if searchTerm?.count ?? 0 > 0 {
            return 1
        }
        
        return indexedCountriesFirstLetter.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchTerm?.count ?? 0 > 0 {
            return searchedCountries.count
        }
        
        if countriesSequence == .byPopulation {
            return countriesByPopulation.count
        }
        
        var firstLetter = indexedCountriesFirstLetter[section]
        if countriesSequence == .descending {
            firstLetter = indexedCountriesFirstLetterReversed[section]
        }
        return indexedCountries[firstLetter]?.count ?? 0
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if searchTerm?.count ?? 0 > 0 {
            return nil
        }
        
        if countriesSequence == .byPopulation {
            return nil
        }
        
        var iterationToUse = indexedCountriesFirstLetter
        if countriesSequence == .descending {
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
        
        if countriesSequence == .byPopulation {
            return nil
        }
        
        if countriesSequence == .descending {
            return String(indexedCountriesFirstLetterReversed[section])
        } else {
            return String(indexedCountriesFirstLetter[section])
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "country_cell")! as! CountryTableViewCell
        
        var country : Country?
        
        if searchTerm?.count ?? 0 > 0 {
            country = searchedCountries[indexPath.row]
        } else if countriesSequence == .byPopulation {
            country = countriesByPopulation[indexPath.row]
        } else {
            if countriesSequence == .ascending {
                let firstLetter = indexedCountriesFirstLetter[indexPath.section]
                country = indexedCountries[firstLetter]?[indexPath.row]
            } else {
                let firstLetter = indexedCountriesFirstLetterReversed[indexPath.section]
                country = indexedCountriesReversed[firstLetter]?[indexPath.row]
            }
        }
        
        cell.setup(with: country!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailViewController = DetailViewController(nibName: "DetailViewController", bundle: nil)
        
        var country : Country?
        
        if searchTerm?.count ?? 0 > 0 {
            country = searchedCountries[indexPath.row]
        } else if countriesSequence == .byPopulation {
            country = countriesByPopulation[indexPath.row]
        } else {
            if countriesSequence == .ascending {
                let firstLetter = indexedCountriesFirstLetter[indexPath.section]
                country = indexedCountries[firstLetter]?[indexPath.row]
            } else {
                let firstLetter = indexedCountriesFirstLetterReversed[indexPath.section]
                country = indexedCountriesReversed[firstLetter]?[indexPath.row]
            }
        }
        
        detailViewController.country = country
        present(detailViewController, animated: true, completion: nil)
    }
    

}

