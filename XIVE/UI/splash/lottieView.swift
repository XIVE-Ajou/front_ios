//
//  lottieView.swift
//  XIVE
//
//  Created by 나현흠 on 4/3/24.
//

import Foundation
import SwiftUI
import UIKit
import Lottie


/// 로티 애니메이션 뷰
struct LottieView: UIViewRepresentable {
    
    var name : String
    var loopMode: LottieLoopMode

    
    init(jsonName: String = "logo_splash",
         _ loopMode : LottieLoopMode = .playOnce){
        print("LottieView - init() called / jsonName: ", jsonName)
        self.name = jsonName
        self.loopMode = loopMode
    }
    
    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        
        print("LottieView - makeUIView() called")
        let view = UIView(frame: .zero)
        view.backgroundColor = .black // Lottie 뷰의 배경을 검정색으로 설정

        let animationView = LottieAnimationView()
        let animation = LottieAnimation.named(name)
        
        animationView.animation = animation
        
        animationView.contentMode = .scaleAspectFit
        
        animationView.loopMode = loopMode
        
        animationView.play()

        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        print("LottieView - updateUIView() called")
    }
}


