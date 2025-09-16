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
    var fromUserId: String
    var fromUserName: String
    var fromUserEmail: String
    var fromUserProfilePicture: String
    var toUserId: String
    var status: String
    var createdAt: Date
    
    var profileImageUrl: URL? {
        return URL(string: fromUserProfilePicture)
    }
}

enum FriendRequestStatus {
    case pending
    case accepted
}
