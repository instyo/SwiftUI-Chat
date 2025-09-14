//
//  ChatListView.swift
//  SwiftUI Chat
//
//  Created by ikhwan on 14/09/25.
//

import SwiftUI
import CachedAsyncImage

struct ChatListView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @EnvironmentObject private var member: MemberViewModel
    @State private var searchText = ""
    @State private var isLoading = true
    @State private var debounceTask: Task<Void, Never>? = nil
    @State private var users: [ChatUser] = []
    
    private func searchUsers(with email: String) {
        isLoading = true
        
        member.searchUsers(byEmail: email) { users in
            self.users = users
            isLoading = false
        }
    }

    var body: some View {
        NavigationStack {
            
            VStack {
                if isLoading {
                    ProgressView()
                } else {
                    NavigationLink(destination: SearchView()) {
                        Text("See chats")
                    }
                }
            }
//            VStack {
//                Text("Hello World")
//                
//                if let user = auth.appUser {
//                    Text(user.displayName)
//                    Text(user.email)
//                    CachedAsyncImage(url: user.imageUrl!)
//                        .frame(width: 120, height: 120)
//                }
//                
//                Button("Logout") {
//                    do {
//                        try auth.signOut()
//                    } catch {
//                        print(error.localizedDescription)
//                    }
//                }
//            }
        }
        .onChange(of: searchText) { old, new in
            // Cancel previous task if still running
            debounceTask?.cancel()
            
            // Start new debounce task
            debounceTask = Task {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s
                
                if !Task.isCancelled {
                   searchUsers(with: new)
                }
            }
        }
        .onAppear {
            searchUsers(with: "bbbh@hh.com")
        }
    }
}
