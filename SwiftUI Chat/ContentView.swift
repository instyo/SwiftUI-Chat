//
//  ContentView.swift
//  SwiftUI Chat
//
//  Created by ikhwan on 14/09/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showingLogin = true
    @EnvironmentObject private var auth: AuthViewModel
    
    var body: some View {
        Group {
            if let user = auth.appUser {
                TabView {
                    ChatListView()
                        .tabItem {
                            Image(systemName: "person.badge.plus")
                            Text("Chats")
                        }
                    
                    FriendRequestsView()
                        .tabItem {
                            Image(systemName: "person.2")
                            Text("Friend Request")
                        }
                        .badge(2)
                }
                .environmentObject(FriendsViewModel(currentUser: user))
                .environmentObject(UsersViewModel(currentUser: user))
            } else {
                NavigationView {
                    if showingLogin {
                        LoginView(showingLogin: $showingLogin)
                    } else {
                        RegisterView(showingLogin: $showingLogin)
                    }
                }
            }
        }
    }
}
