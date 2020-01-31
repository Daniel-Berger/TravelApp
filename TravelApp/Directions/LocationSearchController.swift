//
//  LocationSearchController.swift
//  TravelApp
//
//  Created by daniel berger on 1/27/20.
//  Copyright © 2020 daniel berger. All rights reserved.
//

import SwiftUI
import UIKit
import Combine
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationController?.popViewController(animated: true)
        let mapItem = self.items[indexPath.item]
        selectionHandler?(mapItem)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.becomeFirstResponder()
        
        performLocalSearch()
        setupSearchBar()
    }
    
    let searchTextField = IndentedTextField(placeholder: "Enter search term", padding: 12)

    let backIcon = UIButton(image: UIImage(imageLiteralResourceName: "back-arrow"), tintColor: .black, target: self, action: #selector(handleBack)).withWidth(32)
    @objc fileprivate func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    let navBarHeight: CGFloat = 66
    
    fileprivate func setupSearchBar() {
        let navBar = UIView(backgroundColor: .white)
        view.addSubview(navBar)
        navBar.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: -navBarHeight, right: 0))
        
        // fix scrollbar insets
        collectionView.verticalScrollIndicatorInsets.top = navBarHeight

        let container = UIView(backgroundColor: .clear)
        navBar.addSubview(container)
        container.fillSuperviewSafeAreaLayoutGuide()
        container.hstack(backIcon, searchTextField, spacing: 12).withMargins(.init(top: 0, left: 16, bottom: 16, right: 16))
        searchTextField.layer.borderWidth = 2
        searchTextField.layer.borderColor = UIColor.lightGray.cgColor
        searchTextField.layer.cornerRadius = 5
        searchTextField.textColor = .black

        setupSearchListener()
    }
    
    var listener: AnyCancellable!
    
    fileprivate func setupSearchListener() {
        // search throttling
        listener = NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: searchTextField).debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] (_) in
                self?.performLocalSearch()
        }
    }

    // fix items under search bar
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: navBarHeight, left: 0, bottom: 0, right: 0)
    }
    
    fileprivate func performLocalSearch() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTextField.text
        
        let search = MKLocalSearch.init(request: request)
        search.start { (resp, err) in
            // check err
            self.items = resp?.mapItems ?? []
        }
    }
}

extension LocationSearchController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: 70)
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
