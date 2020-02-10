//
//  PlacesController.swift
//  TravelApp
//
//  Created by dberger1 on 2/7/20.
//  Copyright © 2020 daniel berger. All rights reserved.
//

// https://console.cloud.google.com/

//import UIKit
import SwiftUI
import MapKit
import LBTATools
import GooglePlaces

class PlacesController: UIViewController, CLLocationManagerDelegate {
    
    let mapView = MKMapView()
    let locationManager = CLLocationManager()
    let client = GMSPlacesClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        mapView.fillSuperview()
//        mapView.showsCompass = true
//        mapView.showsScale = true
//        mapView.showsBuildings = true
        mapView.showsUserLocation = true
        locationManager.delegate = self
    
        requestForLocationAuthorization()
    }
    
    fileprivate func findNearByPlaces() {
        client.currentPlace { [weak self] (likelihoodList, error) in
            if let error = error {
                print("Failed to find nearby places: ", error.localizedDescription)
                return
            }
            likelihoodList?.likelihoods.forEach({(likelihood) in
                print(likelihood.place.name ?? "")
                let place = likelihood.place
                let annotation = MKPointAnnotation()
                annotation.title = place.name
//                annotation.subtitle = place.addressComponents
                annotation.coordinate = place.coordinate
                
                self?.mapView.addAnnotation(annotation)
            })
            self?.mapView.showAnnotations(self?.mapView.annotations ?? [], animated: false)
        }
    }
    
    fileprivate func requestForLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let first = locations.first else { return }
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: first.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        findNearByPlaces()
    }
}

struct PlacesController_Previews: PreviewProvider {
    static var previews: some View {
        Container().edgesIgnoringSafeArea(.all)
    }
    
    struct Container: UIViewControllerRepresentable {
//        typealias UIViewControllerType = <#type#>
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<PlacesController_Previews.Container>) -> UIViewController {
            PlacesController()
        }
        
        func updateUIViewController(_ uiViewController: PlacesController_Previews.Container.UIViewControllerType, context: UIViewControllerRepresentableContext<PlacesController_Previews.Container>) {
            
        }
    }
}
