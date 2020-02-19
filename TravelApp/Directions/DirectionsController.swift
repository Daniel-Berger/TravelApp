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
import JGProgressHUD

extension DirectionsController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = #colorLiteral(red: 0.1247136965, green: 0.5529010892, blue: 0.950386107, alpha: 1) // color literal
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
        
        setupShowRouteButton()
    }
    
    fileprivate func setupShowRouteButton() {
        let showRouteButton = UIButton(title: "Show Route", titleColor: .white, font: .boldSystemFont(ofSize: 16), backgroundColor:  #colorLiteral(red: 0.1247136965, green: 0.5529010892, blue: 0.950386107, alpha: 1), target: self, action: #selector(handleShowRoute))
        view.addSubview(showRouteButton)
        
        showRouteButton.anchor(top: nil, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: .allSides(16), size: CGSize(width: 0, height: 50))
        
    }
    
    @objc fileprivate func handleShowRoute() {
        let routesController = RoutesController()
        routesController.route = currentlyShowingRoute
        currentlyShowingRoute?.distance
        
        routesController.items = self.currentlyShowingRoute?.steps.filter{ !$0.instructions.isEmpty } ?? []
        present(routesController, animated: true, completion: nil)
    }
    
    class RouteStepCell: LBTAListCell<MKRoute.Step> {
        
        let nameLabel = UILabel(text: "Name", numberOfLines: 0)
        let distanceLabel = UILabel(text: "Distance", textAlignment: .right)
        
        override var item: MKRoute.Step! {
            didSet {
                nameLabel.text = item.instructions
                let milesConversion = item.distance * 0.00062137
//                distanceLabel.text = "\(milesConversion)"
                distanceLabel.text = String(format: "%.2f mi", milesConversion)
            }
        }
        
        override func setupViews() {
            hstack(nameLabel, distanceLabel.withWidth(80)).withMargins(.allSides(16))
            addSeparatorView(leadingAnchor: nameLabel.leadingAnchor)
        }
    }
    
   
    class RoutesController: LBTAListHeaderController<RouteStepCell, MKRoute.Step, RouteHeader>, UICollectionViewDelegateFlowLayout {
        
        var route: MKRoute!
//        gurad let currentRoute = route else { return }
        
        override func setupHeader(_ header: RouteHeader) {
            header.setupHeaderInformation(route: route)
//            header.nameLabel.attributedText = header.generateAttributedString(title: "Route", description: route.name)
//
//            let milesDistance = route.distance * 0.00062137
//            let milesString = String(format: "%.2f mi", milesDistance)
//            header.distanceLabel.attributedText = header.generateAttributedSTring(title: "Distance", description: milesString)
//            
//            var timeString = ""
//            if route.expectedTravelTime > 3600 {
//                let h = Int(route.expectedTravelTime / 60 / 60)
//                let m = Int((route.expectedTravelTime.truncatingRemainder(dividingBy: 60 * 60)) / 60)
//                timeString = String(format: "%d hr %d min", h, m)
//            } else {
//                let time = Int(route.expectedTravelTime / 60)
//                timeString = String (format: "%d min", time)
//            }
//            header.estimatedTimeLabel.attributedText =  header.generateAttributedSTring(title: "Estimated time", description: timeString)
        }
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
//            collectionView.register(<#T##viewClass: AnyClass?##AnyClass?#>, forSupplementaryViewOfKind: <#T##String#>, withReuseIdentifier: <#T##String#>)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            .init(width: view.frame.width, height: 70)
        }
        
//        override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//
//        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
            .init(width: 0, height: 120)
        }
    }
    
    var currentlyShowingRoute: MKRoute?
    
    fileprivate func requestForDirections() {
        let request = MKDirections.Request()
        request.source = startMapItem
        request.destination = endMapItem

//        request.transportType = MKDirectionsTransportType.automobile
//        request.requestsAlternateRoutes = true
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Routing..."
        hud.show(in: view)
        
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            hud.dismiss()
            
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
//            response?.routes.forEach({ (route) in
//                self.mapView.addOverlay(route.polyline)
//            })
            if let firstRoute = response?.routes.first {
                self.mapView.addOverlay(firstRoute.polyline)
            }
            
            self.currentlyShowingRoute = response?.routes.first
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
        
        // OVer HEre 
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
    
    var startMapItem: MKMapItem?
    var endMapItem: MKMapItem?
    
    @objc fileprivate func handleChangeStartLocation() {
       let vc = LocationSearchController()
        vc.selectionHandler = { [weak self] mapItem in
            self?.startTextField.text = mapItem.name
            self?.startMapItem = mapItem
            self?.refreshMap()
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func refreshMap() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        if let mapItem = startMapItem {
                let annotation = MKPointAnnotation()
                annotation.coordinate = mapItem.placemark.coordinate
                annotation.title = mapItem.name
                self.mapView.addAnnotation(annotation)
//            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        }
        
        if let mapItem = endMapItem {
                let annotation = MKPointAnnotation()
                annotation.coordinate = mapItem.placemark.coordinate
                annotation.title = mapItem.name
                self.mapView.addAnnotation(annotation)
//            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
              }
        
        requestForDirections()
        mapView.showAnnotations(self.mapView.annotations, animated: true)
    }
    
    @objc fileprivate func handleChangeEndLocation() {
        let vc = LocationSearchController()
        vc.selectionHandler = { [weak self] mapItem in
            self?.endTextField.text = mapItem.name
            self?.endMapItem = mapItem
            self?.refreshMap()
        }
        requestForDirections()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    fileprivate func setupRegionForMap() {
        
        let homeCoordinate = CLLocationCoordinate2D(latitude: 41.189428, longitude: -74.053212)
        let manhattanCoordinate = CLLocationCoordinate2D(latitude: 40.765671, longitude: -73.974302)
        
        let coordinateSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
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

