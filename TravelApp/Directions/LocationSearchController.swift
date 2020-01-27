//
//  LocationSearchController.swift
//  TravelApp
//
//  Created by daniel berger on 1/27/20.
//  Copyright © 2020 daniel berger. All rights reserved.
//

import SwiftUI
import UIKit
import MapKit
import LBTATools

class LocationSearchCell: LBTAListCell<MKMapItem> {
    
    let nameLabel = UILabel(text: "Name Label", font: .boldSystemFont(ofSize: 16))
    let addressLabel = UILabel(text: "Address Label", font: .boldSystemFont(ofSize: 14))
    
    override var item: MKMapItem! {
        didSet {
            nameLabel.text = item.name
            addressLabel.text = item.address()
        }
    }
    
    override func setupViews() {
        stack(nameLabel, addressLabel).withMargins(.allSides(16))
        addSeparatorView(leftPadding: 16)
    }
}

class LocationSearchController: LBTAListController<LocationSearchCell, MKMapItem> {
    
    var selectionHandler: ((MKMapItem) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        performLocalSearch()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        navigationController?.popViewController(animated: true)
        let mapItem = self.items[indexPath.item]
        selectionHandler?(mapItem)
    }
    
    fileprivate func performLocalSearch() {
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Apple"
//        request.region
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            
            if error != nil {
                print("Local search error: ", error)
                return
            }
            
            print(response?.mapItems)
            self.items = response?.mapItems ?? []
        }
    }
}


extension LocationSearchController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return .init(width: view.frame.width, height: 80)
    }
}


struct LocationSearchController_Previews: PreviewProvider {
    
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        typealias UIViewControllerType = LocationSearchController

        func makeUIViewController(context: UIViewControllerRepresentableContext<LocationSearchController_Previews.ContainerView>) -> LocationSearchController {
            LocationSearchController()
        }
        
        func updateUIViewController(_ uiViewController: LocationSearchController, context: UIViewControllerRepresentableContext<LocationSearchController_Previews.ContainerView>) {
            
        }
    }
}
