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
    @State private var showNavigationBars: Bool = false
    @ObservedObject private var nfcViewModel = NFCViewModel()
    @State private var showErrorView = false
    @State private var webViewReloadTrigger = UUID()
    @State private var stampID: Int?
    @State private var showNFCButton: Bool = false // Added state variable

    var urlToLoad: String
    var eventID: String
    var ticketID: String

    var body: some View {
        NavigationView {
            if showErrorView {
                ErrorView {
                    self.reloadWebView()
                }
            } else {
                VStack(spacing: 0) {
                    if showNavigationBars {
                        setupNavigationBar()
                            .transition(.move(edge: .top))
                            .animation(.easeInOut, value: showNavigationBars)
                    }

                    ZStack {
                        GeometryReader { geometry in
                            WebView(
                                urlToLoad: urlToLoad,
                                reloadTrigger: webViewReloadTrigger,
                                stampID: $stampID,
                                eventID: eventID,
                                ticketID: ticketID,
                                onError: {
                                    self.showErrorView = true
                                },
                                showNFCButton: $showNFCButton // Pass the binding
                            )
                            .edgesIgnoringSafeArea(.all)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        if value.translation.height > 0 { // 위에서 아래로 스크롤할 때
                                            withAnimation {
                                                self.showNavigationBars = true
                                            }
                                        } else if value.translation.height < 0 { // 아래에서 위로 스크롤할 때
                                            withAnimation {
                                                self.showNavigationBars = false
                                            }
                                        }
                                    }
                            )
                        }

                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                if showNFCButton { // Conditionally show the button
                                    setupNFCButton()
                                        .padding(.trailing, 15)
                                        .transition(.opacity) // Optional: Add transition for smooth appearance
                                }
                            }
                        }
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
        .onChange(of: stampID) { newStampID in
            if let stampID = newStampID {
                callNfcTaggingFunction(stampID: stampID)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    @ViewBuilder
    private func setupNFCButton() -> some View {
        Button(action: {
            nfcViewModel.beginScanning()
            nfcViewModel.urlDetected = { url in
                nfcViewModel.handleStampTagging(eventToken: url) { stampID in
                    if let stampID = stampID {
                        self.stampID = stampID
                        print("Received stampID: \(stampID)")
                    } else {
                        print("Failed to get stamp ID")
                    }
                }
            }
        }) {
            Image("NFCButton_Light")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .shadow(color: .gray.opacity(0.25), radius: 5, x: 10, y: 10)
                .shadow(color: .gray.opacity(0.25), radius: 5, x: -10, y: -10)
                .shadow(color: .gray.opacity(0.25), radius: 5, x: 10, y: -10)
                .shadow(color: .gray.opacity(0.25), radius: 5, x: -10, y: 10)
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
                Text("        ")
                Spacer()
                Text("        ")
            }
            .padding()
            .frame(height: 44)
            Divider()
                .background(Color.secondary)
                .background(Color.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
        }
        .background(Color.white)
    }

    private func handleURL(_ url: String) {
        nfcViewModel.handleDetectedURL(url: url)
    }

    private func callNfcTaggingFunction(stampID: Int) {
        guard let webView = getWebView() else {
            print("WebView not found")
            return
        }
        let js = "nfcTagging(\(stampID));"
        webView.evaluateJavaScript(js) { (result, error) in
            if let error = error {
                print("Error calling nfcTagging: \(error.localizedDescription)")
            }
        }
    }

    private func getWebView() -> WKWebView? {
        for subview in UIApplication.shared.windows.first?.rootViewController?.view.subviews ?? [] {
            if let webView = subview as? WKWebView {
                return webView
            }
        }
        return nil
    }

    private func reloadWebView() {
        self.showErrorView = false
        self.webViewReloadTrigger = UUID()
    }
}

struct WebView: UIViewRepresentable {
    var urlToLoad: String
    var reloadTrigger: UUID
    @Binding var stampID: Int?
    var eventID: String
    var ticketID: String
    var onError: () -> Void
    @Binding var showNFCButton: Bool // Added binding

    func makeUIView(context: Context) -> WKWebView {
        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: "iosHandler")

        let config = WKWebViewConfiguration()
        config.userContentController = contentController

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        loadRequest(in: webView)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if context.coordinator.previousReloadTrigger != reloadTrigger {
            loadRequest(in: uiView)
            context.coordinator.previousReloadTrigger = reloadTrigger
        }

        if let stampID = stampID {
            let js = "nfcTagging(\(stampID));"
            uiView.evaluateJavaScript(js) { (result, error) in
                if let error = error {
                    print("Error calling nfcTagging: \(error.localizedDescription)")
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    private func loadRequest(in webView: WKWebView) {
        guard let url = URL(string: self.urlToLoad) else {
            print("Invalid URL: \(self.urlToLoad)")
            self.onError()
            return
        }
        print("Loading URL: \(url)")
        webView.load(URLRequest(url: url))
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: WebView
        var previousReloadTrigger: UUID?

        init(_ parent: WebView) {
            self.parent = parent
        }

        // JavaScript에서 호출되는 함수
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "iosHandler", let messageBody = message.body as? String {
                print("JavaScript 메시지 수신: \(messageBody)")
                handleJavaScriptMessage(messageBody)
            }
        }

        func handleJavaScriptMessage(_ message: String) {
            // Update the showNFCButton based on the message
            DispatchQueue.main.async {
                switch message {
                case "1":
                    self.parent.showNFCButton = true
                case "2":
                    self.parent.showNFCButton = false
                case "3":
                    self.parent.showNFCButton = true
                default:
                    break
                }
            }
            print("JavaScript에서 받은 메시지: \(message)")
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let accessToken = UserDefaults.standard.string(forKey: "User_AccessToken") ?? ""
            let refreshToken = UserDefaults.standard.string(forKey: "User_RefreshToken") ?? ""
            let eventID = parent.eventID
            let ticketID = parent.ticketID
            let initWebJS = "initWeb('\(accessToken)', '\(refreshToken)', '\(eventID)', '\(ticketID)', true);"
            webView.evaluateJavaScript(initWebJS) { (result, error) in
                if let error = error {
                    print("Error calling initWeb: \(error.localizedDescription)")
                    print("Calling initWeb with accessToken: \(accessToken), refreshToken: \(refreshToken), eventID: \(eventID), ticketID: \(ticketID)")
                }
            }

            if let stampID = parent.stampID {
                let nfcTaggingJS = "nfcTagging(\(stampID));"
                webView.evaluateJavaScript(nfcTaggingJS) { (result, error) in
                    if let error = error {
                        print("Error calling nfcTagging: \(error.localizedDescription)")
                    }
                }
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("WebView did fail navigation with error: \(error.localizedDescription)")
            parent.onError()
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("WebView did fail provisional navigation with error: \(error.localizedDescription)")
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
                    .padding(.leading, 15)
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

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView {
            // Retry action for preview purposes
        }
    }
}
