//
//  ImageCache.swift
//  SwiftUI Chat
//
//  Created by ikhwan on 14/09/25.
//

import Foundation

extension URLCache {
    static let imageCache = URLCache(memoryCapacity: 512_000_000, diskCapacity: 10_000_000_000)
}
