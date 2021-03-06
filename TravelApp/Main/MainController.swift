//
//  MainController.swift
//  TravelApp
//
//  Created by daniel berger on 1/15/20.
//  Copyright © 2020 daniel berger. All rights reserved.
//

import UIKit
import MapKit
import LBTATools
import Combine

extension MainController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if (annotation is MKPointAnnotation) {
            var annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "id")
            annotationView.canShowCallout = true
            annotationView.image = UIImage(imageLiteralResourceName: "tourist")
            return annotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        // maybe use address instead of title in case two restaurants have the same name
        guard let index = self.locationsController.items.firstIndex(where: { $0.name == view.annotation?.title}) else { return }
       
        locationsController.collectionView.scrollToItem(at: [0, index], at: .centeredHorizontally, animated: true)
    }
}

extension MainController: UITextFieldDelegate {
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        textField.resignFirstResponder()
        return true
    }
}

extension MainController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        default:
            print("No authorization permitted")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let firstLocation = locations.first else { return }
//        firstLocation.altitude
//        firstLocation.course
//        firstLocation.floor
//        firstLocation.speed
        // center the map on user location
        mkMapView.setRegion(MKCoordinateRegion(center: firstLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)), animated: false)
//        locationManager.stopUpdatingLocation()
        
    }
}

class MainController: UIViewController {
    
    let mkMapView = MKMapView()
    let searchTextField = UITextField(placeholder: "Search for location")
    var cancellable: AnyCancellable? = nil
    let locationsController = LocationsCarouselController(scrollDirection: .horizontal)
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        mkMapView.delegate = self
        searchTextField.delegate = self
        
        view.addSubview(mkMapView)
        mkMapView.fillSuperview()
        mkMapView.mapType = .standard
        mkMapView.showsUserLocation = true
        
        setupRegionForMap()
//        setupAnnotaionsForMap()
        performLocalSearch()
        setupSearchUI()
        setupLocationsCarousel()
        locationsController.mainController = self
        requestUserLocation()
        
//        mkMapView.translatesAutoresizingMaskIntoConstraints = false
//        mkMapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
//        mkMapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//        mkMapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        mkMapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    fileprivate func setupLocationsCarousel() {
        let locationsView = locationsController.view!
       
        
        view.addSubview(locationsView)
        locationsView.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, size: CGSize(width: 0, height: 150))
    }
    
    var listener: AnyCancellable!
    
    fileprivate func setupSearchUI() {
        searchTextField.textColor = .black
        let whiteContainer = UIView(backgroundColor: .white)
        view.addSubview(whiteContainer)
        whiteContainer.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 8, left: 16, bottom: 0, right: 16), size: CGSize(width: 0, height: 50))
        
        whiteContainer.stack(searchTextField).withMargins(.allSides(16))
        
//        searchTextField.addTarget(self, action: #selector(handleSearchChanges), for: .editingChanged)
        
        // search throttling - Combine
//        NotificationCenter.default
//                   .publisher(for: UITextField.textDidChangeNotification, object: searchTextField)
//                   .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
//                   .sink { (_) in
//                    print("lololololol")
//                       self.performLocalSearch()
//               }
        
        listener = NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: searchTextField)
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { _ in
                self.performLocalSearch()
        }
    }
    
    
    @objc fileprivate func handleSearchChanges() {
        performLocalSearch()
    }
    
    fileprivate func setupRegionForMap() {
        
//        let homeCoordinate = CLLocationCoordinate2D(latitude: 41.189428, longitude: -74.053212)
        let manhattanCoordinate = CLLocationCoordinate2D(latitude: 40.765671, longitude: -73.974302)
        
        let coordinateSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        
        let region = MKCoordinateRegion(center: manhattanCoordinate, span: coordinateSpan)
        
        mkMapView.setRegion(region, animated: true)
    }
    
    // not called
    fileprivate func setupAnnotaionsForMap() {
     
        let nycAnnotation = MKPointAnnotation()
        nycAnnotation.coordinate = CLLocationCoordinate2D(latitude: 40.765671, longitude: -73.974302)
        nycAnnotation.title = "New York City :)"
        nycAnnotation.subtitle = "New York"
        mkMapView.addAnnotation(nycAnnotation)
        
        let homeAnnotation = MKPointAnnotation()
        homeAnnotation.coordinate = .init(latitude: 41.189428, longitude: -74.053212)
        homeAnnotation.title = "Home Sweet Home"
        homeAnnotation.subtitle = "Pomona, NY"
        mkMapView.addAnnotation(homeAnnotation)
        mkMapView.showAnnotations(self.mkMapView.annotations, animated: true)
        mkMapView.showsScale = true
        mkMapView.showsCompass = true
       
    }
    
    fileprivate func  performLocalSearch() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTextField.text
        request.region = mkMapView.region

        let localSearch = MKLocalSearch(request: request)
        localSearch.start { (response, error) in
            
            // error
            if let error = error {
                print("Local search error ", error)
                return
            }
            
            // success
            self.mkMapView.removeAnnotations(self.mkMapView.annotations)
            self.locationsController.items.removeAll()
            
            response?.mapItems.forEach({ (mapItem) in
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = mapItem.placemark.coordinate
                annotation.title = mapItem.name
                
//                if let phone = mapItem.phoneNumber {
//                    annotation.subtitle = phone
//                }
                
//                if let mapUrl = mapItem.url {
//                     let mapUrlString = String(describing: mapUrl)
//                    annotation.subtitle = mapUrlString
//                }
                
                let placemark = mapItem.placemark
                var addressString = ""
                
                if placemark.subThoroughfare != nil {
                    addressString += placemark.subThoroughfare! + " "
                }
                
                if placemark.thoroughfare != nil {
                    addressString += placemark.thoroughfare! + " "
                }
                
                if placemark.locality != nil {
                    addressString += placemark.locality! + " "
                }
                
                if placemark.postalCode != nil {
                    addressString += placemark.postalCode! + " "
                }
                
                if placemark.subAdministrativeArea != nil {
                    addressString += placemark.subAdministrativeArea! + " "
                }
                
                if placemark.administrativeArea != nil {
                    addressString += placemark.administrativeArea! + " "
                }
                
                if placemark.country != nil {
                    addressString += placemark.country! + " "
                }
                    
                annotation.subtitle = addressString
                self.mkMapView.addAnnotation(annotation)
                
                self.locationsController.items.append(mapItem)
            })
            // for carousel
            self.locationsController.collectionView.scrollToItem(at: [0 ,0], at: .centeredHorizontally, animated: true)
            self.mkMapView.showAnnotations(self.mkMapView.annotations, animated: true)

        }
    }
    
    fileprivate func requestUserLocation() {
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
    }
}



// SwiftUI Preview
import SwiftUI

struct MainPreview: PreviewProvider {
    static var previews: some View {
//        Text("Main Preview MODIFIED")
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
       
        func makeUIViewController(context: UIViewControllerRepresentableContext<MainPreview.ContainerView>) -> MainController {
            
            return MainController()
        }
        
        func updateUIViewController(_ uiViewController: MainController, context: UIViewControllerRepresentableContext<MainPreview.ContainerView>) {
            
        }
        
        typealias UIViewControllerType = MainController
        
        
    }
}

