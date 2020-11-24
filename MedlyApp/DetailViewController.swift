//
//  DetailViewController.swift
//  MedlyApp
//
//  Created by Anthony Frizalone on 11/24/20.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet var countryLabel: UILabel!
    @IBOutlet var alpha2CodeLabel: UILabel!
    @IBOutlet var capitalLabel: UILabel!
    @IBOutlet var populationLabel: UILabel!
    @IBOutlet var timezoneLabel: UILabel!
    
    var country: Country?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        countryLabel.text = country?.name
        alpha2CodeLabel.text = "Code: " + String(country!.alpha2Code!)
        capitalLabel.text = "Capital: " + String(country!.capital!)
        populationLabel.text = "Population: " + formatNumber(country!.population!)
        timezoneLabel.text = "Timezones: "
        var i = 0
        var timezoneLabelString = ""
        for timezone in country!.timezones! {
            timezoneLabelString += timezone
            
            if i < country!.timezones!.count - 1 {
                timezoneLabelString += ", "
            }
            
            i += 1
        }
        timezoneLabel.text = "Timezones: " + timezoneLabelString
        
    }

    @IBAction func back(){
        self.dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
