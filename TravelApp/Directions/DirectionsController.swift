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

        setupStartEndDummyAnnotation()
        requestForDirections()
    }
    
    fileprivate func requestForDirections() {
        let request = MKDirections.Request()

        let startingPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 40.753402, longitude: -73.982271))
        request.source = MKMapItem(placemark: startingPlacemark)
        
        let endingPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 40.706175, longitude: -74.018171))
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
        let newYorkPublicLibraryAnnotation = MKPointAnnotation()
        newYorkPublicLibraryAnnotation.coordinate = CLLocationCoordinate2D(latitude: 40.753402, longitude: -73.982271)
        newYorkPublicLibraryAnnotation.title = "start"
        
        let museumAnnotation = MKPointAnnotation()
        museumAnnotation.coordinate = CLLocationCoordinate2D(latitude: 40.706175, longitude: -74.018171)
        museumAnnotation.title = "end"
        
        mapView.addAnnotation(newYorkPublicLibraryAnnotation)
        mapView.addAnnotation(museumAnnotation)
        
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    fileprivate func setupNavBar() {
        navBar.backgroundColor = #colorLiteral(red: 0.1259145737, green: 0.5621746778, blue: 0.9666383862, alpha: 1) //colorLiteral
        view.addSubview(navBar)
        navBar.setupShadow(opacity: 0.5, radius: 5)
        navBar.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: -100, right: 0))

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
//        Text("Hello DirectionController World!")
        ContainterView().edgesIgnoringSafeArea(.all)
            .environment(\.colorScheme, .dark)
    }
    
    struct ContainterView: UIViewControllerRepresentable {
        
        typealias UIViewControllerType = DirectionsController
        

        func makeUIViewController(context: UIViewControllerRepresentableContext<DirectionsPreview.ContainterView>) -> DirectionsPreview.ContainterView.UIViewControllerType {
            return DirectionsController()
        }
        
        func updateUIViewController(_ uiViewController: DirectionsPreview.ContainterView.UIViewControllerType, context: UIViewControllerRepresentableContext<DirectionsPreview.ContainterView>) {
            
        }
        
    }
}
