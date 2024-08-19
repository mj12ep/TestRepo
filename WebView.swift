import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    var url: URL
    var accessToken: String
    var refreshToken: String
    var userInfo: String
    var contentLoadedHandler: (() -> Void)?

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate {
        var parent: WebView
        weak var webView: WKWebView?

        init(parent: WebView) {
            self.parent = parent
        }

        private var contentLoaded = false

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            switch message.name {
            case "storeToken":
                if let tokens = message.body as? [String: String],
                   let accessToken = tokens["accessToken"],
                   let refreshToken = tokens["refreshToken"],
                   let userInfo = tokens["userInfo"] {
                    TokenManager.saveAccessToken(token: accessToken)
                    TokenManager.saveRefreshToken(token: refreshToken)
                    TokenManager.saveUserInfo(userInfo: userInfo)
                    print("Tokens and user info stored in Keychain")
                }

            case "clearToken":
                TokenManager.clearTokens()
                print("Tokens cleared from Keychain")

            case "shareLink":
                if let urlString = message.body as? String, let url = URL(string: urlString) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.presentShareSheet(url: url)
                    }
                } else {
                    print("Failed to create URL from shareLink string.")
                }

            case "consoleLog":
                if let logMessage = message.body as? String {
                    print("JavaScript Log: \(logMessage)")
                }

            case "contentLoaded":
                if !contentLoaded, let handler = parent.contentLoadedHandler {
                    contentLoaded = true
                    DispatchQueue.main.async {
                        handler()
                    }
                }

            default:
                print("Unhandled message: \(message.name)")
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if webView.url?.path.contains("/ios") == true || webView.url?.path.contains("/static/ios.html") == true {
                print("WebView finished navigation, injecting tokens.")
                parent.injectTokensAndUserInfoIntoWebView(webView)
            }
        }

        @objc
        func handleAppDidBecomeActive() {
            print("App became active, forcing WebView to redraw")
            DispatchQueue.main.async { [weak self] in
                guard let webView = self?.webView else { return }

                webView.scrollView.setContentOffset(.zero, animated: false)
                webView.scrollView.setContentInsetAndVisibleRect()
                webView.scrollView.isScrollEnabled = false
                webView.scrollView.isScrollEnabled = true

                // Evaluate JavaScript to trigger a re-render if necessary
                let jsCode = """
                document.body.dispatchEvent(new Event('visibilitychange'));
                if (typeof window.triggerContentRefresh === 'function') {
                    window.triggerContentRefresh();
                }
                scrollToBottom('chat-box');
                """
                webView.evaluateJavaScript(jsCode) { _, error in
                    if let error = error {
                        print("Error triggering visibility change event: \(error.localizedDescription)")
                    }
                }
            }
        }

        private func presentShareSheet(url: URL) {
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.windows.first?.rootViewController?.present(activityViewController, animated: true)
            }
        }
    }

    func makeUIView(context: Context) -> WKWebView {
        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.websiteDataStore = WKWebsiteDataStore.default()

        let webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator

        // Adding JavaScript message handlers
        webView.configuration.userContentController.add(context.coordinator, name: "shareLink")
        webView.configuration.userContentController.add(context.coordinator, name: "storeToken")
        webView.configuration.userContentController.add(context.coordinator, name: "clearToken")
        webView.configuration.userContentController.add(context.coordinator, name: "consoleLog")
        webView.configuration.userContentController.add(context.coordinator, name: "contentLoaded")

        let request = URLRequest(url: url)
        webView.load(request)

        // Add observer for appDidBecomeActive notification
        NotificationCenter.default.addObserver(context.coordinator, selector: #selector(context.coordinator.handleAppDidBecomeActive), name: .appDidBecomeActive, object: nil)

        context.coordinator.webView = webView

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func injectTokensAndUserInfoIntoWebView(_ webView: WKWebView) {
        let jsCode = """
        localStorage.setItem('access_token', '\(accessToken)');
        localStorage.setItem('refresh_token', '\(refreshToken)');
        localStorage.setItem('user_info', JSON.stringify(\(userInfo)));
        document.cookie = 'access_token=\(accessToken); path=/';
        document.cookie = 'refresh_token=\(refreshToken); path=/';
        document.cookie = 'user_info=' + JSON.stringify(\(userInfo)) + '; path=/';
        window.location.href = '/chat';
        """

        DispatchQueue.main.async {
            webView.evaluateJavaScript(jsCode, completionHandler: { (result, error) in
                if let error = error {
                    print("Error injecting JavaScript: \(error.localizedDescription)")
                } else {
                    print("JavaScript injected successfully: \(String(describing: result))")
                }
            })
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

// Extension for UIScrollView to handle visibility rect change
extension UIScrollView {
    func setContentInsetAndVisibleRect() {
        let visibleRect = CGRect(origin: contentOffset, size: bounds.size)
        scrollRectToVisible(visibleRect, animated: false)
    }
}
