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
    @Published var friends: [ChatUser] = []

    let currentUser: ChatUser

    init(currentUser: ChatUser) {
        self.currentUser = currentUser
        listenForRequests()
        listenForFriends()
    }
    
    func searchUsers(byEmail email: String, completion: @escaping ([ChatUser]) -> Void) {
        print("🔍 [SearchUsers] Starting search for email: \(email)")
        
        Firestore.firestore().collection("users")
            .whereField("email", isEqualTo: email)
            .getDocuments { snap, err in
                if let err = err {
                    print("❌ [SearchUsers] Error fetching users: \(err.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let docs = snap?.documents else {
                    print("⚠️ [SearchUsers] No documents found for email: \(email)")
                    completion([])
                    return
                }
                
                print("✅ [SearchUsers] Found \(docs.count) document(s) for email: \(email)")
                
                let users = docs.compactMap { doc -> ChatUser? in
                    do {
                        let user = try doc.data(as: ChatUser.self)
                        print("👤 [SearchUsers] Parsed user: \(user)")
                        return user
                    } catch {
                        print("⚠️ [SearchUsers] Failed to decode user from docID: \(doc.documentID), error: \(error)")
                        return nil
                    }
                }
                
                print("📦 [SearchUsers] Returning \(users.count) user(s)")
                completion(users)
            }
    }


    func sendFriendRequest(to userId: String) {
        Firestore.firestore()
            .collection("friendRequests")
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
                    .collection("friendRequests")
                    .addDocument(data: [
                        "fromUserId": self?.currentUser.id ?? "",
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
        let friendData = ["id": request.fromId, "createdAt": Timestamp()] as [String: Any]
        db.collection("users").document(currentUser.id ?? "")
            .collection("friends").document(request.fromId)
            .setData(friendData)

        let reverseData = ["id": currentUser.id ?? "", "createdAt": Timestamp()] as [String: Any]
        db.collection("users").document(request.fromId)
            .collection("friends").document(currentUser.id ?? "")
            .setData(reverseData)
    }

    func rejectRequest(_ request: FriendRequest) {
        guard let id = request.id else { return }
        db.collection("friend_requests").document(id).updateData([
            "status": "rejected"
        ])
    }

    private func listenForRequests() {
        db.collection("friend_requests")
            .whereField("toId", isEqualTo: currentUser.id ?? "")
            .whereField("status", isEqualTo: "pending")
            .addSnapshotListener { [weak self] snap, _ in
                guard let docs = snap?.documents else { return }
                self?.friendRequests = docs.compactMap { try? $0.data(as: FriendRequest.self) }
            }
    }

    private func listenForFriends() {
        db.collection("users").document(currentUser.id ?? "").collection("friends")
            .addSnapshotListener { [weak self] snap, _ in
                guard let docs = snap?.documents else { return }
                self?.friends = docs.compactMap { try? $0.data(as: ChatUser.self) }
            }
    }
}
