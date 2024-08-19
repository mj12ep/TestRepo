//
//  Item.swift
//  edenic-ai
//
//  Created by Neil Young on 3/14/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
