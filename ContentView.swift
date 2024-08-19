import SwiftUI

// Extension for checking device type
extension UIDevice {
    var isiPad: Bool {
        return userInterfaceIdiom == .pad
    }
    
    var isiPhone: Bool {
        return userInterfaceIdiom == .phone
    }
}

struct ContentView: View {
    @StateObject private var sessionManager = SessionManager()
    @State private var isSessionLoaded = false
    @State private var contentLoaded = false
    
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) var colorScheme // This environment variable helps track the color scheme

    var body: some View {
        ZStack {
            if isSessionLoaded {
                // Render WebView or WebView2 based on the presence of tokens
                if let accessToken = sessionManager.accessToken,
                   let refreshToken = sessionManager.refreshToken,
                   let userInfo = sessionManager.userInfo {
                    WebView(
                        url: URL(string: "https://to.gee.page/ios")!,
                        accessToken: accessToken,
                        refreshToken: refreshToken,
                        userInfo: userInfo,
                        contentLoadedHandler: {
                            if (!contentLoaded) {
                                withAnimation {
                                    contentLoaded = true
                                }
                            }
                        }
                    )
                    .opacity(contentLoaded ? 1 : 0)  // Hide the WebView until the content is loaded
                    .edgesIgnoringSafeArea(.all)
                } else {
                    WebView2(url: URL(string: "https://to.gee.page/chat")!)
                        .opacity(contentLoaded ? 1 : 0)  // Hide the WebView2 until content is loaded
                        .edgesIgnoringSafeArea(.all)
                        .onAppear {
                            // Simulate content loaded for WebView2
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                if (!contentLoaded) {
                                    withAnimation {
                                        contentLoaded = true
                                    }
                                }
                            }
                        }
                }
            }

            // Initial loading view with CustomThreeDotsProgressView
            if !contentLoaded {
                VStack {
                    HStack {
                        Text("hello")
                            .bold()
                            .foregroundColor(.blue) // Preserve text color as specified
                            .background(Color(colorScheme == .dark ? .black : .white)) // Adapt background color
                            .scaleEffect(2.0)
                        Text(":)")
                            .bold()
                            .foregroundColor(.red) // Preserve text color as specified
                            .background(Color(colorScheme == .dark ? .black : .white)) // Adapt background color
                            .scaleEffect(2.0)
                            .padding(.leading, UIDevice.current.isiPad ? 22 : 16) // Adjust padding based on device type
                        CustomThreeDotsProgressView()
                            .padding(.top, UIDevice.current.isiPad ? 14 : 0)
                    }
                    .padding()
                    .background(Color(colorScheme == .dark ? .black : .white)) // Adapt background color for entire context
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
        .onAppear {
            print("Loading session...")  // Debug print
            sessionManager.loadSession {
                withAnimation {
                    isSessionLoaded = true
                }
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                NotificationCenter.default.post(name: .appDidBecomeActive, object: nil)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView().environment(\.colorScheme, .light)
            ContentView().environment(\.colorScheme, .dark)
        }
    }
}

extension Notification.Name {
    static let appDidBecomeActive = Notification.Name("appDidBecomeActive")
}
