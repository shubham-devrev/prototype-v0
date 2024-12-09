import SwiftUI

struct ChatView: View {
    let chatId: String
    let isAIChat: Bool
    
    var chatPartner: User? {
        if isAIChat { return nil }
        return User.mockUsers.first { $0.id == chatId }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Chat header
            HStack {
                if isAIChat {
                    // AI Chat header
                    HStack {
                        Circle()
                            .fill(.white)
                            .frame(width: 32, height: 32)
                            .overlay {
                                Image(systemName: "sparkle")
                                    .foregroundStyle(.black)
                            }
                        Text("AI Assistant")
                            .font(.headline)
                    }
                } else if let user = chatPartner {
                    // User chat header
                    HStack {
                        Avatar(user: user, size: 32, showStatus: user.status == .online)
                        VStack(alignment: .leading) {
                            Text(user.name)
                                .font(.headline)
                            Text(user.email)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } else if chatId == "all-chats" {
                    HStack {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.title2)
                        Text("All Conversations")
                            .font(.headline)
                    }
                } else {
                    Text("Select a chat")
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(.ultraThinMaterial)
            
            Spacer()
            
            if let user = chatPartner {
                Text("Chat with \(user.name)")
                    .foregroundStyle(.secondary)
            } else if isAIChat {
                Text("Chat with AI Assistant")
                    .foregroundStyle(.secondary)
            } else if chatId == "all-chats" {
                Text("All your conversations")
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    ChatView(chatId: "1", isAIChat: false)
} 