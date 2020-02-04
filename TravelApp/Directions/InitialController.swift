//
//  InitialController.swift
//  TravelApp
//
//  Created by dberger1 on 2/4/20.
//  Copyright © 2020 daniel berger. All rights reserved.
//

import SwiftUI
import UIKit
import CircleMenu
import Pastel

extension UIColor {
    static func color(_ red: Int, green: Int, blue: Int, alpha: Float) -> UIColor {
        return UIColor(
            red: 1.0 / 255.0 * CGFloat(red),
            green: 1.0 / 255.0 * CGFloat(green),
            blue: 1.0 / 255.0 * CGFloat(blue),
            alpha: CGFloat(alpha))
    }
}

class InitialController: UIViewController, CircleMenuDelegate {
    
    var pastelView: PastelView?
    var circleMenu: CircleMenu?
    
    let items: [(icon: String, color: UIColor)] = [
        ("icon_home", UIColor(red: 0.19, green: 0.57, blue: 1, alpha: 1)),
        ("icon_search", UIColor(red: 0.22, green: 0.74, blue: 0, alpha: 1)),
        ("notifications-btn", UIColor(red: 0.96, green: 0.23, blue: 0.21, alpha: 1)),
        ("settings-btn", UIColor(red: 0.51, green: 0.15, blue: 1, alpha: 1)),
        ("nearby-btn", UIColor(red: 1, green: 0.39, blue: 0, alpha: 1))
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPatel()
        setupCircleMenuButton()
        callPressButton()
    }
    
    fileprivate func callPressButton() {
        perform(#selector(pressButton), with: nil, afterDelay: 2)
    }
    
    @objc fileprivate func pressButton() {
        circleMenu?.sendActions(for: .touchUpInside)
    }
    
    fileprivate func setupPatel() {
        self.pastelView = PastelView(frame: view.frame)
        
        guard let myPastelView = pastelView else { return }
        myPastelView.startPastelPoint = .bottomLeft
        myPastelView.endPastelPoint = .topRight
        myPastelView.animationDuration = 2.0
        myPastelView.setColors([UIColor(red: 156/255, green: 39/255, blue: 176/255, alpha: 1.0),
                               UIColor(red: 255/255, green: 64/255, blue: 129/255, alpha: 1.0),
                               UIColor(red: 123/255, green: 31/255, blue: 162/255, alpha: 1.0),
                               UIColor(red: 32/255, green: 76/255, blue: 255/255, alpha: 1.0),
                               UIColor(red: 32/255, green: 158/255, blue: 255/255, alpha: 1.0),
                               UIColor(red: 90/255, green: 120/255, blue: 127/255, alpha: 1.0),
                               UIColor(red: 58/255, green: 255/255, blue: 217/255, alpha: 1.0)])
        myPastelView.startAnimation()
        view.insertSubview(myPastelView, at: 0)
    }
    
    fileprivate func setupCircleMenuButton() {
        
//        guard let myCircleButton = circleMenu else { return }
        self.circleMenu = CircleMenu(
               frame: CGRect(x: 200, y: 200, width: 60, height: 60),
               normalIcon:"icon_menu",
               selectedIcon:"icon_close",
               buttonsCount: 5,
               duration: 0.3,
               distance: 120
        )
        circleMenu!.backgroundColor = UIColor.lightGray
        circleMenu!.delegate = self
        circleMenu!.layer.cornerRadius = circleMenu!.frame.size.width / 2.0
        pastelView!.addSubview(circleMenu!)
        circleMenu!.center = view.center
        
        
//        let button = CircleMenu(
//               frame: CGRect(x: 200, y: 200, width: 60, height: 60),
//               normalIcon:"icon_menu",
//               selectedIcon:"icon_close",
//               buttonsCount: 5,
//               duration: 0.3,
//               distance: 120)
//        button.backgroundColor = UIColor.lightGray
//        button.delegate = self
//        button.layer.cornerRadius = button.frame.size.width / 2.0
//        pastelView!.addSubview(button)
//        button.center = view.center
    }
        
    // configure buttons
    func circleMenu(_ circleMenu: CircleMenu, willDisplay button: UIButton, atIndex: Int) {
        button.backgroundColor = items[atIndex].color
        button.setImage(UIImage(named: items[atIndex].icon), for: .normal)

       // set highlited image
        let highlightedImage = UIImage(named: items[atIndex].icon)?.withRenderingMode(.alwaysTemplate)
        button.setImage(highlightedImage, for: .highlighted)
        button.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
    }

    // call before animation
    func circleMenu(_ circleMenu: CircleMenu, buttonWillSelected button: UIButton, atIndex: Int) {
        
    }

    // call after animation
    func circleMenu(_ circleMenu: CircleMenu, buttonDidSelected button: UIButton, atIndex: Int) {

        switch atIndex {
             case 0:
             print("First Button")
             case 1:
             print("Second Button")
            present(UINavigationController(rootViewController: DirectionsController()), animated: true, completion: nil)
             case 2:
             print("Third Button")
             case 3:
             print("Fourth Button")
             default:
                 ("Unknown Button")
             }

    }

    // call upon cancel of the menu - fires immediately on button press
    func menuCollapsed(_ circleMenu: CircleMenu) {
        
    }

    // call upon opening of the menu - fires immediately on button press
    func menuOpened(_ circleMenu: CircleMenu) {
        
    }
    
}



struct InitialController_Previews: PreviewProvider {
      static var previews: some View {
            ContainerView().edgesIgnoringSafeArea(.all)
        }
        
    struct ContainerView: UIViewControllerRepresentable {
        func makeUIViewController(context: UIViewControllerRepresentableContext<InitialController_Previews.ContainerView>) -> UIViewController {
            return InitialController()
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<InitialController_Previews.ContainerView>) {
            
        }
        
    }
}
