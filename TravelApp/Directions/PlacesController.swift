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
    // HUD Label
    let hudNameLabel = UILabel(text: "Name", font: .boldSystemFont(ofSize: 16))
    let hudAddressLabel = UILabel(text: "Address", font: .boldSystemFont(ofSize: 16))
    let hudTypeLabel = UILabel(text: "Types", textColor: .gray)
    lazy var infoButton = UIButton(type: .infoLight)
    let hudContainter = UIView(backgroundColor: .white)
    
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
        setupSelectedAnnotationHUD()
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
    
    fileprivate func setupSelectedAnnotationHUD() {
        view.addSubview(hudContainter)
        hudContainter.layer.cornerRadius = 5
        hudContainter.setupShadow(opacity: 0.2, radius: 5, offset: .zero, color: .darkGray)
        hudContainter.anchor(top: nil, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: .allSides(16), size: .init(width: 0, height: 125))
        
        let topRow = UIView()
        topRow.hstack(hudNameLabel, infoButton.withWidth(44))
        hudContainter.hstack(hudContainter.stack(topRow,
                                                 hudAddressLabel,
                                                 hudTypeLabel, spacing: 8),
                             alignment: .center).withMargins(.allSides(16))
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
    
    fileprivate func setupHUD(view: MKAnnotationView) {
        guard let annotation = view.annotation as? PlaceAnnotation else { return }
        
        let place = annotation.place
        hudNameLabel.text = place.name
        hudAddressLabel.text = place.formattedAddress
        hudTypeLabel.text = place.types?.joined(separator: ", ")
    }
    
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        setupHUD(view: view)
        
        currentCustomCallout?.removeFromSuperview()
        
        let customCalloutContainer = CalloutContainer()
        
        view.addSubview(customCalloutContainer)
        
        let widthAnchor = customCalloutContainer.widthAnchor.constraint(equalToConstant: 100)
        widthAnchor.isActive = true
        let heightAnchor = customCalloutContainer.heightAnchor.constraint(equalToConstant: 200)
        heightAnchor.isActive = true
        customCalloutContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        customCalloutContainer.bottomAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
        currentCustomCallout = customCalloutContainer
        
        
        guard let firstPhotoMetadata = (view.annotation as? PlaceAnnotation)?.place.photos?.first else {
            print("Error getting first photo metadata")
            return
        }
        
        self.client.loadPlacePhoto(firstPhotoMetadata) { [weak self] (image, error) in
            if let error = error {
                print("Failed to load photo for place")
                return
            }
            
            guard let image = image else { return }
            guard let bestSize = self?.bestCalloutImageSize(image: image) else { return }
            widthAnchor.constant = bestSize.width
            heightAnchor.constant = bestSize.height
            
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
    
    fileprivate func bestCalloutImageSize(image: UIImage) -> CGSize {
        if image.size.width > image.size.height {
            let newWidth: CGFloat = 300
            let newHeight = newWidth / image.size.width * image.size.height
            return .init(width: newWidth, height: newHeight)
        } else {
            let newHeight: CGFloat = 200
            let newWidth = newHeight / image.size.height * image.size.width
            return .init(width: newWidth, height: newHeight)
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
