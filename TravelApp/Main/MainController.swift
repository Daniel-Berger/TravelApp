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

class MainController: UIViewController {
    
     let mkMapView = MKMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        view.addSubview(mkMapView)
        mkMapView.fillSuperview()
        mkMapView.mapType = .standard
        
        setupRegionForMap()
//        mkMapView.translatesAutoresizingMaskIntoConstraints = false
//        mkMapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
//        mkMapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//        mkMapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        mkMapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
    }
    
    fileprivate func setupRegionForMap() {
        
        let homeCoordinate = CLLocationCoordinate2D(latitude: 41.189428, longitude: -74.053212)
        let manhattanCoordinate = CLLocationCoordinate2D(latitude: 40.765671, longitude: -73.974302)
        
        let coordinateSpan = MKCoordinateSpan(latitudeDelta: 0.09, longitudeDelta: 0.09)
        
        let region = MKCoordinateRegion(center: manhattanCoordinate, span: coordinateSpan)
        
        mkMapView.setRegion(region, animated: true)
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
