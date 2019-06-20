//
//  MainViewControler.swift
//  LovePlaces
//
//  Created by Evgeniy Suprun on 18/06/2019.
//  Copyright © 2019 Evgeniy Suprun. All rights reserved.
//

import UIKit
import RealmSwift

class MainViewControler: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var places: Results<Place>!

    override func viewDidLoad() {
        super.viewDidLoad()
      places = realm.objects(Place.self)
       
    }

    // MARK: - Table view data source

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return places.isEmpty ? 0 : places.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MyCustomCell
        
        let place = places[indexPath.row]

        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.height / 2
        cell.imageOfPlace.clipsToBounds = true

        return cell
    }
    
    // MARK: Table View Delegate (work with cells, delete)
    
     func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let place = places[indexPath.row]
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (_, _) in
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        return [deleteAction]
    }

  //   MARK: - Navigation (prepare fo segue)

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      
        if segue.identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let place = places[indexPath.row]
            let newPlaceVC = segue.destination as! NewPlaceControler
            newPlaceVC.currentPlace = place
        }
    }
 
    
    // MARK: Save new place and reload Data!
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue){
        
        guard let newPlaceVC = segue.source as? NewPlaceControler else {return}
        newPlaceVC.savePlace()
        tableView.reloadData()
    }
   
    
}
