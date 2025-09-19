//
//  ChatView.swift
//  SwiftUI Chat
//
//  Created by ikhwan on 16/09/25.
//
import SwiftUI
import FirebaseAuth

struct ChatView: View {
    @StateObject private var vm = ChatViewModel()
    let chatId: String
    
    var body: some View {
        VStack {
            messagesScrollView
//            inputBar
            // Input area
            HStack(spacing: 12) {
               
                
                HStack {
                    TextField("Write a message...", text: $vm.inputText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    
                    Button(action: {
                        Task { await vm.sendMessage(chatId: chatId) }
                    }) {
                        Image(systemName: "paperplane")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .rotationEffect(.degrees(45))
                    }.padding(.trailing, 16)
                }
                .background(Color(.systemGray6))
                .cornerRadius(25)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            vm.startListening(chatId: chatId)
        }
        .onDisappear {
            vm.stopListening()
        }
    }
    
    // Break out the ScrollView into a computed property
    private var messagesScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                messagesLazyVStack
                    .padding()
            }
            .onChange(of: vm.messages.count) { _, _ in
                if let lastId = vm.messages.last?.id {
                    withAnimation {
                        proxy.scrollTo(lastId, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    // Break out the LazyVStack into a computed property
    private var messagesLazyVStack: some View {
        LazyVStack(alignment: .leading, spacing: 8) {
            ForEach(vm.messages) { msg in
                MessageRow(
                    message: msg,
                    isCurrentUser: msg.senderId == Auth.auth().currentUser?.uid
                )
                .id(msg.id)
            }
        }
    }
    
    // Break out the input bar into a computed property
    private var inputBar: some View {
        HStack {
            messageTextField
            sendButton
        }
        .padding()
    }
    
    // Break out the TextField
    private var messageTextField: some View {
        TextField("Message...", text: $vm.inputText)
            .textFieldStyle(.roundedBorder)
    }
    
    // Break out the Send button
    private var sendButton: some View {
        Button("Send") {
            Task { await vm.sendMessage(chatId: chatId) }
        }
        .buttonStyle(.borderedProminent)
    }
}

struct MessageRow: View {
    let message: ChatMessage
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer()
                currentUserMessage
            } else {
                otherUserMessage
                Spacer()
            }
        }
    }
    
    // Break out current user message styling
    private var currentUserMessage: some View {
        Text(message.text)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                Color.blue
            )
            .foregroundColor(.white)
            .cornerRadius(20)
    }
    
    // Break out other user message styling
    private var otherUserMessage: some View {
        Text(message.text)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                Color(.systemGray5)
            )
            .foregroundColor(.primary)
            .cornerRadius(20)
    }
}
