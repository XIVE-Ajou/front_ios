//
//  LoginViewModel.swift
//  XIVE
//
//  Created by 나현흠 on 4/3/24.
//

import SwiftUI
import AuthenticationServices
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import WebKit

class LoginViewModel: NSObject, ObservableObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding, WKNavigationDelegate {
    @Published var loginModel = LoginModel()
    @Published var isAuthorized = false
    @Published var shouldShowOnboarding = false
    @Published var showWebView = false
    @Published var webViewURL: URL?
    @Published var isNewUser = false

    override init() {
        super.init()
        checkLoginStatus()
    }

    func checkLoginStatus() {
        if UserDefaults.standard.bool(forKey: "isLoggedIn") {
            DispatchQueue.main.async {
                self.shouldShowOnboarding = false
                self.isAuthorized = true
            }
        }
    }

    private func saveLoginState(isLoggedIn: Bool, name: String?, loginMethod: String) {
        UserDefaults.standard.set(isLoggedIn, forKey: "isLoggedIn")
        if let userName = name {
            UserDefaults.standard.set(userName, forKey: "userName")
        }
        UserDefaults.standard.set(loginMethod, forKey: "loginMethod")
    }

    private func saveTokens(accessToken: String?, refreshToken: String?) {
        if let accessToken = accessToken {
            UserDefaults.standard.set(accessToken, forKey: "User_AccessToken")
        }
        if let refreshToken = refreshToken {
            UserDefaults.standard.set(refreshToken, forKey: "User_RefreshToken")
        }
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            fatalError("No key window found")
        }
        return window
    }

    // Helper function to post login data to the server
    func postLoginData(url: URL, parameters: [String: Any], completion: @escaping (Result<Data, Error>) -> Void) {
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
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
                    let error = NSError(domain: "", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error: \(response.statusCode)"])
                    completion(.failure(error))
                } else if let data = data {
                    completion(.success(data))
                }
            }
        }.resume()
    }

    // Handle Kakao login using SDK
    func handleKakaoLogin() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                if let error = error {
                    print("Kakao Login Failed: \(error.localizedDescription)")
                    self.loginWithKakaoAccount()
                } else if let token = oauthToken {
                    print("Kakao Login Successful.")
                    self.processKakaoLoginSuccess(token: token)
                }
            }
        } else {
            loginWithKakaoAccount()
        }
    }

    private func loginWithKakaoAccount() {
        UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
            if let error = error {
                print("Kakao Account Login Failed: \(error.localizedDescription)")
            } else if let token = oauthToken {
                print("Kakao Account Login Successful.")
                self.processKakaoLoginSuccess(token: token)
            }
        }
    }

    private func processKakaoLoginSuccess(token: OAuthToken) {
        UserApi.shared.me { (user, error) in
            if let error = error {
                print("Kakao User Info Fetch Failed: \(error.localizedDescription)")
            } else if let user = user {
                let name = user.kakaoAccount?.profile?.nickname ?? "Kakao User"
                DispatchQueue.main.async {
                    self.saveLoginState(isLoggedIn: true, name: name, loginMethod: "kakao")
                }

                self.postLoginData(url: URL(string: /*"https://api.xive.co.kr/api/kakao-login"*/ "https://1626edc1e3c68daf037d9f7108dbe7ebd4464974.xiveapple.store/api/kakao-login")!, parameters: ["accessToken": token.accessToken]) { result in
                    switch result {
                    case .success(let data):
                        let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        let accessToken = json?["accessToken"] as? String
                        let refreshToken = json?["refreshToken"] as? String
                        self.saveTokens(accessToken: accessToken, refreshToken: refreshToken)
                        self.isNewUser = json?["isNew"] as? Bool ?? false
                        self.isAuthorized = true
                    case .failure(let error):
                        print("Error sending Kakao login data: \(error.localizedDescription)")
                        print(token.accessToken)
                    }
                }
            }
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
            
            let fullName: String
            if let givenName = appleIDCredential.fullName?.givenName, let familyName = appleIDCredential.fullName?.familyName {
                fullName = "\(givenName) \(familyName)"
            } else {
                fullName = UserDefaults.standard.string(forKey: "userName") ?? ""
            }
            
            saveLoginState(isLoggedIn: true, name: fullName, loginMethod: "apple")
            let email = appleIDCredential.email ?? ""
            
            postLoginData(url: URL(string: /*"https://api.xive.co.kr/api/apple-login"*/ "https://1626edc1e3c68daf037d9f7108dbe7ebd4464974.xiveapple.store/api/apple-login")!, parameters: ["code": authCode, "id_token": idToken, "name": fullName, "email": email]) { result in
                switch result {
                case .success(let data):
                    let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    let accessToken = json?["accessToken"] as? String
                    let refreshToken = json?["refreshToken"] as? String
                    self.saveTokens(accessToken: accessToken, refreshToken: refreshToken)
                    self.isNewUser = json?["isNew"] as? Bool ?? false
                    self.isAuthorized = true
                case .failure(let error):
                    print("Error sending Apple login data: \(error.localizedDescription)")
                }
            }
            self.isAuthorized = true
            print("Apple Login Successful: code: \(authCode), id_token: \(idToken), name: \(fullName), email: \(email)")
            
        default:
            break
        }
    }
}

extension URL {
    var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false), let queryItems = components.queryItems else {
            return nil
        }
        return queryItems.reduce(into: [String: String]()) { result, item in
            result[item.name] = item.value
        }
    }
}
