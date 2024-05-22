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
    @State private var showNavigationBars: Bool = true // 네비게이션 바 항상 보이도록 설정
    @State private var nfcButtonOffset: CGFloat = 0.0 // NFC 버튼 오프셋 추가
    @ObservedObject private var nfcViewModel = NFCViewModel() // NFCViewModel 추가

    var urlToLoad: String

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                setupNavigationBar() // 네비게이션 바 항상 보이도록 설정
                ZStack {
                    WebView(urlToLoad: urlToLoad)
                        .edgesIgnoringSafeArea(.all)
                }
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true) // 시스템 뒤로 가기 버튼 숨기기
        }
        .navigationBarBackButtonHidden(true) // 시스템 뒤로 가기 버튼 숨기기
        .onAppear {
            nfcViewModel.urlDetected = { url in
                // URL 처리
                self.handleURL(url)
            }
        }
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
            .frame(height: 44) // 상단바 높이 설정
            Divider().background(Color.secondary) // 구분선 추가
            .background(Color.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
        }
        .background(Color.white) // 상단바 배경 색상 추가
    }

    private func handleURL(_ url: String) {
        // URL 처리 및 서버 전송
        nfcViewModel.sendToServer(url: url)
    }
}

struct WebView: UIViewRepresentable {
    var urlToLoad: String

    func makeUIView(context: Context) -> WKWebView {
        guard let url = URL(string: self.urlToLoad) else {
            return WKWebView()
        }
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // 필요한 UI 업데이트 로직
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }
    }
}

struct MyWebView_Previews: PreviewProvider {
    static var previews: some View {
        MyWebView(urlToLoad: "https://xive.co.kr/frida")
    }
}
