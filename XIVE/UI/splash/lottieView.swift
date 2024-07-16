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
    
    var name: String
    var loopMode: LottieLoopMode
    var animationSize: CGSize // 크기를 조정하기 위한 변수 추가

    init(jsonName: String = "logo_splash",
         loopMode: LottieLoopMode = .playOnce,
         size: CGSize = CGSize(width: 150, height: 150)) { // 기본값 지정
        print("LottieView - init() called / jsonName: ", jsonName)
        self.name = jsonName
        self.loopMode = loopMode
        self.animationSize = size // 크기 초기화
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
            // 제약 조건을 변경하여 애니메이션 뷰의 크기를 설정합니다.
            animationView.heightAnchor.constraint(equalToConstant: animationSize.height),
            animationView.widthAnchor.constraint(equalToConstant: animationSize.width),
            // 애니메이션 뷰를 부모 뷰의 중앙에 위치시킵니다.
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        print("LottieView - updateUIView() called")
        // 필요한 경우 여기서 UIView 업데이트 로직을 처리할 수 있습니다.
    }
}



