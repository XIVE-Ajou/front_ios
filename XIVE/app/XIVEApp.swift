//
//  XIVEApp.swift
//  XIVE
//
//  Created by 나현흠 on 3/10/24.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct XIVEApp: App {
    @StateObject private var loginViewModel = LoginViewModel()  // 로그인 상태를 관리하는 ViewModel

    init() {
        // 카카오 SDK 초기화
        KakaoSDK.initSDK(appKey: kakaoNativeAppKey)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(loginViewModel)  // ViewModel을 환경 객체로 전달
                .onOpenURL(perform: { url in
                    // 커스텀 URL 스킴을 통한 카카오 로그인 처리
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        AuthController.handleOpenUrl(url: url)
                    }
                })
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var loginVM: LoginViewModel

    var body: some View {
        Group {
            if loginVM.isAuthorized {
                HomeView()
            } else {
                LoginView()
            }
        }
    }
}

func checkFont() {
        for family in UIFont.familyNames {
            print("*** \(family) ***")
            for name in UIFont.fontNames(forFamilyName: family) {
                print(name)
            }
            print("-----------")
        }
    }

