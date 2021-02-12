//
//  ViewController.swift
//  CoffeeShops
//
//  Created by Ali Abod on 19/11/2019.
//
//  ALI ABOD - 201267800
//
//  Copyright © 2019 Ali Abod. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import CoreData

class MainViewController: UIViewController {
    
    // map and table view outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    var coffeeShops: CoffeeShops?
    var selectedCoffeeShop: CoffeeShop?
    var userLocation: CLLocation?
    var filteredTableData: CoffeeShops?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var context: NSManagedObjectContext?
    var setRegionBool = true
    var searchBarIsActive: Bool {
        return !(searchBar.text?.isEmpty ?? true)
    }
    
    // search bar
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .prominent
        searchBar.placeholder = " Search..."
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        searchBar.showsCancelButton = true
        searchBar.delegate = self
        searchBar.sizeToFit()
        return searchBar
    }()
    
    
    // location manager
    lazy var locationManager: CLLocationManager? = {
        guard CLLocationManager.locationServicesEnabled() else { return nil
        }
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        return locationManager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        context = appDelegate.persistentContainer.viewContext
        
        getCoffeeShops()
        requestLocationAccess()
        navigationItem.titleView = searchBar
    }
    // ensures coffee shop details have loaded and assigns which coffee shop details to present
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? DetailViewController,
            let selectedCoffeeShop = self.selectedCoffeeShop,
            selectedCoffeeShop.details != nil
            else { return }
        vc.coffeeShop = selectedCoffeeShop
    }
    
    // gets coffee shop basic data from cache and API
    func getCoffeeShops() {
        getCoffeeShopsFromAPI()
        getCoffeeShopsFromCache()
    }
    
    // gets coffee shop data from cache
    func getCoffeeShopsFromCache() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CoffeeShopsEntity")
        guard let CoffeeShopsEntity = try? context?.fetch(request).first as? CoffeeShopsEntity else { return }
        let data = CoffeeShopsEntity.coffeeShopArrayAttribute
        setCoffeeshops(data: data)
    }
    
    // gets coffee shop data from API
    func getCoffeeShopsFromAPI() {
        URLSession.shared.getData(url: urls.getCoffeeShops, completionHandler: { data in
            guard let data = data else { return }
            self.saveDataInCoreData(data: data)
            self.setCoffeeshops(data: data)
        })
    }
    
    // decode and setup coffee shop annotations + sort order
    func setCoffeeshops(data: Data) {
        do {
            // decode data
            let decoder = JSONDecoder()
            self.coffeeShops = try decoder.decode(CoffeeShops.self, from: data)
            // for each coffee shop create an array of annotations
            let annotations = self.coffeeShops!.data.map({$0.annotation})
            self.mapView.addAnnotations(annotations)
            // sort coffee shops according to distance to user distance
            self.sortCoffeeshops()
            self.tableView.reloadData()
        } catch {
            print(error)
        }
    }
    
    // pushes user to detail view/page
    func pushToDetailVC(coffeeShop: CoffeeShop) {
        // pull details from object if available
        if coffeeShop.details != nil {
            selectedCoffeeShop = coffeeShop
            performSegue(withIdentifier: "detailsPage", sender: self)
        } else {
            // get and decode data if not stored
            URLSession.shared.getData(url: urls.getCoffeeShopDetails(id: coffeeShop.id)) { data in
                guard let data = data else { return }
                do {
                    let decoder = JSONDecoder()
                    let details = try decoder.decode(CoffeeShopDetails.self, from: data)
                    coffeeShop.details = details
                    self.selectedCoffeeShop = coffeeShop
                    self.performSegue(withIdentifier: "detailsPage", sender: self)
                } catch {
                    print("error:\(error)")
                }
            }
        }
    }
    // request user's location
    func requestLocationAccess() {
        locationManager?.delegate = self
        locationManager?.startUpdatingLocation()
    }
    
    // sorts coffee shops according to distance from user location
    func sortCoffeeshops() {
        guard let coffeeShops = self.coffeeShops,
            let userLocation = userLocation
            else { return }
        // bubble sorts all coffee shops - using location.distance
        self.coffeeShops?.data = coffeeShops.data.sorted(by: { $0.location.distance(from: userLocation) < $1.location.distance(from: userLocation)
        })
        // assigns each coffee shop object distance variable - used later for displaying distance
        self.coffeeShops?.data.forEach({ (shop) in
            let calcDist = shop.location.distance(from: userLocation)
            shop.distance = String(format: "%.0f", calcDist)
        })
        tableView.reloadData()
    }
    
    // function that saves CoffeeShops data in core data
    func saveDataInCoreData(data: Data) {
        let coffeeShopsEntity = NSEntityDescription.insertNewObject(forEntityName: "CoffeeShopsEntity", into: context!) as! CoffeeShopsEntity
        coffeeShopsEntity.coffeeShopArrayAttribute = data
        do {
            try context?.save()
        } catch {
            fatalError()
        }
    }
}

extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchBarIsActive ?
            (filteredTableData?.data.count ?? 0):
            (coffeeShops?.data.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MainTableViewCell
        // sets cell labels for filtered coffee shops
        if searchBarIsActive {
            let coffeeShop = filteredTableData!.data[indexPath.row]
            cell.nameLabel.text = coffeeShop.name
            cell.distanceLabel.text = "\(coffeeShop.distance)m"
            return cell
        } else {
            // sets cell labels when no search initiated
            let coffeeShop = coffeeShops!.data[indexPath.row]
            cell.nameLabel.text = coffeeShop.name
            cell.distanceLabel.text = "\(coffeeShop.distance)m"
            return cell
        }
    }
    
}

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // if cell is selected, call pushToDetailVC and pass selected coffeeshop object
        if searchBarIsActive,
            let coffeeShop = filteredTableData?.data[indexPath.row] {
            pushToDetailVC(coffeeShop: coffeeShop)
        } else if let coffeeShop = coffeeShops?.data[indexPath.row] {
            pushToDetailVC(coffeeShop: coffeeShop)
        }
    }
    
    // sets height for table view cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}

extension MainViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let myAnnotation = view.annotation as! MyAnnotation
        let selectedCoffeeshop = coffeeShops!.data.first(where: {$0.id == myAnnotation.id})
        pushToDetailVC(coffeeShop: selectedCoffeeshop!)
    }
}

extension MainViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locationOfUser = locations.first else {
            return
        }
        userLocation = locationOfUser
        
        let latitude = locationOfUser.coordinate.latitude
        let longitude = locationOfUser.coordinate.longitude
        let latDelta: CLLocationDegrees = 0.002
        let lonDelta: CLLocationDegrees = 0.002
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: location, span: span)
        // ensures set region is only done once at launch allowing user to pan map
        if setRegionBool == true {
            self.mapView.setRegion(region, animated: true)
            setRegionBool = false
        }
        // sorts the coffee shops according to distance from user location
        sortCoffeeshops()
    }
}

extension MainViewController: UISearchBarDelegate {
    // search function
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredTableData = nil
        guard let coffeeShops = coffeeShops?.data,
            !searchText.isEmpty else {
                self.tableView.reloadData()
                return
        }
        // creates an array of coffee shops that match filter
        let filteredArray  = coffeeShops.filter({ coffeeShop -> Bool in
            return coffeeShop.name.lowercased().contains(searchText.lowercased())
        })
        // creates coffeeshops object using filtered array
        filteredTableData = CoffeeShops(data: filteredArray)
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
