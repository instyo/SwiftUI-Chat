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
            if let user = auth.firebaseUser {
                ChatListView()
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
