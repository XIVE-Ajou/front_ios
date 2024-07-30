//
//  OneToOneView.swift
//  XIVE
//
//  Created by 나현흠 on 5/20/24.
//

import Foundation
import SwiftUI

struct OneToOneView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var userEmail: String = ""
    @State private var inquiryContent: String = ""
    @State private var isSubmitDisabled = true

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                setupNavigationBar()
                formFields
                    .padding()
                submitButton
                    .padding()
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
        }
        .navigationBarBackButtonHidden(true)
        .onChange(of: userEmail) { _ in validateForm() }
        .onChange(of: inquiryContent) { _ in validateForm() }
    }
    
    private var formFields: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("답변 받으실 이메일")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 10)
                    .foregroundColor(.black)
                
                emailTextField
                    .padding([.leading, .trailing], 10)
                    .padding(.bottom, 20)

                HStack {
                    Text("문의 내용")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 10)
                        .padding(.top, 20)
                        .foregroundColor(.black)
                    
                    HStack {
                        Spacer()
                        Text("\(inquiryContent.count)/500")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.trailing, 10)
                            .padding(.top, 30)
                    }
                    .padding(.trailing, 5)
                }
                
                inquiryContentEditor
                    .padding([.leading, .trailing], 10)
                    .padding(.bottom, 20)
            }
        }
    }
    
    private var emailTextField: some View {
        VStack(spacing: 0) {
            TextField("Enter your email", text: $userEmail)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .padding(.bottom, 5)
                .onChange(of: userEmail) { _ in validateForm() }
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray)
        }
    }

    private var inquiryContentEditor: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                TextEditor(text: $inquiryContent)
                    .frame(height: 200) // 고정된 높이 설정
                    .background(GeometryReader { geometry in
                        Color.clear.preference(key: ViewHeightKey.self, value: geometry.size.height)
                    })
                    .onChange(of: inquiryContent) { _ in
                        validateForm()
                        if inquiryContent.count > 500 {
                            inquiryContent = String(inquiryContent.prefix(500))
                        }
                    }
                
                if inquiryContent.isEmpty {
                    Text("최대 500자까지 입력 가능합니다")
                        .foregroundColor(Color.gray)
                        .padding(.top, 8)
                        .padding(.leading, 4)
                }
            }
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray)
        }
    }

    private var submitButton: some View {
        Button("문의하기") {
            sendInquiry()
        }
        .disabled(isSubmitDisabled)
        .frame(maxWidth: .infinity)
        .padding()
        .foregroundColor(.white)
        .background(isSubmitDisabled ? Color.gray : Color.black)
        .cornerRadius(10)
    }
    
    private func sendInquiry() {
        guard let requestUrl = URL(string: "https://1626edc1e3c68daf037d9f7108dbe7ebd4464974.xiveapple.store/api/inquiries") else { return }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        // UserDefaults에서 AccessToken과 RefreshToken 읽기
        guard let accessToken = UserDefaults.standard.string(forKey: "User_AccessToken"),
              let refreshToken = UserDefaults.standard.string(forKey: "User_RefreshToken") else {
            print("AccessToken 또는 RefreshToken을 찾을 수 없습니다.")
            return
        }
        
        // 헤더에 AccessToken과 RefreshToken 추가
        request.setValue(accessToken, forHTTPHeaderField: "AccessToken")
        request.setValue(refreshToken, forHTTPHeaderField: "RefreshToken")
        
        // 요청 바디에 email과 contents 추가
        let requestBody: [String: Any] = [
            "email": userEmail,
            "contents": inquiryContent
        ]
        
        print("accesstoken: \(accessToken), refreshToken: \(refreshToken), \(requestBody)")
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending inquiry: \(error.localizedDescription)")
                return
            }
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                print("Failed to send inquiry with status code: \(response.statusCode)")
            } else {
                print("Inquiry sent successfully")
            }
        }.resume()
    }
    
    private func validateForm() {
        isSubmitDisabled = userEmail.isEmpty || !isValidEmail(userEmail) || inquiryContent.isEmpty || inquiryContent.count > 500
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    @ViewBuilder
    private func setupNavigationBar() -> some View {
        HStack {
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image("back_arrow")
                    .padding(.leading, 15)
            }
            
            Spacer()
            
            Text("1:1 문의")
            
            Spacer()
            
            Button(action: {
                // Additional action can be added here
            }) {
                Text("     ")
            }
        }
        .padding()
        .background(Color.white)
    }
}

private struct ViewHeightKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: CGFloat = 50
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct OneToOneView_Previews: PreviewProvider {
    static var previews: some View {
        OneToOneView()
    }
}
