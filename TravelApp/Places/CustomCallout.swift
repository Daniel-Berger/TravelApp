//
//  CustomCallout.swift
//  TravelApp
//
//  Created by dberger1 on 2/19/20.
//  Copyright © 2020 daniel berger. All rights reserved.
//

import UIKit
class CalloutContainer: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false
        
        layer.borderWidth = 1.5
        layer.borderColor = UIColor.darkGray.cgColor
        setupShadow(opacity: 0.2, radius: 5, offset: .zero, color: .darkGray)
        layer.cornerRadius = 5
        
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .darkGray
        spinner.startAnimating()
        addSubview(spinner)
        spinner.fillSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
