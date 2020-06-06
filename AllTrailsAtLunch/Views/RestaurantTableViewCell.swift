//
//  RestaurantTableViewCell.swift
//  AllTrailsAtLunch
//
//  Created by Evelyn C Cordner on 6/3/20.
//  Copyright © 2020 EvelynCordner. All rights reserved.
//

import UIKit

class RestaurantTableViewCell: UITableViewCell {
    
    @IBOutlet weak var roundedCornerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingsView: RatingsView!
    @IBOutlet weak var ratingsLabel: UILabel!
    @IBOutlet weak var restaurantImageView: UIImageView!
    @IBOutlet weak var heartImageView: UIImageView!
    
    var imageReference:String?
    
    var favorite:Bool = false {
        didSet {
            if favorite {
                heartImageView.image = #imageLiteral(resourceName: "Full Heart")
            } else {
                heartImageView.image = #imageLiteral(resourceName: "Empty Heart")
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        roundedCorners()
        self.selectionStyle = UITableViewCell.SelectionStyle.none
    }
    
    func setImage(from reference: String) {
        if (imageReference != reference) {
            imageReference = reference
            
            self.restaurantImageView.image = nil;
            let imgSource = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(reference)&key=\(API_KEY)"
            guard let imageURL = URL(string: imgSource) else { return }

            DispatchQueue.global().async {
                guard let imageData = try? Data(contentsOf: imageURL) else { return }

                let image = UIImage(data: imageData)
                DispatchQueue.main.async {
                    self.restaurantImageView.image = image
                }
            }
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted && !favorite || !highlighted && favorite {
            self.heartImageView.image = #imageLiteral(resourceName: "Full Heart")
        } else {
            self.heartImageView.image = #imageLiteral(resourceName: "Empty Heart")
        }
    }
}

private extension RestaurantTableViewCell {
    
    func roundedCorners() {
        roundedCornerView.layer.cornerRadius = 9
        roundedCornerView.layer.masksToBounds = true
        roundedCornerView.layer.borderColor = UIColor.lightGray.cgColor
        roundedCornerView.layer.borderWidth = 1
        
    }
    
}
