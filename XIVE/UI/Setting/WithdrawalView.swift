//
//  WithdrawalView.swift
//  XIVE
//
//  Created by 나현흠 on 5/17/24.
//

import SwiftUI

struct WithdrawalView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var agreementChecked = false
    @State private var reasonsChecked = [false, false, false, false, false, false]
    @State private var showReasonSection = false
    @State private var otherReason: String = ""
    @State private var navigateToLogin = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                setupNavigationBar(presentationMode)
                
                let fullname = UserDefaults.standard.string(forKey: "userName") ?? "Guest"
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("정말 XIVE를 탈퇴하고 싶으신가요?😅")
                        .padding(.top, 18)
                        .padding([.leading, .trailing], 25)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .tracking(-0.02)
                        .font(.title3)
                        .bold()
                    
                    Text("회원 탈퇴 처리 내용")
                        .fontWeight(.bold)
                        .padding([.leading, .trailing], 25)
                        .padding(.top, 13)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .tracking(-0.02)
                        .font(.headline)
                        .bold()
                    
                    Text("탈퇴하시면 개인정보 처리 방침에 따라 최대 30일 이내에 '\(fullname)'님의 모든 개인정보 및 계정 정보가 삭제됩니다. 이후에는 '\(fullname)'님의 앱 내 활동 데이터는 다시 복구될 수 없습니다.")
                        .padding([.leading, .trailing], 25)
                        .padding(.top, 1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .tracking(-0.02)
                        .font(.subheadline)
                    
                    HStack {
                        Button(action: {
                            agreementChecked.toggle()
                            showReasonSection = agreementChecked
                        }) {
                            Image(agreementChecked ? "Setting_Check" : "Setting_Blank")
                        }
                        Text("회원 탈퇴 처리 내용에 동의합니다.")
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 10)
                    .font(.subheadline)
                    
                    if showReasonSection {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("XIVE 서비스를 그만 사용하는 이유를 알려주세요!")
                                .fontWeight(.bold)
                                .padding([.leading, .trailing], 25)
                                .padding(.top, 40)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .tracking(-0.02)
                                .font(.headline)
                                .bold()
                            
                            Text("이후 더 나은 서비스로 찾아뵙겠습니다.")
                                .padding([.leading, .trailing], 25)
                                .padding(.top, 1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .tracking(-0.02)
                                .font(.subheadline)
                            
                            ForEach(0..<6) { index in
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack {
                                        Button(action: {
                                            reasonsChecked[index].toggle()
                                        }) {
                                            Image(reasonsChecked[index] ? "Setting_Check" : "Setting_Blank")
                                        }
                                        Text(reasonText(for: index))
                                    }
                                    .padding(.horizontal, 25)
                                    .padding(.top, index == 0 ? 10 : 2)
                                    .font(.subheadline)
                                    
                                    if index == 5 && reasonsChecked[5] {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 0)
                                                .fill(Color("XIVE_SettingDivider"))
                                            TextField("계정을 삭제하려는 이유를 알려주세요.", text: $otherReason)
                                                .padding(8)
                                                .background(Color.clear)
                                        }
                                        .padding(.horizontal, 25)
                                        .padding(.top, 10)
                                        .frame(height: 60)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                withdraw()
                            }) {
                                Text("탈퇴하기")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(canWithdraw() ? Color.black : Color.gray)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal, 25)
                            .padding(.bottom, 20)
                            .disabled(!canWithdraw())
                        }
                    }
                    
                    Spacer()  // This will push the content to the top
                }
            }
            .navigationBarHidden(true)
            .background(
                NavigationLink(destination: LoginView(), isActive: $navigateToLogin) {
                    EmptyView()
                }
            )
        }
        .navigationBarBackButtonHidden(true)
        .background(Color.white)
        .preferredColorScheme(.light) // 다크 모드에서도 흰색 배경 유지
    }
    
    private func reasonText(for index: Int) -> String {
        switch index {
        case 0: return "XIVE에서 제공하는 티켓에 불만족함"
        case 1: return "자주 사용하지 않음"
        case 2: return "앱 사용 방식이 어려움"
        case 3: return "잦은 오류와 장애가 발생함"
        case 4: return "다른 계정으로 재가입하기 위함"
        case 5: return "기타"
        default: return ""
        }
    }
    
    private func reasonOption(for index: Int) -> String {
        switch index {
        case 0: return "OPTION1"
        case 1: return "OPTION2"
        case 2: return "OPTION3"
        case 3: return "OPTION4"
        case 4: return "OPTION5"
        case 5: return "OTHER_OPTION"
        default: return "NONE"
        }
    }
    
    private func canWithdraw() -> Bool {
        return agreementChecked && reasonsChecked.contains(true)
    }
    
    private func withdraw() {
        guard let url = URL(string: "https://api.xive.co.kr/api/withdrawal") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Set headers
        guard let accessToken = UserDefaults.standard.string(forKey: "User_AccessToken"),
              let refreshToken = UserDefaults.standard.string(forKey: "User_RefreshToken") else {
            print("AccessToken 또는 RefreshToken을 찾을 수 없습니다.")
            return
        }
        request.setValue(accessToken, forHTTPHeaderField: "AccessToken")
        request.setValue(refreshToken, forHTTPHeaderField: "RefreshToken")
        
        // Set body
        let selectedOptionIndex = reasonsChecked.firstIndex(of: true) ?? 0
        let withdrawalOption = reasonOption(for: selectedOptionIndex)
        let content = (withdrawalOption == "OTHER_OPTION") ? otherReason : "NONE"
        
        let requestBody: [String: Any] = [
            "withdrawalOption": withdrawalOption,
            "content": content
        ]
        
        print("accesstoken: \(accessToken), refreshToken: \(refreshToken), \(requestBody)")
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Perform request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error:", error)
                return
            }
            
            guard let data = data else {
                print("No data")
                return
            }
            
            // Handle response
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                print("Withdrawal successful")
                // Handle successful withdrawal (e.g., navigate back to login)
                DispatchQueue.main.async {
                    UserDefaults.standard.set(false, forKey: "isLoggedIn")
                    navigateToLogin = true
                }
            } else {
                print("Withdrawal failed")
                // Handle failed withdrawal
            }
        }.resume()
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
            
            Text("회원탈퇴")
                .frame(alignment: .center)
            
            Spacer()
            
            Button(action: {
            }) {
                Text("     ")
            }
        }
        .padding()
        .background(Color.white)
    }
}

struct WithdrawalView_Previews: PreviewProvider {
    static var previews: some View {
        WithdrawalView()
    }
}
