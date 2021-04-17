//
//  ViewController.swift
//  GooglePlacesSearchController
//
//  Created by Dmitry Shmidt on 6/28/15.
//  Copyright (c) 2015 Dmitry Shmidt. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import GooglePlacesSearchController
import GoogleMaps
import CoreData
import CoreLocation
class ViewController: UIViewController,CLLocationManagerDelegate {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate //Singlton instance
    var context:NSManagedObjectContext!
    let locationManager = CLLocationManager()
    var latitude = Double()
    var long = Double()
    let GoogleMapsAPIServerKey = "AIzaSyDsIG8XXKNR2B1pklpLlbx1cXh0GI7k76E"

    lazy var placesSearchController: GooglePlacesSearchController = {
        let controller = GooglePlacesSearchController(delegate: self,
                                                      apiKey: GoogleMapsAPIServerKey,
                                                      placeType: .address
                                                      
            // Optional: coordinate: CLLocationCoordinate2D(latitude: 55.751244, longitude: 37.618423),
            // Optional: radius: 10,
            // Optional: strictBounds: true,
            // Optional: searchBarPlaceholder: "Start typing..."
    //PlaceDetails:.coordinate
        )
      
        
        
        //Optional: controller.searchBar.isTranslucent = false
        //Optional: controller.searchBar.barStyle = .black
        //Optional: controller.searchBar.tintColor = .white
        //Optional: controller.searchBar.barTintColor = .black
        return controller
    }()

    @IBAction func searchAddress(_ sender: UIBarButtonItem) {
        present(placesSearchController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
     
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        let camera = GMSCameraPosition.camera(withLatitude: locValue.latitude, longitude: locValue.longitude, zoom: 13.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        view = mapView
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
        
        
        
        
    }
    // MARK: Methods to Open, Store and Fetch data
//        func openDatabse()
//        {
//            context = appDelegate.persistentContainer.viewContext
//            let entity = NSEntityDescription.entity(forEntityName: "Location", in: context)
//            let newUser = NSManagedObject(entity: entity!, insertInto: context)
//            saveData(UserDBObj:newUser)
//        }

    
    
}

extension ViewController: GooglePlacesAutocompleteViewControllerDelegate {
    func viewController(didAutocompleteWith place: PlaceDetails) {
        print(place.description)
        print(place.coordinate ?? "")
        print(place.coordinate?.latitude ?? "")
        print(place.coordinate?.longitude ?? "")
        placesSearchController.isActive = false
        
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate!.latitude, longitude: place.coordinate!.longitude, zoom: 13.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        view = mapView
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: place.coordinate!.latitude, longitude: place.coordinate!.longitude)
        marker.title = "gopi"
        marker.snippet = "test"
        marker.map = mapView
        latitude = place.coordinate!.latitude
        long = place.coordinate!.longitude
        
       guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Now let’s create an entity and new user records.
        let userEntity = NSEntityDescription.entity(forEntityName: "Location", in: managedContext)!
        
        //final, we need to add some data to our newly created record for each keys using
        //here adding 5 data with loop
        
        
        let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
        user.setValue("\(latitude)", forKeyPath: "longitude")
        user.setValue("\(long)", forKeyPath: "latitude")
        
        do {
            try managedContext.save()
           
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
       
       fetchData()
    }
    
        func fetchData()
        {
             //As we know that container is set up in the AppDelegates so we need to refer that container.
                   guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                   
                   //We need to create a context from this container
                   let managedContext = appDelegate.persistentContainer.viewContext
                   
                   //Prepare the request of type NSFetchRequest  for the entity
                   let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
                   
           //        fetchRequest.fetchLimit = 1
           //        fetchRequest.predicate = NSPredicate(format: "username = %@", "Ankur")
           //        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "email", ascending: false)]
           //
                   do {
                       let result = try managedContext.fetch(fetchRequest)
                       for data in result as! [NSManagedObject] {
                           print(data.value(forKey: "longitude") as! String)
                        print(data.value(forKey: "latitude") as! String)
                       }
                       
                   } catch {
                       
                       print("Failed")
                   }
        }
    
    func viewController(didManualCompleteWith text: String) {
        print(text)
        placesSearchController.isActive = false
    }
}
