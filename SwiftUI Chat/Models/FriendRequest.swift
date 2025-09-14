//
//  FriendRequest.swift
//  SwiftUI Chat
//
//  Created by ikhwan on 15/09/25.
//


import Foundation
import FirebaseFirestore

struct FriendRequest: Identifiable, Codable {
    @DocumentID var id: String?
    var fromId: String
    var toId: String
    var status: String
    var createdAt: Date
}
