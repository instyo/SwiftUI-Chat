//
//  FriendsViewModel.swift
//  SwiftUI Chat
//
//  Created by ikhwan on 15/09/25.
//
import Foundation
import FirebaseFirestore


class FriendsViewModel: ObservableObject {
    private let db = Firestore.firestore()
    @Published var friendRequests: [FriendRequest] = []
    @Published var requestedUserIds: Set<String> = []
    @Published var receivedUserIds: Set<String> = []
    
    private let currentUser: ChatUser
    
    // Add these to store listener references
    private var sentRequestListener: ListenerRegistration?
    private var receivedRequestListener: ListenerRegistration?
    private var listenFriendRequest: ListenerRegistration?
    
    init(currentUser: ChatUser) {
        self.currentUser = currentUser
        listenForSentRequest()
        listenForReceivedRequest()
        listenAllFriendRequest()
    }
    
    deinit {
        sentRequestListener?.remove()
        receivedRequestListener?.remove()
        listenFriendRequest?.remove()
    }
    
    func listenAllFriendRequest() {
        
        guard let toUserId = currentUser.id else { return }
        
        listenFriendRequest = db.collection("friend_requests")
            .addSnapshotListener { [weak self] snap, error in
                if let error = error {
                    print("❌ Error listening for received requests: \(error.localizedDescription)")
                    return
                }
                
                guard let docs = snap?.documents else { return }
                
                DispatchQueue.main.async {
                    self?.friendRequests = snap?.documents.compactMap { doc in
                        try? doc.data(as: FriendRequest.self)
                    } ?? []
                }
            }
    }
    
    func sendFriendRequest(to userId: String) {
        Firestore.firestore()
            .collection("friend_requests")
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
                Firestore.firestore()
                    .collection("friend_requests")
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
    
    func acceptRequest(_ request: FriendRequest) {
        guard let id = request.id else { return }
        
        db.collection("friend_requests").document(id).updateData([
            "status": "accepted"
        ])
        
        // Add each other as friends
        let friendData = ["id": request.fromUserId, "createdAt": Timestamp()] as [String: Any]
        db.collection("users").document(currentUser.id ?? "")
            .collection("friends").document(request.fromUserId)
            .setData(friendData)
        
        let reverseData = ["id": currentUser.id ?? "", "createdAt": Timestamp()] as [String: Any]
        db.collection("users").document(request.fromUserId)
            .collection("friends").document(currentUser.id ?? "")
            .setData(reverseData)
    }
    
    func rejectRequest(_ request: FriendRequest) {
        guard let id = request.id else { return }
        db.collection("friend_requests").document(id).updateData([
            "status": "rejected"
        ])
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
}
