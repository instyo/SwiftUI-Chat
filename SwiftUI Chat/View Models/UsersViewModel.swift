//
//  UsersViewModel.swift
//  SwiftUI Chat
//
//  Created by ikhwan on 15/09/25.
//

import FirebaseFirestore

@MainActor
class UsersViewModel: ObservableObject {
    @Published var users: [ChatUser] = []
    @Published var requestedUserIds: Set<String> = []
    @Published var receivedUserIds: Set<String> = []
    
    private let db = Firestore.firestore()
    private let currentUser: ChatUser
    
    // Add these to store listener references
    private var sentRequestListener: ListenerRegistration?
    private var receivedRequestListener: ListenerRegistration?
    
    init(currentUser: ChatUser) {
        self.currentUser = currentUser
        fetchUsers()
        listenForSentRequest()
        listenForReceivedRequest()
    }
    
    deinit {
        sentRequestListener?.remove()
        receivedRequestListener?.remove()
    }
    
    func fetchUsers() {
        db.collection("users")
            .getDocuments { snap, err in
                if let err = err {
                    print("❌ Error fetching users: \(err.localizedDescription)")
                    return
                }
                
                self.users = snap?.documents.compactMap { doc in
                    try? doc.data(as: ChatUser.self)
                }.filter { $0.id != self.currentUser.id } ?? []
                
                print("✅ Loaded \(self.users.count) users")
            }
    }
    
    func listenForSentRequest() {
        guard let fromId = currentUser.id else { return }
        
        sentRequestListener = db.collection("friend_requests")
            .whereField("fromUserId", isEqualTo: fromId)
            .addSnapshotListener { [weak self] snap, error in
                if let error = error {
                    print("❌ Error listening for sent requests: \(error.localizedDescription)")
                    return
                }
                
                guard let docs = snap?.documents else { return }
                
                DispatchQueue.main.async {
                    self?.requestedUserIds = Set(docs.compactMap { $0["toUserId"] as? String })
                    print("✅ Updated requested user IDs: \(self?.requestedUserIds ?? [])")
                }
            }
    }
    
    func listenForReceivedRequest() {
        guard let toUserId = currentUser.id else { return }
        
        receivedRequestListener = db.collection("friend_requests")
            .whereField("toUserId", isEqualTo: toUserId)
            .addSnapshotListener { [weak self] snap, error in
                if let error = error {
                    print("❌ Error listening for received requests: \(error.localizedDescription)")
                    return
                }
                
                guard let docs = snap?.documents else { return }
                
                DispatchQueue.main.async {
                    self?.receivedUserIds = Set(docs.compactMap { $0["fromUserId"] as? String })
                    print("✅ Updated received user IDs: \(self?.receivedUserIds ?? [])")
                }
            }
    }
    
    func sendFriendRequest(to userId: String) {
        db.collection("friend_requests")
            .whereField("fromUserId", isEqualTo: currentUser.id ?? "")
            .whereField("toUserId", isEqualTo: userId)
            .whereField("status", isEqualTo: "pending")
            .getDocuments { [weak self] snap, err in
                if let err = err {
                    print("❌ Error checking existing requests: \(err.localizedDescription)")
                    return
                }
                
                if let docs = snap?.documents, !docs.isEmpty {
                    print("⚠️ Friend request already exists")
                    return
                }
                
                // safe to add new request
                self?.db.collection("friend_requests")
                    .addDocument(data: [
                        "fromUserId": self?.currentUser.id ?? "",
                        "fromUserName": self?.currentUser.displayName ?? "",
                        "fromUserEmail": self?.currentUser.email ?? "",
                        "fromUserProfilePicture": self?.currentUser.profilePicture ?? "",
                        "toUserId": userId,
                        "status": "pending",
                        "createdAt": Timestamp()
                    ])
            }

    }

    func acceptRequest(from userId: String) {
        // Early return if currentUser.id is nil
        guard let currentUserId = currentUser.id else {
            print("Error: Current user ID is nil")
            return
        }
        
        db.collection("friend_requests")
            .whereField("fromUserId", isEqualTo: userId)
            .whereField("toUserId", isEqualTo: currentUserId)
            .whereField("status", isEqualTo: "pending")
            .getDocuments { [weak self] snapshot, error in
                
                // Handle errors
                if let error = error {
                    print("Error getting friend request: \(error.localizedDescription)")
                    return
                }
                
                // Check if documents exist
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("No pending friend request found")
                    return
                }
                
                // Get the document ID from the first matching document
                let documentId = documents[0].documentID
                
                // Create a batch write for atomic operations
                let batch = self?.db.batch()
                
                // Update friend request status
                let friendRequestRef = self?.db.collection("friend_requests").document(documentId)
                batch?.updateData(["status": "accepted"], forDocument: friendRequestRef!)
                
                // Add friends to both users (using batch for atomicity)
                let timestamp = Timestamp()
                
                // Add friend to current user's friends collection
                let currentUserFriendRef = self?.db.collection("users")
                    .document(currentUserId)
                    .collection("friends")
                    .document(userId)
                
                let friendData: [String: Any] = [
                    "id": userId,
                    "createdAt": timestamp
                ]
                batch?.setData(friendData, forDocument: currentUserFriendRef!)
                
                // Add current user to friend's friends collection
                let otherUserFriendRef = self?.db.collection("users")
                    .document(userId)
                    .collection("friends")
                    .document(currentUserId)
                
                let reverseData: [String: Any] = [
                    "id": currentUserId,
                    "createdAt": timestamp
                ]
                batch?.setData(reverseData, forDocument: otherUserFriendRef!)
                
                // Commit the batch
                batch?.commit { error in
                    if let error = error {
                        print("Error accepting friend request: \(error.localizedDescription)")
                    } else {
                        print("Friend request accepted successfully")
                    }
                }
            }
    }
}
