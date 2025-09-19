//
//  UsersViewModel.swift
//  SwiftUI Chat
//
//  Created by ikhwan on 16/09/25.
//


import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@MainActor
class UsersViewModel: ObservableObject {
    @Published var users: [UserWithFriendStatus] = []
    @Published var activeChatId: String? = nil

    private let db = Firestore.firestore()
    private let service = FirestoreService()
    private var listener: ListenerRegistration?
    private var friendsListener: ListenerRegistration?
    
    func startListening() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        // Listen to all users
        listener = db.collection("users").addSnapshotListener { [weak self] snapshot, error in
            guard let docs = snapshot?.documents else { return }
            let allUsers = docs.compactMap { try? $0.data(as: UserModel.self) }
                .filter { $0.id != currentUserId }
            
            // Listen to friend subcollection
            self?.friendsListener?.remove()
            self?.friendsListener = self?.db.collection("users").document(currentUserId)
                .collection("friends")
                .addSnapshotListener { friendSnap, _ in
                    var friendMap: [String: FriendStatus] = [:]
                    if let docs = friendSnap?.documents {
                        for doc in docs {
                            if let status = try? doc.data(as: FriendModel.self) {
                                if let fid = status.id {
                                    friendMap[fid] = status.status
                                }
                            }
                        }
                    }
                    
                    // Merge status into users
                    self?.users = allUsers.map { user in
                        UserWithFriendStatus(
                            user: user,
                            status: friendMap[user.id ?? ""] // nil if no entry
                        )
                    }
                }
        }
    }
    
    func stopListening() {
        listener?.remove()
        friendsListener?.remove()
    }
    
    func addFriend(userId: String) async {
        try? await service.sendFriendRequest(to: userId)
    }
    
    func acceptFriend(userId: String) async {
        do {
            let chatId = try await service.acceptFriendRequest(from: userId)
            activeChatId = chatId
        } catch {
            print("Error accepting friend : \(error.localizedDescription)")
        }
    }
    
    func startChat(with userId: String) async {
        do {
            let chatId = try await service.startChat(with: userId)
            activeChatId = chatId
        } catch {
            print("Error starting chat: \(error.localizedDescription)")
        }
    }
}
