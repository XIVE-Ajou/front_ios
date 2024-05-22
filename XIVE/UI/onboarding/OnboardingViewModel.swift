//
//  OnboardingViewModel.swift
//  XIVE
//
//  Created by 나현흠 on 4/3/24.
//

import Foundation
import SwiftUI

final class OnboardingViewModel: ObservableObject {
    @Published private(set) var model = OnboardingModel()
    @Published var isLastPage = false // 마지막 페이지 여부 확인

    func moveToNext() {
        let allStates = OnboardingInformationState.allCases
        if let currentIndex = allStates.firstIndex(of: model.informationState), currentIndex < allStates.count - 1 {
            model.informationState = allStates[currentIndex + 1]
        } else {
            self.isLastPage = true // 마지막 페이지 도달 시 isLastPage를 true로 설정
        }
    }
}

extension OnboardingViewModel {
    var tabSelectionBinding: Binding<OnboardingInformationState> {
        .init {
            self.model.informationState
        } set: { newValue in
            self.model.informationState = newValue
        }
    }
}
