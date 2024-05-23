//
//  WebView.swift
//  XIVE
//
//  Created by 나현흠 on 5/8/24.
//

import SwiftUI
import WebKit

struct MyWebView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showNavigationBars: Bool = true
    @State private var nfcButtonOffset: CGFloat = 0.0
    @ObservedObject private var nfcViewModel = NFCViewModel()
    @State private var showErrorView = false
    @State private var webViewReloadTrigger = UUID()
    
    var urlToLoad: String

    var body: some View {
        NavigationView {
            if showErrorView {
                ErrorView {
                    self.reloadWebView()
                }
            } else {
                VStack(spacing: 0) {
                    setupNavigationBar()
                    ZStack {
                        WebView(urlToLoad: urlToLoad, reloadTrigger: webViewReloadTrigger, onError: {
                            self.showErrorView = true
                        })
                        .edgesIgnoringSafeArea(.all)
                    }
                }
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)
            }
        }
        .onAppear {
            nfcViewModel.urlDetected = { url in
                self.handleURL(url)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    @ViewBuilder
    private func setupNavigationBar() -> some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image("back_arrow")
                        .padding(.leading, 15)
                }
                Spacer()
                Image("        ")
                Spacer()
                Text("         ")
            }
            .padding()
            .frame(height: 44)
            Divider().background(Color.secondary)
            .background(Color.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
        }
        .background(Color.white)
    }

    private func handleURL(_ url: String) {
        nfcViewModel.sendToServer(url: url)
    }
    
    private func reloadWebView() {
        self.showErrorView = false
        self.webViewReloadTrigger = UUID()
    }
}

struct WebView: UIViewRepresentable {
    var urlToLoad: String
    var reloadTrigger: UUID
    var onError: () -> Void

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        loadRequest(in: webView)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Load the request only when reloadTrigger changes
        if context.coordinator.previousReloadTrigger != reloadTrigger {
            loadRequest(in: uiView)
            context.coordinator.previousReloadTrigger = reloadTrigger
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func loadRequest(in webView: WKWebView) {
        guard let url = URL(string: self.urlToLoad) else {
            self.onError()
            return
        }
        webView.load(URLRequest(url: url))
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        var previousReloadTrigger: UUID?

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.onError()
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.onError()
        }
    }
}

struct ErrorView: View {
    var onRetry: () -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToHome = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {

                Image("Warning_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 115, height: 90)
                    .padding(.top, 150)
                    .tracking(-0.02)
                
                VStack {
                    Text("현재 접속이 원활하지 않아요.")
                        .font(.system(size: 22))
                        .padding(.top, 20)
                        .fontWeight(.bold)
                        .foregroundColor(Color.black)
                        .tracking(-0.02)
                    Text("          ")
                        .font(.system(size: 10))

                    Text("일시적인 오류로 서비스에 접속할 수 없습니다. \n 잠시 후 다시 시도해주세요.")
                        .font(.system(size: 16))
                        .multilineTextAlignment(.center)
                        .tracking(-0.02)
                        .foregroundColor(.gray)
                }
                
                submitButton
                    .padding(.top, 40)
                
                VStack{
                    Button(action: onRetry) {
                        Text("다시 시도")
                            .tracking(-0.02)
                            .underline()
                            .foregroundColor(Color.purple)
                    }
                    .padding(25)
                    .multilineTextAlignment(.center)
                }
                
                Spacer()
                
            }
            .background(Color.white) // 배경색을 흰색으로 고정
            .navigationBarBackButtonHidden(true)
        }
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(.light) // 라이트 모드로 고정
    }
    
    @ViewBuilder
    private func setupNavigationBar() -> some View {
        HStack {
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image("back_arrow")
            }
            .frame(alignment: .leading)
            
            Spacer()
            
            Text("      ")
            
            Spacer()
            
            Text("      ")
        }
        .padding()
        .background(VStack {
            Spacer()
            Divider().background(Color.secondary)
        })
    }

    private var submitButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Text("홈으로 돌아가기")
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(Color.black)
                .cornerRadius(10)
                .padding(.horizontal, 40)
        }
    }
}

struct MyWebView_Previews: PreviewProvider {
    static var previews: some View {
        MyWebView(urlToLoad: "https://xive.co.kr/frida")
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView {
            // Retry action for preview purposes
        }
    }
}

