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

// 12:00

class PlacesController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let mapView = MKMapView()
    let locationManager = CLLocationManager()
    let client = GMSPlacesClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        mapView.fillSuperview()
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.showsBuildings = true
        mapView.showsUserLocation = true
        mapView.delegate = self
        locationManager.delegate = self

        requestForLocationAuthorization()
    }

/*
    fileprivate func findNearByPlaces() {
        client.currentPlace { [weak self] (likelihoodList, error) in
            if let error = error {
                print("Failed to find nearby places: ", error.localizedDescription)
                return
            }
            
            likelihoodList?.likelihoods.forEach({ (likelihood) in
                let place = likelihood.place
//                let annotation = MKPointAnnotation()
                let annotation = PlaceAnnotation(place: place)
                annotation.title = place.name
                annotation.subtitle = place.formattedAddress ?? ""
                annotation.coordinate = place.coordinate
                
                self?.mapView.addAnnotation(annotation)
            })
            self?.mapView.showAnnotations(self?.mapView.annotations ?? [], animated: false)
        }
    }
*/
    fileprivate func findNearbyPlaces() {
        client.currentPlace { [weak self] (likelihoodList, err) in
            if let err = err {
                print("Failed to find current place:", err)
                return
            }
            
            likelihoodList?.likelihoods.forEach({  (likelihood) in
                print(likelihood.place.name ?? "")
                
                let place = likelihood.place
                
                let annotation = PlaceAnnotation(place: place)
                annotation.title = place.name
                annotation.coordinate = place.coordinate
                
                self?.mapView.addAnnotation(annotation)
            })
            
            self?.mapView.showAnnotations(self?.mapView.annotations ?? [], animated: false)
        }
    }
    
    class PlaceAnnotation: MKPointAnnotation {
        let place: GMSPlace
        init(place: GMSPlace) {
            self.place = place
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
 
/*
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let first = locations.first else { return }
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: first.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        findNearbyPlaces()
    }
*/
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
          guard let first = locations.first else { return }
          let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
          let region = MKCoordinateRegion(center: first.coordinate, span: span)
          mapView.setRegion(region, animated: false)
          
          findNearbyPlaces()
      }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if !(annotation is PlaceAnnotation) {
            print("Annotation is nil!!!")
            return nil
        }
        
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "id")
        annotationView.canShowCallout = true
        
        if let placeAnnotation = annotation as? PlaceAnnotation {
            print("places types: ",placeAnnotation.place.types)
            // cafe, bar, point_of_interest, clothing_store, lodging, tourist_attraction
            let types = placeAnnotation.place.types
            if let firstType = types?.first {
                if firstType == "bar" {
                    annotationView.image = #imageLiteral(resourceName: "bar")
                } else if firstType == "restaurant" {
                    annotationView.image = #imageLiteral(resourceName: "restaurant")
                } else {
                    annotationView.image = #imageLiteral(resourceName: "tourist")
                }
            }
//            annotationView.image = #imageLiteral(resourceName: "default")
        }
        
        return annotationView
    }
    
    var currentCustomCallout: UIView?
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        currentCustomCallout?.removeFromSuperview()
        
        let customCalloutContainer = UIView(backgroundColor: .red)
        view.addSubview(customCalloutContainer)
        
        customCalloutContainer.translatesAutoresizingMaskIntoConstraints = false
        customCalloutContainer.heightAnchor.constraint(equalToConstant: 200).isActive = true
        customCalloutContainer.widthAnchor.constraint(equalToConstant: 100).isActive = true
        customCalloutContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        customCalloutContainer.bottomAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
        currentCustomCallout = customCalloutContainer
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
