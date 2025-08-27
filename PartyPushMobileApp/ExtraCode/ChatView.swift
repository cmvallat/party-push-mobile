//
//  ChatView.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 8/26/25.
//


// Demo for upcoming chat feature

import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let username: String
    let text: String
    let timestamp: Date
}

struct ChatView: View {
    @State private var messages: [ChatMessage] = [
        ChatMessage(username: "Alice", text: "Hey everyone!", timestamp: Date().addingTimeInterval(-3600)),
        ChatMessage(username: "Bob", text: "Hello Alice!", timestamp: Date().addingTimeInterval(-3590)),
        ChatMessage(username: "Charlie", text: "Hi! What's up?", timestamp: Date().addingTimeInterval(-3500)),
        ChatMessage(username: "Alice", text: "Ready to start the party?", timestamp: Date().addingTimeInterval(-3400))
    ]
    @State private var currentMessage: String = ""
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(messages) { message in
                            ChatMessageRow(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(.vertical)
                }
                .onChange(of: messages.count) { _ in
                    if let last = messages.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
            Divider()
            HStack {
                TextField("Enter message", text: $currentMessage, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .focused($isInputFocused)
                    .onSubmit(sendMessage)
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(currentMessage.trimmingCharacters(in: .whitespaces).isEmpty ? .gray : .accentColor)
                }
                .disabled(currentMessage.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding([.horizontal, .bottom])
            .background(Color(.systemBackground))
        }
        .navigationTitle("Chatroom")
    }

    private func sendMessage() {
        let trimmed = currentMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let newMessage = ChatMessage(username: "Me", text: trimmed, timestamp: Date())
        messages.append(newMessage)
        currentMessage = ""
        isInputFocused = true
    }
}

struct ChatMessageRow: View {
    let message: ChatMessage
    @State private var showTimestamp = false

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .top, spacing: 8) {
                Text(message.username)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.accentColor)
                Text(message.text)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            if showTimestamp {
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .transition(.opacity)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.secondarySystemBackground))
        )
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                withAnimation {
                    showTimestamp.toggle()
                }
            } label: {
                Label("Timestamp", systemImage: "clock")
            }
            .tint(.blue)
        }
    }
}

#Preview {
    NavigationStack {
        ChatView()
    }
}
