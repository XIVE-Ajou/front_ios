//
//  OnboardingViewIndicator.swift
//  XIVE
//
//  Created by 나현흠 on 4/9/24.
//

import SwiftUI

struct OnboardingViewIndicator: View {
    let currentPage: Int
    let total: Int
    
    var body: some View {
        HStack {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .frame(width: currentPage == index ? 40 : 10, height: 11)
                    .foregroundColor(currentPage == index ? .XIVE_Purple : .gray)
            }
        }
    }
}

struct LoginViewIndicator_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingViewIndicator(currentPage: 0, total: 3)
    }
}
