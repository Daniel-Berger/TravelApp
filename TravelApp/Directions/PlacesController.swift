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

class PlacesController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let mapView = MKMapView()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        mapView.fillSuperview()
        mapView.delegate = self
        mapView.showsUserLocation = true
        
//        CLLocationSpeed
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        requestForLocationAuthorization()
        
//        findNearbyPlaces()
    }
    
    let client = GMSPlacesClient()
    
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
                
                ///
                self?.mapView.showAnnotations(self?.mapView.annotations ?? [], animated: false)
            })
            
//            self?.mapView.showAnnotations(self?.mapView.annotations ?? [], animated: false)
        }
    }
    
    class PlaceAnnotation: MKPointAnnotation {
        let place: GMSPlace
        init(place: GMSPlace) {
            self.place = place
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is PlaceAnnotation) {
            return nil
            
        }
        
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "id")
//        annotationView.canShowCallout = true
        
        if let placeAnnotation = annotation as? PlaceAnnotation {
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
//            print(placeAnnotation.place.types)
//            if placeAnnotation.place.types
//            annotationView.image = #imageLiteral(resourceName: "restaurant")
        }
        
        return annotationView
    }
    
    var currentCustomCallout: UIView?
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        currentCustomCallout?.removeFromSuperview()
        
        let customCalloutContainer = UIView(backgroundColor: .white)
        
//        customCalloutContainer.frame = .init(x: 0, y: 0, width: 100, height: 200)
        
        view.addSubview(customCalloutContainer)
        
        customCalloutContainer.translatesAutoresizingMaskIntoConstraints = false
        let widthAnchor = customCalloutContainer.widthAnchor.constraint(equalToConstant: 100)
        widthAnchor.isActive = true
        let heightAnchor = customCalloutContainer.heightAnchor.constraint(equalToConstant: 200)
        heightAnchor.isActive = true
        customCalloutContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        customCalloutContainer.bottomAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
        customCalloutContainer.layer.borderWidth = 1.5
        customCalloutContainer.layer.borderColor = UIColor.darkGray.cgColor
        customCalloutContainer.layer.cornerRadius = 5
        customCalloutContainer.setupShadow(opacity: 0.2, radius: 5, offset: .zero, color: .darkGray)
        
        currentCustomCallout = customCalloutContainer
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .darkGray
        spinner.startAnimating()
        customCalloutContainer.addSubview(spinner)
        spinner.fillSuperview()
        
        guard let placeId = (view.annotation as? PlaceAnnotation)?.place.placeID else { return }
        
        client.lookUpPhotos(forPlaceID: placeId) { [weak self] (metalist, error) in
            if let error = error {
                print("Error when looking up photo: ", error)
                return
            }
            
            guard let firstPhotoMetadata = metalist?.results.first else {
                print("Error getting first photo metadata")
                return
            }
            
            self?.client.loadPlacePhoto(firstPhotoMetadata) { (image, error) in
                if let error = error {
                    print("Failed to load photo for place")
                    return
                }
                
                guard let image = image else { return }
                
                if image.size.width > image.size.height {
                    let newWidth: CGFloat = 200
                    let newHeight = newWidth / image.size.width * image.size.height
                    widthAnchor.constant = newWidth
                    heightAnchor.constant = newHeight
                    
                } else {
                    let newHeight: CGFloat = 200
                    let newWidth = newHeight / image.size.height * image.size.width
                    widthAnchor.constant = newWidth
                    heightAnchor.constant = newHeight
                }
                
                let imageView = UIImageView(image: image, contentMode: .scaleAspectFill)
                customCalloutContainer.addSubview(imageView)
                imageView.layer.cornerRadius = 5
                imageView.fillSuperview()
                
                let labelContainer = UIView(backgroundColor: .white)
                let nameLabel = UILabel(text: (view.annotation as? PlaceAnnotation)?.place.name, textAlignment: .center)
                labelContainer.stack(nameLabel)
                customCalloutContainer.stack(UIView(), labelContainer.withHeight(30))
            }
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
        mapView.setRegion(region, animated: false)
        
        findNearbyPlaces()
    }
}
