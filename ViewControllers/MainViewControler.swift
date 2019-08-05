//
//  MainViewControler.swift
//  LovePlaces
//
//  Created by Evgeniy Suprun on 18/06/2019.
//  Copyright © 2019 Evgeniy Suprun. All rights reserved.
//

import UIKit
import RealmSwift
import Cosmos

class MainViewControler: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var places: Results<Place>!
    private var filteredPlaces: Results<Place>!
    private var ascendingSorting = true
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else {return false}
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var reverseSegment: UIBarButtonItem!
    

    override func viewDidLoad() {
        super.viewDidLoad()
      places = realm.objects(Place.self)
        
    // Mark Check version ios for LargeTitle
        
        if #available(iOS 11.0, *) {
            guard let navigationController = navigationController else { return }
            guard navigationController.navigationBar.prefersLargeTitles else { return }
            guard navigationController.navigationItem.largeTitleDisplayMode != .never else { return }
        }
        
    
     // Setup serch controller
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    // MARK: - Table view data source

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredPlaces.count
        }
        return places.isEmpty ? 0 : places.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MyCustomCell
        
        let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
    

        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        cell.ratingCell.rating = place.rating

        return cell
    }
    
    // MARK: Table View Delegate (work with cells, delete)
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
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
            let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
            let newPlaceVC = segue.destination as! NewPlaceControler
            newPlaceVC.currentPlace = place
        }
    }
 
    
    // MARK: Save new place and reload Data!
    
//    @IBAction func unwindSegue(_ segue: UIStoryboardSegue){
//        
////        guard let newPlaceVC = segue.source as? NewPlaceControler else {return}
////        // newPlaceVC.savePlace()
//        tableView.reloadData()
//    }
    
    
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        
       sorting()
    }
    
    @IBAction func reverseSorting(_ sender: Any) {
        
        ascendingSorting.toggle()
        
        if ascendingSorting {
            reverseSegment.image = #imageLiteral(resourceName: "AZ")
        } else {
            reverseSegment.image = #imageLiteral(resourceName: "ZA")
        }
        sorting()
        
    }
    
    // MARK: Sorting Data from cell for name and date
    
    private func sorting() {
        
        if segmentedControl.selectedSegmentIndex == 0  {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        tableView.reloadData()
    }

    
}

extension MainViewControler: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        
        tableView.reloadData()
    }
    
}

