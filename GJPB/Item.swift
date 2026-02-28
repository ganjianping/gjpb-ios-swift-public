//
//  Item.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
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
