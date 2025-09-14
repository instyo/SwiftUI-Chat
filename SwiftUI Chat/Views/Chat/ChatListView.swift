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
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Hello World")
                
                if let user = auth.appUser {
                    Text(user.displayName)
                    Text(user.email)
                    CachedAsyncImage(url: user.imageUrl!)
                        .frame(width: 120, height: 120)
                }
                
                Button("Logout") {
                    do {
                        try auth.signOut()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}
