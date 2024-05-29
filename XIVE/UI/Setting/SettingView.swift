//
//  SettingView.swift
//  XIVE
//
//  Created by 나현흠 on 5/4/24.
//

import SwiftUI

struct SettingView: View {
    @StateObject private var viewModel = SettingViewModel()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var isAppleLinked = false
    @State private var isKakaoLinked = false
    @State private var showLogoutDialog = false
    @State private var shouldNavigateToLogin = false
    @StateObject private var loginViewModel = LoginViewModel()
    
    var body: some View {
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        let fullname = UserDefaults.standard.string(forKey: "userName") ?? "Guest"
        let loginMethod = UserDefaults.standard.string(forKey: "loginMethod") ?? "guest"
        
        if isLoggedIn {
            loggedInView(fullname: fullname, loginMethod: loginMethod)
        } else {
            guestLoginView()
        }
    }
    
    //MARK: 회원 가입 됐을 경우,
    private func loggedInView(fullname: String, loginMethod: String) -> some View {
        NavigationView {
            VStack(spacing: 0) {
                setupNavigationBar(presentationMode)
                CustomDivider(color: .XIVE_SettingDivider, height: 7)
                ScrollView {
                    VStack {
                        HStack{
                            Text("로그인 계정")
                                .padding(25)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 7)
                                .tracking(-0.02)
                            
                            HStack(spacing: 10) { // 간격을 10으로 설정
                                if loginMethod == "kakao" {
                                    Image("kakao_small_logo")
                                        .multilineTextAlignment(.trailing)
                                } else if loginMethod == "apple" {
                                    Image("apple_small_logo")
                                        .multilineTextAlignment(.trailing)
                                }
                                
                                Text(fullname)
                                    .multilineTextAlignment(.trailing)
                                    .tracking(-0.02)
                            }
                            .padding(.trailing, 25)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .frame(height: 56)
                        .padding(.top, 7)
                        
                        HStack {
                            if loginMethod == "kakao" {
                                Text("애플 계정 연동하기")
                                    .tracking(-0.02)
                                    .padding(25)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.gray)
                                    .frame(height: 56)
                                    .padding(.top, 7)
                            } else if loginMethod == "apple" {
                                Text("애플 계정 연동하기")
                                    .tracking(-0.02)
                                    .padding(25)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.black)
                                    .frame(height: 56)
                                    .padding(.top, 7)
                            }
                            
                            Button(action: {
                                if loginMethod != "apple" {
                                    isAppleLinked.toggle()
                                    if isAppleLinked {
                                        loginViewModel.handleAuthorizationAppleIDButtonPress()
                                    } else {
                                        print("애플 계정 연동 해제")
                                    }
                                }
                            }) {
                                Image((loginMethod == "apple" || isAppleLinked) ? "toggle_on" : "toggle_off")
                                    .tracking(-0.02)
                                    .padding(.top, 7)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding(.trailing, 25)
                            }
                            .disabled(loginMethod == "kakao")
                        }
                        .frame(height: 56)
                        HStack {
                            if loginMethod == "kakao" {
                                Text("카카오 계정 연동하기")
                                    .tracking(-0.02)
                                    .padding(25)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.black)
                                    .frame(height: 56)
                                    .padding(.top, 7)
                            } else if loginMethod == "apple" {
                                Text("카카오 계정 연동하기")
                                    .tracking(-0.02)
                                    .padding(25)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.gray)
                                    .frame(height: 56)
                                    .padding(.top, 7)
                            }
                            
                            Button(action: {
                                if loginMethod != "kakao" {
                                    isKakaoLinked.toggle()
                                    if isKakaoLinked {
                                        loginViewModel.handleKakaoLogin()
                                    } else {
                                        print("카카오 계정 연동 해제")
                                    }
                                }
                            }) {
                                Image((loginMethod == "kakao" || isKakaoLinked) ? "toggle_on" : "toggle_off")
                                    .tracking(-0.02)
                                    .padding(.top, 7)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding(.trailing, 25)
                            }
                            .disabled(loginMethod == "apple")
                        }
                        .frame(height: 56)

                        CustomDivider(color: .XIVE_SettingDivider, height: 7)
                        HStack {
                            NavigationLink(destination: OneToOneView()) {
                                Text("1:1 문의")
                                    .tracking(-0.02)
                                    .foregroundStyle(Color.black)
                            }
                            .padding(25)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            NavigationLink(destination: OneToOneView()) {
                                Image("right_arrow")
                                    .padding(25)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        .frame(height: 56)
                        CustomDivider(color: .XIVE_SettingDivider, height: 7)
                        
                        HStack {
                            NavigationLink(destination: ServiceTermView()) {
                                Text("서비스 이용 약관")
                                    .tracking(-0.02)
                                    .foregroundStyle(Color.black)
                            }
                            .padding(25)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            NavigationLink(destination: ServiceTermView()) {
                                Image("right_arrow")
                                    .padding(25)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        .frame(height: 56)
                        
                        HStack {
                            NavigationLink(destination: PrivacyPolicyView()) {
                                Text("개인정보 처리 방침")
                                    .tracking(-0.02)
                                    .foregroundStyle(Color.black)
                            }
                            .padding(25)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            NavigationLink(destination: PrivacyPolicyView()) {
                                Image("right_arrow")
                                    .padding(25)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        .frame(height: 56)
                        CustomDivider(color: .XIVE_SettingDivider, height: 7)
                        HStack {
                            Text("버전 정보")
                                .padding(25)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .tracking(-0.02)
                            Text("Ver 1.0.2")
                                .padding(25)
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .tracking(-0.02)
                        }
                        .frame(height: 56)
                        CustomDivider(color: .XIVE_SettingDivider, height: 7)
                        
                        HStack {
                            Button(action: {
                                showLogoutDialog.toggle()
                            }) {
                                Text("로그아웃")
                                    .tracking(-0.02)
                                    .padding(25)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                    .foregroundStyle(Color.black)
                            }
                        }
                        .frame(height: 56)
                        
                        HStack {
                            NavigationLink(destination: WithdrawalView()) {
                                Text("회원 탈퇴")
                                    .tracking(-0.02)
                                    .foregroundStyle(Color.black)
                            }
                            .padding(25)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(height: 56)
                    }
                }
                .navigationBarBackButtonHidden(true)
                .onAppear {
                    if loginMethod == "apple" {
                        isAppleLinked = true
                    } else if loginMethod == "kakao" {
                        isKakaoLinked = true
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .background(Color.white)
            .customDialog(isActive: $showLogoutDialog, shouldNavigateToLogin: $shouldNavigateToLogin, title: "로그아웃 하시겠어요?", message: "언제나 여기서 기다리고 있을게요 😢", buttonTitle: "머무르기", action: {
                // 로그아웃 로직 추가
            })
            .fullScreenCover(isPresented: $shouldNavigateToLogin) {
                LoginView()
            }
        }
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(.light) // 다크 모드에서도 흰색 배경 유지
    }
    
    //MARK: 비회원 로그인
    private func guestLoginView() -> some View {
        NavigationView {
            VStack(spacing: 0) {
                setupNavigationBar(presentationMode)
                CustomDivider(color: .XIVE_SettingDivider, height: 7)
                ScrollView {
                    VStack {
                        HStack {
                            Text("로그인 계정")
                                .padding(25)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 7)
                                .tracking(-0.02)
                            
                            HStack(spacing: 10) { // 간격을 10으로 설정
                                    Image("non_login")
                                        .multilineTextAlignment(.trailing)
                                
                                Text("비회원")
                                    .multilineTextAlignment(.trailing)
                                    .tracking(-0.02)
                            }
                            .padding(.trailing, 25)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .frame(height: 56)
                        .padding(.top, 7)
                        
                        HStack {
                            Text("애플 계정 연동하기")
                                .tracking(-0.02)
                                .padding(25)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.black)
                                .frame(height: 56)
                                .padding(.top, 7)
                            
                            Button(action: {
                                isAppleLinked.toggle()
                                if isAppleLinked {
                                    loginViewModel.handleAuthorizationAppleIDButtonPress()
                                } else {
                                    print("애플 계정 연동 해제")
                                }
                            }) {
                                Image("toggle_off")
                                    .tracking(-0.02)
                                    .padding(.top, 0)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding(.trailing, 25)
                                    .frame(height: 56)
                            }
                        }
                        HStack {
                            Text("카카오 계정 연동하기")
                                .tracking(-0.02)
                                .padding(25)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.black)
                                .frame(height: 56)
                                .padding(.top, 7)
                            
                            Button(action: {
                                isKakaoLinked.toggle()
                                if isKakaoLinked {
                                    loginViewModel.handleKakaoLogin()
                                } else {
                                    print("카카오 계정 연동 해제")
                                }
                            }) {
                                Image("toggle_off")
                                    .tracking(-0.02)
                                    .padding(.top, 7)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding(.trailing, 25)
                            }
                        }
                        .frame(height: 56)
                        CustomDivider(color: .XIVE_SettingDivider, height: 7)
                        HStack {
                            NavigationLink(destination: OneToOneView()) {
                                Text("1:1 문의")
                                    .tracking(-0.02)
                                    .foregroundStyle(Color.black)
                            }
                            .padding(25)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            NavigationLink(destination: OneToOneView()) {
                                Image("right_arrow")
                                    .padding(25)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        .frame(height: 56)
                        CustomDivider(color: .XIVE_SettingDivider, height: 7)
                        
                        HStack {
                            NavigationLink(destination: ServiceTermView()) {
                                Text("서비스 이용 약관")
                                    .tracking(-0.02)
                                    .foregroundStyle(Color.black)
                            }
                            .padding(25)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            NavigationLink(destination: ServiceTermView()) {
                                Image("right_arrow")
                                    .padding(25)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        .frame(height: 56)
                        
                        HStack {
                            NavigationLink(destination: PrivacyPolicyView()) {
                                Text("개인정보 처리 방침")
                                    .tracking(-0.02)
                                    .foregroundStyle(Color.black)
                            }
                            .padding(25)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            NavigationLink(destination: PrivacyPolicyView()) {
                                Image("right_arrow")
                                    .padding(25)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        .frame(height: 56)
                        CustomDivider(color: .XIVE_SettingDivider, height: 7)
                        HStack {
                            Text("버전 정보")
                                .tracking(-0.02)
                                .padding(25)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.black)
                            Text("Ver 1.0.2")
                                .tracking(-0.02)
                                .padding(25)
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .frame(height: 56)
                        CustomDivider(color: .XIVE_SettingDivider, height: 7)
                        
                        HStack {
                            Button(action: {
                                showLogoutDialog.toggle()
                            }) {
                                Text("로그아웃")
                                    .tracking(-0.02)
                                    .padding(25)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                    .foregroundStyle(Color.black)
                            }
                        }
                        .frame(height: 56)
                        
                        HStack {
                            NavigationLink(destination: WithdrawalView()) {
                                Text("회원 탈퇴")
                                    .tracking(-0.02)
                                    .foregroundStyle(Color.black)
                            }
                            .padding(25)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(height: 56)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
        }
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(.light) // 다크 모드에서도 흰색 배경 유지
        .customDialog(isActive: $showLogoutDialog, shouldNavigateToLogin: $shouldNavigateToLogin, title: "로그아웃 하시겠어요?", message: "언제나 여기서 기다리고 있을게요 😢", buttonTitle: "머무르기", action: {
            // 로그아웃 로직 추가
        })
        .fullScreenCover(isPresented: $shouldNavigateToLogin) {
            LoginView()
        }
    }
    
    @ViewBuilder
    private func setupNavigationBar(_ presentationMode: Binding<PresentationMode>) -> some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image("back_arrow")
            }
            
            Spacer()
            
            Text("설정")
                .frame(alignment: .center)
            
            Spacer()
            
            Button(action: {
            }) {
                Text("     ")
            }
        }
        .padding()
        .background(Color.white)
        .frame(maxHeight: 44) // Adjust the height as needed
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}

struct CustomDivider: View {
    var color: Color
    var height: CGFloat
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: height)
            .edgesIgnoringSafeArea(.horizontal)
    }
}

extension View {
    func customDialog(isActive: Binding<Bool>, shouldNavigateToLogin: Binding<Bool>, title: String, message: String, buttonTitle: String, action: @escaping () -> ()) -> some View {
        self.modifier(CustomDialogModifier(isActive: isActive, shouldNavigateToLogin: shouldNavigateToLogin, title: title, message: message, buttonTitle: buttonTitle, action: action))
    }
}

struct CustomDialogModifier: ViewModifier {
    @Binding var isActive: Bool
    @Binding var shouldNavigateToLogin: Bool

    let title: String
    let message: String
    let buttonTitle: String
    let action: () -> ()

    func body(content: Content) -> some View {
        ZStack {
            content
            if isActive {
                CustomDialog(isActive: $isActive, shouldNavigateToLogin: $shouldNavigateToLogin, title: title, message: message, buttonTitle: buttonTitle, action: action)
            }
        }
    }
}
