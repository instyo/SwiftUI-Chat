//
//  ChatViewModel.swift
//  SwiftUI Chat
//
//  Created by ikhwan on 16/09/25.
//


import Combine
import FirebaseFirestore

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    
    private let service = FirestoreService()
    private var listener: ListenerRegistration?
    
    func startListening(chatId: String) {
        listener = service.listenMessages(chatId: chatId) { [weak self] msgs in
            Task { @MainActor in
                self?.messages = msgs
            }
        }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    func sendMessage(chatId: String) async {
        guard !inputText.isEmpty else { return }
        do {
            let text = inputText
            inputText = ""
            try await service.sendMessage(chatId: chatId, text: text)
        } catch {
            print("Error sending message: \(error.localizedDescription)")
        }
    }
}
