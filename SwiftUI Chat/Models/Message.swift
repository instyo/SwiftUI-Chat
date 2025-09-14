//
//  Message.swift
//  SwiftUI Chat
//
//  Created by ikhwan on 14/09/25.
//
import Foundation
import FirebaseFirestore

struct Message: Identifiable, Codable {
  @DocumentID var id: String?
  var senderId: String
  var text: String
  var createdAt: Date
}
