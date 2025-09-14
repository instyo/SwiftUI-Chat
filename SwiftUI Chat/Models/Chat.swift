//
//  Chat.swift
//  SwiftUI Chat
//
//  Created by ikhwan on 14/09/25.
//
import Foundation
import FirebaseFirestore

struct Chat: Identifiable, Codable {
  @DocumentID var id: String?
  var participantIds: [String]
  var lastMessage: String?
  var updatedAt: Date?
}
