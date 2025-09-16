//
//  ChatUser.swift
//  SwiftUI Chat
//
//  Created by ikhwan on 14/09/25.
//


import Foundation
import FirebaseFirestore

struct ChatUser: Identifiable, Codable {
    @DocumentID var id: String?    // uid
    var displayName: String
    var email: String
    var createdAt: Date
    var profilePicture: String
    
    var imageUrl: URL? {
        return URL(string: profilePicture)
    }
}
