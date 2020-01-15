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
        mkMapView.mapType = .hybridFlyover
        
//        mkMapView.translatesAutoresizingMaskIntoConstraints = false
//        mkMapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
//        mkMapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//        mkMapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        mkMapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
    }
    
}
