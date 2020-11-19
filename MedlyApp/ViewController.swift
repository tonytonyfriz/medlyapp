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
    
    var countries = [Country]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.register(CountryTableViewCell.self, forCellReuseIdentifier: "country_cell")
        failedToLoadLabel.isHidden = true
        
        beginCountryLoad()
    }
    
    func beginCountryLoad(){
        CountriesLoader.getCountries(success: { [weak self] (countries: [Country]) in
            DispatchQueue.main.async {
                self?.countries = countries
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "country_cell")!
        
        let country = countries[indexPath.row]
        
        cell.textLabel?.font = cell.textLabel!.font.withSize(22.0)
        cell.detailTextLabel?.font = cell.textLabel!.font.withSize(14.0)
        
        cell.textLabel?.text = country.name
        cell.detailTextLabel?.text = country.capital
        
        if let countryCode = country.alpha2Code {
            let countryIconURL = CountriesLoader.getCountryImageURL(code: countryCode)
            cell.imageView!.af.setImage(withURL: URL(string: countryIconURL)!)
        }
        
        return cell
    }
    

}

