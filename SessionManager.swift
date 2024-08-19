//
//  SessionManager.swift
//  edenic.ai
//
//  Created by Neil Young on 8/7/24.
//

import Foundation
import SwiftUI
import Combine

class SessionManager: ObservableObject {
    @Published var accessToken: String?
    @Published var refreshToken: String?
    @Published var userInfo: String?

    init() {
        // Initialization if necessary
    }

    func loadSession(completion: @escaping () -> Void) {
        // Simulate an async load of session data
        DispatchQueue.global().async {
            // Retrieve tokens and user info from Keychain
            let accessToken = TokenManager.retrieveAccessToken()
            let refreshToken = TokenManager.retrieveRefreshToken()
            let userInfo = TokenManager.retrieveUserInfo()

            print("Loaded session: accessToken=\(String(describing: accessToken)), refreshToken=\(String(describing: refreshToken)), userInfo=\(String(describing: userInfo))")

            // Simulated delay and update published properties on the main thread
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {  // Simulated delay for demo purposes
                self.accessToken = accessToken
                self.refreshToken = refreshToken
                self.userInfo = userInfo
                completion()  // Notify completion
            }
        }
    }
}
