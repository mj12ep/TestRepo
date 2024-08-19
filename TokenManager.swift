//
//  TokenManager.swift
//  edenic.ai
//
//  Created by Neil Young on 8/7/24.
//

import Foundation
class TokenManager {
    private static let accessTokenKey = "accessToken"
    private static let refreshTokenKey = "refreshToken"
    private static let userInfoKey = "userInfo"

    static func saveAccessToken(token: String) {
        KeychainHelper.save(key: accessTokenKey, value: token)
    }

    static func retrieveAccessToken() -> String? {
        return KeychainHelper.retrieve(key: accessTokenKey)
    }

    static func saveRefreshToken(token: String) {
        KeychainHelper.save(key: refreshTokenKey, value: token)
    }

    static func retrieveRefreshToken() -> String? {
        return KeychainHelper.retrieve(key: refreshTokenKey)
    }

    static func saveUserInfo(userInfo: String) {
        KeychainHelper.save(key: userInfoKey, value: userInfo)
    }

    static func retrieveUserInfo() -> String? {
        return KeychainHelper.retrieve(key: userInfoKey)
    }

    static func clearTokens() {
        KeychainHelper.delete(key: accessTokenKey)
        KeychainHelper.delete(key: refreshTokenKey)
        KeychainHelper.delete(key: userInfoKey)
    }
}
