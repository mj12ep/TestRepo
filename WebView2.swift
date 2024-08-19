//
//  WebView2.swift
//  edenic.ai
//
//  Created by Neil Young on 8/7/24.
//

import Foundation
import SwiftUI
import WebKit

struct WebView2: UIViewRepresentable {
    var url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.websiteDataStore = WKWebsiteDataStore.default()

        let webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator

        webView.configuration.userContentController.add(context.coordinator, name: "shareLink")
        webView.configuration.userContentController.add(context.coordinator, name: "storeToken")
        webView.configuration.userContentController.add(context.coordinator, name: "clearToken")
        webView.configuration.userContentController.add(context.coordinator, name: "consoleLog")

        let request = URLRequest(url: url)
        webView.load(request)
        
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate {
        var parent: WebView2

        init(parent: WebView2) {
            self.parent = parent
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "storeToken", let tokens = message.body as? [String: String] {
                if let accessToken = tokens["accessToken"], let refreshToken = tokens["refreshToken"], let userInfo = tokens["userInfo"] {
                    TokenManager.saveAccessToken(token: accessToken)
                    TokenManager.saveRefreshToken(token: refreshToken)
                    TokenManager.saveUserInfo(userInfo: userInfo)
                    print("Tokens and user info stored in Keychain")
                }
            } else if message.name == "clearToken" {
                TokenManager.clearTokens()
                print("Tokens cleared from Keychain")
            }
            // Handle shareLink message
            else if message.name == "shareLink" {
                if let urlString = message.body as? String {
                    if let url = URL(string: urlString) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.presentShareSheet(url: url)
                        }
                    } else {
                        print("Failed to create URL from string: \(urlString)")
                    }
                } else {
                    print("shareLink message body is not a string.")
                }
            }
            // Handle consoleLog message
            else if message.name == "consoleLog" {
                if let logMessage = message.body as? String {
                    print("JavaScript Log: \(logMessage)")
                }
            }
        }

        private func presentShareSheet(url: URL) {
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)

            guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                  let rootViewController = windowScene.windows.first(where: \.isKeyWindow)?.rootViewController else {
                return
            }

            activityViewController.popoverPresentationController?.sourceView = rootViewController.view
            rootViewController.present(activityViewController, animated: true)
        }
    }
}
