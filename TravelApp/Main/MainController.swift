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
        
        var annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "id")
        annotationView.canShowCallout = true
        annotationView.image = UIImage(imageLiteralResourceName: "tourist")
        
        return annotationView
    }
}

class MainController: UIViewController {
    
    let mkMapView = MKMapView()
    let searchTextField = UITextField(placeholder: "Search for location")
    var cancellable: AnyCancellable? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        mkMapView.delegate = self
        view.addSubview(mkMapView)
        mkMapView.fillSuperview()
        mkMapView.mapType = .standard
        
        setupRegionForMap()
//        setupAnnotaionsForMap()
        performLocalSearch()
        
        setupSearchUI()
        
//        mkMapView.translatesAutoresizingMaskIntoConstraints = false
//        mkMapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
//        mkMapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//        mkMapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        mkMapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    fileprivate func setupSearchUI() {
        searchTextField.textColor = .black
        let whiteContainer = UIView(backgroundColor: .white)
        view.addSubview(whiteContainer)
        whiteContainer.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16), size: CGSize(width: 0, height: 50))
        
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
        
        self.cancellable = NotificationCenter.default
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
        
        let homeCoordinate = CLLocationCoordinate2D(latitude: 41.189428, longitude: -74.053212)
        let manhattanCoordinate = CLLocationCoordinate2D(latitude: 40.765671, longitude: -73.974302)
        
        let coordinateSpan = MKCoordinateSpan(latitudeDelta: 0.09, longitudeDelta: 0.09)
        
        let region = MKCoordinateRegion(center: manhattanCoordinate, span: coordinateSpan)
        
        mkMapView.setRegion(region, animated: true)
    }
    
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
                self.mkMapView.showAnnotations(self.mkMapView.annotations, animated: true)

            })
        }
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
