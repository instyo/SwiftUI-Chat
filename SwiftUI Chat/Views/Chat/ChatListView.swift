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
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(users) { user in
                                UserListTile(user: user)
                            }
                        }
                    }
                }
            }
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
//            searchUsers(with: "bbbh@hh.com")
            isLoading = true
            member.getAllUsers(myEmail: auth.firebaseUser?.email ?? "") { data in
                self.users = data
                isLoading = false
            }
        }
    }
}

struct UserListTile: View {
    let user: ChatUser
    
    var body: some View {
        HStack(spacing: 16) {
            // Animal Image
            Circle()
                .fill(Color.gray.opacity(0.1))
                .frame(width: 48, height: 48)
                .overlay(
                    AsyncImage(url: URL(string: user.profilePicture)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 48, height: 48)
                        } else if phase.error != nil {
                            Text("Failed to load")
                        } else {
                            ProgressView()
                        }
                    }
                )
            
            // Text Content
            VStack(alignment: .leading, spacing: 4) {
                Text(user.displayName)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(user.email)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture {
            // Handle tap action
        }
    }
}
