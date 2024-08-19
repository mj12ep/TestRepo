//
//  KeychainHelper.swift
//  edenic.ai
//
//  Created by Neil Young on 8/7/24.
//

import Foundation
import Security

class KeychainHelper {
    static func save(key: String, value: String) {
        if let data = value.data(using: .utf8) {
            let query = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: key,
                kSecValueData: data,
                kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock
            ] as CFDictionary

            let status = SecItemAdd(query, nil)
            if status == errSecDuplicateItem {
                let updateQuery = [
                    kSecClass: kSecClassGenericPassword,
                    kSecAttrAccount: key
                ] as CFDictionary
                let attributesToUpdate = [
                    kSecValueData: data
                ] as CFDictionary
                SecItemUpdate(updateQuery, attributesToUpdate)
            } else if status != errSecSuccess {
                print("Error saving to Keychain: \(status)")
            }
        }
    }

    static func retrieve(key: String) -> String? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary

        var dataTypeRef: AnyObject? = nil
        let status = SecItemCopyMatching(query, &dataTypeRef)
        if status == errSecSuccess {
            if let data = dataTypeRef as? Data {
                return String(data: data, encoding: .utf8)
            }
        } else {
            print("Error retrieving from Keychain: \(status)")
        }
        return nil
    }

    static func delete(key: String) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ] as CFDictionary

        let status = SecItemDelete(query)
        if status != errSecSuccess {
            print("Error deleting from Keychain: \(status)")
        }
    }
}
