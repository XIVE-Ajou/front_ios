//
//  OnboardingInformationState.swift
//  XIVE
//
//  Created by 나현흠 on 4/9/24.
//

import Foundation
import UIKit

enum OnboardingInformationState: Int, CaseIterable, Hashable, Identifiable {
    
    case first
    case second
    case third
    
    var id: String {
        String(self.rawValue)
    }
    
    var text: String {
        switch self {
        case .first:
            return """
스마트 티켓을 태깅해보세요
"""
        case .second:
            return """
스캔 한 번에 모든 콘텐츠를
"""
        case .third:
            return """
문화 생활을 더 즐겁게
"""
        }
    }
    
    var subtext: String {
        switch self {
        case .first:
            return """
스마트 티켓은 NFC 태깅이 가능한\n카이브만의 서비스에요
"""
        case .second:
            return """
카이브 만의 독점 콘텐츠를 확인해보세요
"""
        case .third:
            return """
내 손 안의 문화생활 플랫폼, 카이브와 함께해요!
"""
        }
    }
    
    var lottieFileName: String {
        switch self {
        case .first:
            return "Onboarding_1"
        case .second:
            return "Onboarding_2"
        case .third:
            return "Onboarding_3"
        }
    }
    
    var width: CGFloat {
        switch self {
        case .first:
            return 400
        case .second:
            return 400
        case .third:
            return 520
        }
    }
    
    var height: CGFloat {
        switch self {
        case .first:
            return 400
        case .second:
            return 400
        case .third:
            return 300
        }
    }
    
    var headerText: String {
        switch self {
        default:
            return ""
        }
    }
}
