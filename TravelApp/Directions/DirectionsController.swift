//
//  DirectionsController.swift
//  TravelApp
//
//  Created by daniel berger on 1/24/20.
//  Copyright © 2020 daniel berger. All rights reserved.
//

import UIKit
import SwiftUI
import MapKit
import LBTATools

extension DirectionsController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = #colorLiteral(red: 0.1247136965, green: 0.5529010892, blue: 0.950386107, alpha: 1)
        polylineRenderer.lineWidth = 5
        return polylineRenderer
    }
}

class DirectionsController: UIViewController {
    
    let mapView = MKMapView()
    let navBar = UIView()
    let startTextField = IndentedTextField(padding: 12, cornerRadius: 5) // LBTATools
    let endTextField = IndentedTextField(padding: 12, cornerRadius: 5)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        view.addSubview(mapView)
        
        setupRegionForMap()
        setupNavBar()
        
        mapView.anchor(top: navBar.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.showsUserLocation = true

//        setupStartEndDummyAnnotation()
//        requestForDirections()
    }
    
    fileprivate func requestForDirections() {
        let request = MKDirections.Request()

        let startingPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 41.189244, longitude: -74.054350))
        request.source = MKMapItem(placemark: startingPlacemark)
        
        let endingPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 40.625086, longitude: -73.954562))
        request.destination = MKMapItem(placemark: endingPlacemark)
        
//        request.requestsAlternateRoutes
//        request.transportType = MKDirectionsTransportType.walking
        request.transportType = MKDirectionsTransportType.automobile
        request.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            if let error = error {
                print("Failed to calculate direction ", error)
                return
            }
            
            print("Found directions routing...")
//            guard let route = response?.routes.first else { return }
//            print("route.steps: ",route.steps)
//            print("route.expectedTravelTime: ",route.expectedTravelTime) // in seconds
//            print("Travel time is: ",(route.expectedTravelTime / 60 / 60))
//            print("route.advisoryNotices: ",route.advisoryNotices)
//            print("route.polyline: ",route.polyline)

            // show all possible routes
            response?.routes.forEach({ (route) in
                self.mapView.addOverlay(route.polyline)
            })
            
//            self.mapView.addOverlay(route.polyline)
        }
    }
    
    fileprivate func setupStartEndDummyAnnotation() {
        let startPointAnnotation = MKPointAnnotation()
        startPointAnnotation.coordinate = CLLocationCoordinate2D(latitude: 41.189244, longitude: -74.054350)
        startPointAnnotation.title = "start"
        
        let endPointAnnotation = MKPointAnnotation()
        endPointAnnotation.coordinate = CLLocationCoordinate2D(latitude: 40.625086, longitude: -73.954562)
        endPointAnnotation.title = "end"
        
        mapView.addAnnotation(startPointAnnotation)
        mapView.addAnnotation(endPointAnnotation)
        
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    fileprivate func setupNavBar() {
        navBar.backgroundColor = #colorLiteral(red: 0.1259145737, green: 0.5621746778, blue: 0.9666383862, alpha: 1) //colorLiteral
        view.addSubview(navBar)
        navBar.setupShadow(opacity: 0.5, radius: 5)
        navBar.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: -120, right: 0))

        startTextField.attributedPlaceholder = NSAttributedString(string: "Start", attributes: [.foregroundColor : UIColor.white])
        endTextField.attributedPlaceholder = NSAttributedString(string: "Destination", attributes: [.foregroundColor : UIColor.white])

        [startTextField, endTextField].forEach { (textField) in
            textField.backgroundColor = .init(white: 1, alpha: 0.3)
            textField.textColor = .white
        }
        
        let containerView = UIView(backgroundColor: .clear)
        navBar.addSubview(containerView)
        containerView.fillSuperviewSafeAreaLayoutGuide()
        
        let startIcon = UIImageView(image: UIImage(named: "start-location-icon"), contentMode: .scaleAspectFit)
        startIcon.constrainWidth(20)
        
        let endIcon = UIImageView(image: UIImage(named: "end-location-icon")?.withRenderingMode(.alwaysTemplate), contentMode: .scaleAspectFit)
        endIcon.constrainWidth(20)
        endIcon.tintColor = .white
        
        containerView.stack(
            containerView.hstack(startIcon, startTextField, spacing: 16),
            containerView.hstack(endIcon, endTextField, spacing: 16),
                                 spacing: 12,
                                 distribution: .fillEqually)
        .withMargins(UIEdgeInsets(top: 0, left: 16, bottom: 12, right: 16))
        
        startTextField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleChangeStartLocation)))
        
        endTextField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleChangeEndLocation)))
        
        navigationController?.navigationBar.isHidden = true
    }
    
    @objc fileprivate func handleChangeStartLocation() {
       let vc = LocationSearchController()
        vc.selectionHandler = { [weak self] mapItem in
            self?.startTextField.text = mapItem.name
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc fileprivate func handleChangeEndLocation() {
        let vc = LocationSearchController()
        vc.selectionHandler = { [weak self] mapItem in
            self?.endTextField.text = mapItem.name
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    fileprivate func setupRegionForMap() {
        
        let homeCoordinate = CLLocationCoordinate2D(latitude: 41.189428, longitude: -74.053212)
        let manhattanCoordinate = CLLocationCoordinate2D(latitude: 40.765671, longitude: -73.974302)
        
        let coordinateSpan = MKCoordinateSpan(latitudeDelta: 0.09, longitudeDelta: 0.09)
        let region = MKCoordinateRegion(center: manhattanCoordinate, span: coordinateSpan)
        mapView.setRegion(region, animated: true)
    }
}


struct DirectionsPreview: PreviewProvider {
    
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
//            .environment(\.colorScheme, .light)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<DirectionsPreview.ContainerView>) -> UIViewController {
            return UINavigationController(rootViewController: DirectionsController())
        }
        
        func updateUIViewController(_ uiViewController: DirectionsPreview.ContainerView.UIViewControllerType, context: UIViewControllerRepresentableContext<DirectionsPreview.ContainerView>) {
            
        }
        
    }
    
}

