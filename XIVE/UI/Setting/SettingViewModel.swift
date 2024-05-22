//
//  SettingViewModel.swift
//  XIVE
//
//  Created by 나현흠 on 5/13/24.
//

import SwiftUI
import AuthenticationServices
import KakaoSDKAuth
import KakaoSDKUser

class SettingViewModel: NSObject, ObservableObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    @Published var loginModel = LoginModel()
    @Published var isAuthorized = false
    @Published var shouldShowOnboarding = false

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            fatalError("No key window found")
        }
        return window
    }

    // Helper function to post login data to the server
    func postLoginData(url: URL, parameters: [String: Any]) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Error: Cannot create JSON from parameters")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending login data: \(error.localizedDescription)")
                return
            }
            if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
                print("Server error: \(response.statusCode)")
            } else {
                print("Login data posted successfully.")
            }
        }.resume()
    }

    // Handle Kakao login
    func handleKakaoLogin() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                self.handleKakaoLoginResult(oauthToken: oauthToken, error: error)
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
                self.handleKakaoLoginResult(oauthToken: oauthToken, error: error)
            }
        }
    }

    private func handleKakaoLoginResult(oauthToken: OAuthToken?, error: Error?) {
        if let error = error {
            print("Kakao Login Failed: \(error.localizedDescription)")
        } else if let token = oauthToken {
            print("Kakao Login Successful.")
            self.isAuthorized = true
            self.shouldShowOnboarding = true
            // Convert OAuthToken to JSON object manually
            let tokenData = [
                "accessToken": token.accessToken,
                "refreshToken": token.refreshToken,
                "expiresIn": token.expiresIn,
                "tokenType": token.tokenType,
                "scope": token.scope ?? ""
            ] as [String : Any]
            postLoginData(url: URL(string: "https://api.xive.co.kr/api/kakao-login")!, parameters: ["authCode": oauthToken])
            print(tokenData)
        }
    }


    // Handle Apple ID button press
    func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    // Handle Apple login success
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let authCode = String(data: appleIDCredential.authorizationCode!, encoding: .utf8) ?? ""
            let idToken = String(data: appleIDCredential.identityToken!, encoding: .utf8) ?? ""
            let fullName = "\(appleIDCredential.fullName?.givenName ?? "") \(appleIDCredential.fullName?.familyName ?? "")"
            let email = appleIDCredential.email ?? ""
            
            postLoginData(url: URL(string: "https://api.xive.co.kr/api/apple-login")!, parameters: ["code": authCode, "id_token": idToken, "name": fullName, "email": email])
            self.isAuthorized = true
            self.shouldShowOnboarding = true
            print("Apple Login Successful: code: \(authCode), id_token: \(idToken), name: \(fullName), email: \(email)")
            
        default:
            break
        }
    }
}
