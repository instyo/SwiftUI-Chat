//
//  FriendRequestListView.swift
//  SwiftUI Chat
//
//  Created by ikhwan on 15/09/25.
//

import SwiftUI

struct FriendRequestListView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @EnvironmentObject private var friend: FriendsViewModel
    @State private var isLoading: Bool = false
    
    var body: some View {
        NavigationStack {
            
            VStack {
                if isLoading {
                    ProgressView()
                } else {
                    ScrollView {
                        VStack {
                            ForEach(friend.friendRequests) { request in
                                FriendRequestTile(request: request)
                            }
                        }
                    }
                }
            }
        }
    }
}


struct FriendRequestTile: View {
    let request: FriendRequest
    @EnvironmentObject private var friend: FriendsViewModel
    @EnvironmentObject private var auth: AuthViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            // Animal Image
            Circle()
                .fill(Color.gray.opacity(0.1))
                .frame(width: 48, height: 48)
                .overlay(
                    AsyncImage(url: URL(string: request.fromUserProfilePicture)) { phase in
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
                Text(request.fromUserName)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(request.fromUserEmail)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            
            if request.status == "pending" {
                Button("Accept") {
                    friend.acceptRequest(request)
                }
            } else if request.status == "accepted" {
                Text("Accepted")
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
