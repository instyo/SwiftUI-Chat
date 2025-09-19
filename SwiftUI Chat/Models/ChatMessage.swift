//
//  ChatMessage.swift
//  SwiftUI Chat
//
//  Created by ikhwan on 16/09/25.
//


import Foundation
import FirebaseFirestore

struct ChatMessage: Identifiable, Codable {
    @DocumentID var id: String?
    var senderId: String
    var text: String
    var createdAt: Date
}
