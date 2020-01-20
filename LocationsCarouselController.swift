//
//  File.swift
//  TravelApp
//
//  Created by daniel berger on 1/20/20.
//  Copyright © 2020 daniel berger. All rights reserved.
//

import UIKit
import LBTATools

class LocationCell: LBTAListCell<String> {
    override func setupViews() {
        backgroundColor = .yellow
        setupShadow(opacity: 0.3, radius: 5, offset: .zero, color: .black)
        layer.cornerRadius = 10
    }
}

class LocationsCarouselController: LBTAListController<LocationCell, String>, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width - 64, height: view.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 12
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .clear
        collectionView.clipsToBounds = false
        self.items = ["1", "2", "3"]
    }
}

