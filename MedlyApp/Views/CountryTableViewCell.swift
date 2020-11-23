//
//  CountryTableViewCell.swift
//  MedlyApp
//
//  Created by Anthony Frizalone on 11/19/20.
//

import UIKit
import AlamofireImage

class CountryTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        self.imageView!.image = UIImage(named: "placeholder-image")
        
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(with country: Country){
        textLabel?.font = textLabel!.font.withSize(22.0)
        detailTextLabel?.font = textLabel!.font.withSize(14.0)
        
        textLabel?.text = country.name
        detailTextLabel?.text = country.capital
        
        if let countryCode = country.alpha2Code {
            let countryIconURL = CountriesLoaderImageHelper.getCountryIconImageURL(withCode: countryCode)
            imageView?.af.setImage(withURL: URL(string: countryIconURL)!, cacheKey: nil, placeholderImage: UIImage(named: "placeholder-image"))
        } else {
            imageView?.image = UIImage(named: "placeholder-image")
        }
    }

}
