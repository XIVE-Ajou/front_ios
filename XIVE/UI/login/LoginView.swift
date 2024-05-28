//
//  LoginView.swift
//  XIVE
//
//  Created by 나현흠 on 4/3/24.
//

import SwiftUI
import WebKit

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var isContentReady: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                VStack(spacing: 0) {
                    Image("XIVE_CombinedLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 130)
                        .frame(width: 130)
                        .padding(.top, 150)

                    Spacer()
                        .padding(.bottom, 30)

                    Button(action: viewModel.handleKakaoLogin) {
                        Image("kakao_real")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 52)
                            .frame(width: 342)
                    }
                    .padding(.horizontal, 35)
                    .padding(.vertical, 1)

                    Button(action: viewModel.handleAuthorizationAppleIDButtonPress) {
                        Image("apple_real")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 52)
                            .frame(width: 342)
                    }
                    .padding(.horizontal, 35)
                    .padding(.vertical, 5)

                    Button(action: viewModel.handleGuestLogin) {
                        Text("비회원으로 둘러보기")
                            .tracking(-0.02)
                            .foregroundColor(.gray)
                            .underline()
                            .font(.system(size: 14))
                    }
                    .padding(.bottom, 30)

                    Spacer()
                }
                .background(
                    NavigationLink(destination: destinationView, isActive: $viewModel.isAuthorized) {
                        EmptyView()
                    }
                )

                if viewModel.showWebView, let url = viewModel.webViewURL {
                    KakaoWebView(url: url, navigationDelegate: viewModel)
                        .edgesIgnoringSafeArea(.all)
                }

                if !isContentReady {
                    LottieView(jsonName: "logo_splash")
                        .background(Color.black.edgesIgnoringSafeArea(.all))
                        .transition(.opacity)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation { isContentReady.toggle() }
                }
            }
            .navigationBarBackButtonHidden(true)
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private var destinationView: some View {
        Group {
            if viewModel.isNewUser {
                OnboardingView()
            } else {
                HomeView()
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}


