//
//  AuthViewModel.swift
//  SwiftUI Chat
//
//  Created by ikhwan on 14/09/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class AuthViewModel : ObservableObject {
    static let shared = AuthViewModel()
    @Published var firebaseUser: FirebaseAuth.User?
    @Published var appUser: ChatUser?
    
    private var authListener: AuthStateDidChangeListenerHandle?
    
    private init() {
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.firebaseUser = user
            
            if let uid = user?.uid {
                self?.getAppUser(uid: uid)
            } else {
                self?.appUser = nil
            }
        }
    }
    
    func signUp(email: String, password: String, displayName: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            
            if let error = error {
                print(">> Auth Error: \(error)")
                print(">> Error Code: \(error._code)")
                print(">> Error Domain: \(error._domain)")
                completion(error)
                return
            }
            
            guard let user = result?.user else {
                print(">> No user returned from Auth")
                completion(NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user returned"]))
                return
            }
            
            let randomSeed = Int.random(in: 10...10000)
            let profilePicture = "https://api.dicebear.com/7.x/adventurer/jpg?seed=\(randomSeed)"
            
            let userDoc = ChatUser(id: user.uid, displayName: displayName, email: email, createdAt: Date(), profilePicture: profilePicture)
            
            do {
                try Firestore.firestore().collection("users").document(user.uid).setData(from: userDoc) { error in
                    if let error = error {
                        print(">> Firestore Error: \(error)")
                        print(">> Firestore Error Code: \(error._code)")
                        completion(error)
                    } else {
                        print(">> User document successfully created")
                        completion(nil)
                    }
                }
            } catch {
                print(">> Encoding Error: \(error)")
                completion(error)
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { _, err in completion(err) }
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    private func getAppUser(uid: String) {
        let ref = Firestore.firestore().collection("users").document(uid)
        ref.getDocument { snapshot, error in
            guard let doc = snapshot, doc.exists else { return }
            self.appUser = try? doc.data(as: ChatUser.self)
        }
    }
}
