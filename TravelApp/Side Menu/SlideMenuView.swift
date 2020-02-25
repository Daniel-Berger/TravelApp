//
//  SlideMenuView.swift
//  TravelApp
//
//  Created by dberger1 on 2/25/20.
//  Copyright © 2020 daniel berger. All rights reserved.
//

import SwiftUI
import MapKit

struct SlideMenuView: View {
    
    @State var isMenuShowing = false
    
    var body: some View {
        ZStack {
            SlideMenuMapView()
                .edgesIgnoringSafeArea(.all)
            
            HStack {
                VStack {
                    Button(action: {
                        self.isMenuShowing.toggle()
                    }) {
                        Image(systemName: "line.horizontal.3.decrease.circle.fill")
                        .font(.system(size: 34))
                        .foregroundColor(.white)
                        .shadow(radius :5)
                    }
                    Spacer()
                }
                Spacer()
            }.padding()
            
            Color(.init(white: 0, alpha: self.isMenuShowing ? 0.5 : 0))
                .edgesIgnoringSafeArea(.all)
                .animation(.spring())
            
            HStack {
                ZStack {
                    Color.white
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            self.isMenuShowing.toggle()
                    }
                    VStack {
                       Text("Menu")
                        Spacer()
                    }
                    
                }.frame(width: 200)
                
                Spacer()
            }.offset(x: self.isMenuShowing ? 0 : -200)
                .animation(.spring())
        }
    }
}

struct SlideMenuMapView: UIViewRepresentable {
    typealias UIViewType = MKMapView
    
    func makeUIView(context: UIViewRepresentableContext<SlideMenuMapView>) -> MKMapView {
        MKMapView()
    }
    
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<SlideMenuMapView>) {
        
    }
}

struct SlideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SlideMenuView()
    }
}
