//
//  PlaceModel.swift
//  LovePlaces
//
//  Created by Evgeniy Suprun on 18/06/2019.
//  Copyright © 2019 Evgeniy Suprun. All rights reserved.
//

import Foundation

struct Place {
    let name: String
    let location: String
    let type: String
    let image: String
    
    static let restaurantNames = [
        "Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
        "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
        "Speak Easy", "Morris Pub", "Вкусные истории",
        "Классик", "Love&Life", "Шок", "Бочка"
    ]
    
   static func getPlace() -> [Place] {
        
        var places = [Place]()
        for place in Place.restaurantNames {
            places.append(Place(name: place, location: "Киев", type: "Ресторан", image: place))
        }
        
        return places
    }
}



