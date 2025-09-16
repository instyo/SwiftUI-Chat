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
    @EnvironmentObject private var friend: FriendsViewModel
    @EnvironmentObject private var usersVM: UsersViewModel
    @State private var isLoading = true
    @State private var showingFriendRequest: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(usersVM.users) { user in
                                UserListTile(user: user)
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingFriendRequest, content: {
                FriendRequestListView()
            })
            .toolbar {
                ToolbarItem(placement: .topBarLeading, content: {
                    Button("Friend Request") {
                        showingFriendRequest = true
                    }
                })
                
                ToolbarItem(placement: .topBarTrailing, content: {
                    Button("Logout") {
                        do {
                            try auth.signOut()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                })
            }
            .navigationTitle("Users")
            .navigationBarTitleDisplayMode(.inline)
        }
        
        .onAppear {
            isLoading = true
            usersVM.fetchUsers()
            isLoading = false
        }
    }
}

struct UserListTile: View {
    let user: ChatUser
    @EnvironmentObject private var auth: AuthViewModel
    @EnvironmentObject private var usersVM: UsersViewModel
    
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
                
                Text(user.id ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if usersVM.requestedUserIds.contains(user.id ?? "") {
                Text("Request Sent")
                    .foregroundColor(.gray)
                    .font(.subheadline)
            } else if usersVM.receivedUserIds.contains(user.id ?? "") {
                Button("Approve Request") {
                    usersVM.acceptRequest(from: user.id ?? "")
                }
            } else {
                Button("Add Friend") {
                    if let userId = user.id {
                        usersVM.sendFriendRequest(to: userId)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture {
            // Handle tap action
        }
    }
}
