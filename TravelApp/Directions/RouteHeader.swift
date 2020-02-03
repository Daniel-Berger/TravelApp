//
//  RouteHeader.swift
//  TravelApp
//
//  Created by dberger1 on 2/3/20.
//  Copyright © 2020 daniel berger. All rights reserved.
//

import SwiftUI
import MapKit

class RouteHeader: UICollectionReusableView {
    
    let nameLabel = UILabel(text: "Route Name", font: .systemFont(ofSize: 16))
    let distanceLabel = UILabel(text: "Distance", font: .systemFont(ofSize: 16))
    let estimatedTimeLabel = UILabel(text: "Est time...", font: .systemFont(ofSize: 16))
       
       override init(frame: CGRect) {
           super.init(frame: frame)

        hstack(stack (nameLabel,
                      distanceLabel,
                      estimatedTimeLabel,
                      spacing: 8),
               alignment: .center
        ).withMargins(.allSides(16))
        
        nameLabel.attributedText = generateAttributedString(title: "Title", description: "description")

        distanceLabel.attributedText = generateAttributedString(title: "Distance", description: "description")

        estimatedTimeLabel.attributedText = generateAttributedString(title: "Estimated Time", description: "description")

    }
       
       required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
    
    func setupHeaderInformation(route: MKRoute) {
        nameLabel.attributedText = generateAttributedString(title: "Route", description: route.name)
        let milesDistance = route.distance * 0.00062137
        let milesString = String(format: "%.2f mi", milesDistance)
        
        
        distanceLabel.attributedText = generateAttributedString(title: "Distance", description: milesString)

        var timeString = ""
        if route.expectedTravelTime > 3600 {
            let h = Int(route.expectedTravelTime / 60 / 60)
            let m = Int((route.expectedTravelTime.truncatingRemainder(dividingBy: 60 * 60)) / 60)
            timeString = String(format: "%d hr %d min", h, m)
        } else {
            let time = Int(route.expectedTravelTime / 60)
            timeString = String (format: "%d min", time)
        }
        estimatedTimeLabel.attributedText = generateAttributedString(title: "Est Time", description: timeString)

    }
    
    func generateAttributedString(title: String, description: String) -> NSAttributedString {
        
        let attributedString = NSMutableAttributedString(string: title + ": ", attributes: [.font: UIFont.boldSystemFont(ofSize: 16)])
        
        attributedString.append(.init(string: description, attributes: [.font: UIFont.systemFont(ofSize: 16)]))
  
        return attributedString
    }
       
       
   }
   

//struct RouteHeader: View {
//    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//    }
//}

struct RouteHeader_Previews: PreviewProvider {
    static var previews: some View {
//        RouteHeader()
//        Text("Route Header")
        Container()
    }
    
    struct Container: UIViewRepresentable {
        
        func makeUIView(context: UIViewRepresentableContext<RouteHeader_Previews.Container>) -> UIView {
            return RouteHeader()
        }
        
        func updateUIView(_ uiView: RouteHeader_Previews.Container.UIViewType, context: UIViewRepresentableContext<RouteHeader_Previews.Container>) {
            
        }
    }
}
