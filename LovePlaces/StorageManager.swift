//
//  StorageManager.swift
//  LovePlaces
//
//  Created by Evgeniy Suprun on 20/06/2019.
//  Copyright © 2019 Evgeniy Suprun. All rights reserved.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func saveObject(_ place: Place) {
        try! realm.write {
            realm.add(place)
        }
    }
    
}
