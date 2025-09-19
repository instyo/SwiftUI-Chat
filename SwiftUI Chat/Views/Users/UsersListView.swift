//
//  UsersListView.swift
//  SwiftUI Chat
//
//  Created by ikhwan on 16/09/25.
//
import SwiftUI

struct UsersListView: View {
    @StateObject private var vm = UsersViewModel()
    
    var body: some View {
        NavigationStack {
            List(vm.users) { item in
                HStack {
                    Circle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 48, height: 48)
                        .overlay(
                            AsyncImage(url: URL(string: item.user.photoURL ?? "")) { phase in
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
                    Text(item.user.name)
                    Spacer()
                    
                    if let status = item.status {
                        switch status {
                        case .outgoing:
                            Text("Request Sent")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        case .incoming:
                            Button("Accept") {
                                Task { await vm.acceptFriend(userId: item.user.id!) }
                            }
                            .buttonStyle(.borderedProminent)
                        case .accepted:
                            Text("Friends")
                                .foregroundColor(.green)
                                .font(.subheadline)
                        case .blocked:
                            Text("Blocked")
                        }
                    } else {
                        Button("Add") {
                            Task { await vm.addFriend(userId: item.user.id!) }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if item.status == .accepted {
                        Task {
                            await vm.startChat(with: item.user.id ?? "")
                        }
                    }
                }
            }
            .navigationTitle("All Users")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { vm.startListening() }
            .onDisappear { vm.stopListening() }
            .navigationDestination(item: $vm.activeChatId) { chatId in
                ChatView(chatId: chatId)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing, content: {
                    Button("Sign out") {
                        do {
                            try AuthViewModel.shared.signOut()
                        } catch {
                            print("Failed to logout")
                        }
                    }
                })
            }
        }
    }
}
