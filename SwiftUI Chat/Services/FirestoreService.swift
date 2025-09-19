//
//  FirestoreService.swift
//  SwiftUI Chat
//
//  Created by ikhwan on 16/09/25.
//


import FirebaseFirestore
import FirebaseAuth

class FirestoreService {
    private let db = Firestore.firestore()
    
    private var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    private var allUserListener: ListenerRegistration?
    
    // MARK: - Real-time Users
    func listenToAllUsers(onChange: @escaping ([UserModel]) -> Void) {
        guard let currentUserId else { return }
        
        allUserListener = db.collection("users")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error listening to users: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                let users = documents.compactMap { try? $0.data(as: UserModel.self) }
                    .filter { $0.id != currentUserId } // exclude self
                
                onChange(users)
            }
    }
    
    func removeUserListener() {
        allUserListener?.remove()
        allUserListener = nil
    }
    
    // MARK: - Friend Methods
    
    func sendFriendRequest(to userId: String) async throws {
        guard let currentUserId else { return }
        
        let now = Timestamp(date: Date())
        
        try await db.collection("users").document(currentUserId)
            .collection("friends").document(userId)
            .setData([
                "status": FriendStatus.outgoing.rawValue,
                "createdAt": now
            ])
        
        try await db.collection("users").document(userId)
            .collection("friends").document(currentUserId)
            .setData([
                "status": FriendStatus.incoming.rawValue,
                "createdAt": now
            ])
    }
    
    func acceptFriendRequest(from userId: String) async throws -> String {
        guard let currentUserId else { throw NSError(domain: "Auth", code: 0) }
        
        // Update both users' friend status
        try await db.collection("users").document(currentUserId)
            .collection("friends").document(userId)
            .updateData(["status": FriendStatus.accepted.rawValue])
        
        try await db.collection("users").document(userId)
            .collection("friends").document(currentUserId)
            .updateData(["status": FriendStatus.accepted.rawValue])
        
        // Create chat document
        let chatRef = db.collection("chats").document()
        try await chatRef.setData([
            "type": "private",
            "members": [currentUserId, userId],
            "createdAt": Timestamp(date: Date())
        ])
        
        return chatRef.documentID
    }
    
    func removeFriend(_ userId: String) async throws {
        guard let currentUserId else { return }
        
        try await db.collection("users").document(currentUserId)
            .collection("friends").document(userId)
            .delete()
        
        try await db.collection("users").document(userId)
            .collection("friends").document(currentUserId)
            .delete()
    }
    
    // MARK: - Chat Methods
    
    func startChat(with userId: String) async throws -> String {
        guard let currentUserId else { throw NSError(domain: "Auth", code: 0) }
        
        // Step 1: Check if a private chat already exists
        let snapshot = try await db.collection("chats")
            .whereField("type", isEqualTo: "private")
            .whereField("members", arrayContains: currentUserId)
            .getDocuments()
        
        if let existing = snapshot.documents.first(where: { doc in
            let members = doc["members"] as? [String] ?? []
            return members.contains(userId)
        }) {
            return existing.documentID
        }
        
        // Step 2: If not, create new chat
        let chatRef = db.collection("chats").document()
        try await chatRef.setData([
            "type": "private",
            "members": [currentUserId, userId],
            "createdAt": Timestamp(date: Date())
        ])
        
        return chatRef.documentID
    }
    
    func listenMessages(chatId: String, onChange: @escaping ([ChatMessage]) -> Void) -> ListenerRegistration {
            db.collection("chats")
                .document(chatId)
                .collection("messages")
                .order(by: "createdAt", descending: false)
                .addSnapshotListener { snapshot, error in
                    guard let documents = snapshot?.documents else { return }
                    let messages = documents.compactMap { try? $0.data(as: ChatMessage.self) }
                    onChange(messages)
                }
        }
        
        func sendMessage(chatId: String, text: String) async throws {
            guard let currentUserId else { throw NSError(domain: "Auth", code: 0) }
            
            let message = ChatMessage(
                senderId: currentUserId,
                text: text,
                createdAt: Date()
            )
            
            try await db.collection("chats")
                .document(chatId)
                .collection("messages")
                .addDocument(from: message)
        }
}
