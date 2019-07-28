//
//  MyCustomCell.swift
//  LovePlaces
//
//  Created by Evgeniy Suprun on 18/06/2019.
//  Copyright © 2019 Evgeniy Suprun. All rights reserved.
//

import UIKit
import Cosmos

class MyCustomCell: UITableViewCell {
    
    @IBOutlet weak var imageOfPlace: UIImageView! {
        didSet {
            imageOfPlace.layer.cornerRadius = imageOfPlace.frame.height / 2
            imageOfPlace.clipsToBounds = true
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var ratingCell: CosmosView! {
        didSet {
            ratingCell.settings.updateOnTouch = false
        }
    }
    
}
