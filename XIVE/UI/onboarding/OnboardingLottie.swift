//
//  OnboardingLottie.swift
//  XIVE
//
//  Created by 나현흠 on 4/9/24.
//

import SwiftUI
import Lottie

struct OnboardingLottieView: UIViewRepresentable {
    var name: String

    class Coordinator: NSObject {
        var parent: OnboardingLottieView

        init(parent: OnboardingLottieView) {
            self.parent = parent
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: UIViewRepresentableContext<OnboardingLottieView>) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView(name: name)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.play()
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<OnboardingLottieView>) {
        if let animationView = uiView.subviews.first as? LottieAnimationView {
            animationView.play()
        }
    }
}

