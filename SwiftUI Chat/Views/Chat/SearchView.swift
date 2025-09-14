//
//  SearchView 2.swift
//  SwiftUI Chat
//
//  Created by ikhwan on 15/09/25.
//
import FirebaseFirestore
import FirebaseAuth
import SwiftUI
import CachedAsyncImage

struct SearchView: View {
    @EnvironmentObject var friendsVM: FriendsViewModel
    @State private var email = ""
    @State private var userList: [ChatUser] = []
    var body: some View {
        VStack {
            TextField("Search by email", text: $email)
                .textFieldStyle(.roundedBorder)
                .padding()

            Button("Search") {
                friendsVM.searchUsers(byEmail: email) { userList in
                    self.userList = userList
                }
            }

            List(userList) { user in
                HStack(spacing: 2) {
                    CachedAsyncImage(url: user.imageUrl)
                        .frame(width: 40, height: 40)
                    VStack(alignment: .leading) {
                        Text(user.displayName)
                        Text(user.email).font(.subheadline).foregroundColor(.secondary)
                    }
                    Spacer()
                    Button("Add") {
                        if let id = user.id {
                            friendsVM.sendFriendRequest(to: id)
                        }
                    }
                }
            }
        }
        .navigationTitle("Search Users")
    }
}
