//
//  CountryTableViewCell.swift
//  MedlyApp
//
//  Created by Anthony Frizalone on 11/19/20.
//

import UIKit
import AlamofireImage

extension Double {
    func reduceScale(to places: Int) -> Double {
        let multiplier = pow(10, Double(places))
        let newDecimal = multiplier * self // move the decimal right
        let truncated = Double(Int(newDecimal)) // drop the fraction
        let originalDecimal = truncated / multiplier // move the decimal back
        return originalDecimal
    }
}

func formatNumber(_ n: Int) -> String {
    let num = abs(Double(n))
    let sign = (n < 0) ? "-" : ""

    switch num {
    case 1_000_000_000...:
        var formatted = num / 1_000_000_000
        formatted = formatted.reduceScale(to: 1)
        return "\(sign)\(formatted)B"

    case 1_000_000...:
        var formatted = num / 1_000_000
        formatted = formatted.reduceScale(to: 1)
        return "\(sign)\(formatted)M"

    case 1_000...:
        var formatted = num / 1_000
        formatted = formatted.reduceScale(to: 1)
        return "\(sign)\(formatted)K"

    case 0...:
        return "\(n)"

    default:
        return "\(sign)\(n)"
    }
}


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
        textLabel?.font = UIFont.boldSystemFont(ofSize: 22.0)
        detailTextLabel?.font = detailTextLabel!.font.withSize(14.0)
        
        textLabel?.text = country.name
        
        var capital = ""
        if country.capital != nil && country.capital?.count ?? 0 > 0 {
            capital = country.capital! + ", "
        }
        var population = ""
        if country.population != nil {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            population = "population: " + formatNumber(country.population!)
        }
        
        let attributedString = NSMutableAttributedString(string: capital+population)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 14.0), range: NSMakeRange(0, (capital+population).count))
        attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 14.0), range: NSMakeRange(0, (capital).count))
        
        detailTextLabel?.attributedText = attributedString
        
        if let countryCode = country.alpha2Code {
            let countryIconURL = CountriesLoaderImageHelper.getCountryIconImageURL(withCode: countryCode)
            imageView?.af.setImage(withURL: URL(string: countryIconURL)!, cacheKey: nil, placeholderImage: UIImage(named: "placeholder-image-small"))
        } else {
            imageView?.image = UIImage(named: "placeholder-image-small")
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 60, y: 13.0, width: self.frame.width - 80, height: 30.0)
        detailTextLabel?.frame = CGRect(x: 60, y: 35.0, width: self.frame.width - 80, height: 30.0)
        imageView?.frame = CGRect(x: 14.0, y: 32.0/2 + 7.0, width: 32.0, height: 32.0)
    }
    
}
