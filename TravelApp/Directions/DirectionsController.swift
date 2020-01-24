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

class DirectionsController: UIViewController {
    
    let mapView = MKMapView()
    let navBar = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        
        setupRegionForMap()
        setupNavBar()
        
        mapView.anchor(top: navBar.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.showsUserLocation = true

        setupStartEndDummyAnnotation()
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
        navBar.backgroundColor = #colorLiteral(red: 0.1259145737, green: 0.5621746778, blue: 0.9666383862, alpha: 1)
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
