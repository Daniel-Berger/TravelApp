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
import GradientAnimator

extension UIColor {
    static func color(_ red: Int, green: Int, blue: Int, alpha: Float) -> UIColor {
        return UIColor(
            red: 1.0 / 255.0 * CGFloat(red),
            green: 1.0 / 255.0 * CGFloat(green),
            blue: 1.0 / 255.0 * CGFloat(blue),
            alpha: CGFloat(alpha))
    }
    
//    inputColors: [#colorLiteral(red: 0.9195817113, green: 0.04345837981, blue: 0.7682360411, alpha: 1),#colorLiteral(red: 0.1406921148, green: 0.05199617893, blue: 0.8817588687, alpha: 1),#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1),#colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1),#colorLiteral(red: 0.9725490196, green: 0.7647058824, blue: 0.8039215686, alpha: 1)]
    
//    inputColors: [#colorLiteral(red: 0.9195817113, green: 0.04345837981, blue: 0.7682360411, alpha: 1),#colorLiteral(red: 0.1406921148, green: 0.05199617893, blue: 0.8817588687, alpha: 1),#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1),#colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1),#colorLiteral(red: 0.9725490196, green: 0.7647058824, blue: 0.8039215686, alpha: 1)]
}

class InitialController: UIViewController, CircleMenuDelegate {
    
    var gradientView: GradientAnimator?
    var circleMenu: CircleMenu?
    var buttonPressed = false
    
    
    let items: [(icon: String, color: UIColor)] = [
        ("icon_home", UIColor(red: 0.19, green: 0.57, blue: 1, alpha: 1)),
        ("icon_search", UIColor(red: 0.22, green: 0.74, blue: 0, alpha: 1)),
        ("notifications-btn", UIColor(red: 0.96, green: 0.23, blue: 0.21, alpha: 1)),
        ("settings-btn", UIColor(red: 0.51, green: 0.15, blue: 1, alpha: 1)),
        ("nearby-btn", UIColor(red: 1, green: 0.39, blue: 0, alpha: 1))
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGradientAnimator()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        setupCircleMenuButton()
        setupWelcomeLabel()
        if buttonPressed == false {
            let timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(pressButton), userInfo: nil, repeats: false)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetup), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    @objc fileprivate func resetup() {
        print("woohoo!")
        setupCircleMenuButton()
        setupWelcomeLabel()
    }
    
    fileprivate func setupWelcomeLabel() {
        let label = UILabel(text: "Explore New York City", font: UIFont.boldSystemFont(ofSize: 24), textColor: .white, textAlignment: .center, numberOfLines: 1)
        label.translatesAutoresizingMaskIntoConstraints = false

        gradientView?.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: gradientView!.topAnchor, constant: 100),
            label.widthAnchor.constraint(equalToConstant: 300),
            label.centerXAnchor.constraint(equalTo: gradientView!.centerXAnchor)
        ])
        
    }
    
    fileprivate func callPressButton() {
        perform(#selector(pressButton), with: nil, afterDelay: 2)
        buttonPressed = true
    }
    
    @objc fileprivate func pressButton() {
        circleMenu?.sendActions(for: .touchUpInside)
    }
    
    fileprivate func setupGradientAnimator() {
        self.gradientView = GradientAnimator(
            frame: view.frame,
            theme: GradientThemes.Sunrise,
            _startPoint: GradientPoints.bottomLeft,
            _endPoint: GradientPoints.topRight,
            _animationDuration: 1.0
        )

        self.view.insertSubview(gradientView!, at: 0)
        gradientView?.startAnimate()
    }
    
    fileprivate func setupCircleMenuButton() {
        
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
        gradientView!.addSubview(circleMenu!)
        circleMenu!.center = view.center
    }
        
    func circleMenu(_ circleMenu: CircleMenu, willDisplay button: UIButton, atIndex: Int) {
        button.backgroundColor = items[atIndex].color
        button.setImage(UIImage(named: items[atIndex].icon), for: .normal)

        let highlightedImage = UIImage(named: items[atIndex].icon)?.withRenderingMode(.alwaysTemplate)
        button.setImage(highlightedImage, for: .highlighted)
        button.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
    }

    func circleMenu(_ circleMenu: CircleMenu, buttonDidSelected button: UIButton, atIndex: Int) {

        switch atIndex {
             case 0:
                print("First Button")
             case 1:
                print("Second Button")
                present(UINavigationController(rootViewController: DirectionsController()),            animated: true, completion:{
                    self.buttonPressed = false
                })
             case 2:
                print("Third Button")
             case 3:
                print("Fourth Button")
            case 4:
                print("Fifth Button")
                present(MainController(), animated: true, completion: nil)
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
