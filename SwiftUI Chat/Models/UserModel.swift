//
//  UserModel.swift
//  SwiftUI Chat
//
//  Created by ikhwan on 16/09/25.
//

import Foundation
import FirebaseFirestore

struct UserModel: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var email: String
    var photoURL: String?
    var createdAt: Date
}

struct FriendModel: Identifiable, Codable {
    @DocumentID var id: String?
    var status: String   // "incoming" | "outgoing" | "accepted"
    var createdAt: Date
}

struct ChatModel: Identifiable, Codable {
    @DocumentID var id: String?
    var type: String     // "private" | "group"
    var members: [String]   // user IDs
    var lastMessage: String?
    var lastMessageAt: Date?
    var createdAt: Date
}

struct MessageModel: Identifiable, Codable {
    @DocumentID var id: String?
    var senderId: String
    var text: String
    var createdAt: Date
    var readBy: [String]?
}
