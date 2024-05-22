//
//  KakaoWebView.swift
//  XIVE
//
//  Created by 나현흠 on 5/14/24.
//

import Foundation
import SwiftUI
import WebKit

struct KakaoWebView: UIViewRepresentable {
    let url: URL
    var navigationDelegate: WKNavigationDelegate?

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = navigationDelegate
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

