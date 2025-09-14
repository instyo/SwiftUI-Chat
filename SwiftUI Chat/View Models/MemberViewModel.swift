//
//  MemberViewModel.swift
//  SwiftUI Chat
//
//  Created by ikhwan on 15/09/25.
//
import Foundation
import FirebaseFirestore

final class MemberViewModel: ObservableObject {
    static let shared = MemberViewModel()
    
    func searchUsers(byEmail email: String, completion: @escaping ([ChatUser]) -> Void) {
        Firestore.firestore().collection("users")
            .whereField("email", isEqualTo: email)
            .getDocuments { snap, err in
                guard let docs = snap?.documents else { completion([]); return }
                let users = docs.compactMap { try? $0.data(as: ChatUser.self)}
                completion(users)
            }
    }
}
