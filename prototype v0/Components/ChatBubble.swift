struct ChatBubble: View {
    let message: Message
    @State private var isHovering = false
    
    // Constants
    private enum Constants {
        static let bubblePadding: CGFloat = 12
        static let bubbleSpacing: CGFloat = 8
        static let maxWidth: CGFloat = 480
        static let minWidth: CGFloat = 80
        static let cornerRadius: CGFloat = 8
        static let avatarSize: CGFloat = 28
    }
    
    var body: some View {
        Group {
            switch message.sender {
            case .system:
                systemMessage
            default:
                regularMessage
            }
        }
    }
    
    // System Message
    private var systemMessage: some View {
        Text(message.contents.first?.text ?? "")
            .font(.system(size: 12))
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
    }
    
    // Regular Message
    private var regularMessage: some View {
        HStack(alignment: .bottom, spacing: Constants.bubbleSpacing) {
            if !message.isCurrentUser {
                messageAvatar
            }
            
            VStack(alignment: message.isCurrentUser ? .trailing : .leading, spacing: 4) {
                // Username (only show for non-current user)
                if !message.isCurrentUser {
                    userName
                }
                
                // Message content
                messageContent
                    .padding(Constants.bubblePadding)
                    .background(bubbleBackground)
                    .clipShape(bubbleShape)
            }
            
            if message.isCurrentUser {
                messageAvatar
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
    
    // Message Avatar
    @ViewBuilder
    private var messageAvatar: some View {
        switch message.sender {
        case .internal(let user), .external(let user):
            Avatar(user: user, size: Constants.avatarSize)
        case .ai:
            Image(systemName: "sparkle")
                .font(.system(size: 16))
                .frame(width: Constants.avatarSize, height: Constants.avatarSize)
                .background(Circle().fill(Color.blue.opacity(0.1)))
                .foregroundColor(.blue)
        case .system:
            EmptyView()
        }
    }
    
    // Username
    private var userName: some View {
        Text(extractUserName())
            .font(.system(size: 12))
            .foregroundColor(.secondary)
            .padding(.leading, Constants.bubblePadding)
    }
    
    // Message Content
    private var messageContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(message.contents.indices, id: \.self) { index in
                contentView(for: message.contents[index])
            }
        }
        .frame(maxWidth: Constants.maxWidth, minWidth: Constants.minWidth, alignment: message.isCurrentUser ? .trailing : .leading)
        .overlay(
            timeStamp
                .opacity(isHovering ? 1 : 0)
            , alignment: .bottomTrailing
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }
    
    // Content View Builder
    @ViewBuilder
    private func contentView(for content: MessageContentItem) -> some View {
        switch content {
        case .text(let text):
            Text(text)
                .foregroundColor(message.isCurrentUser ? .white : .primary)
                .textSelection(.enabled)
        case .link(let url, let preview):
            Link(preview ?? url.absoluteString, destination: url)
                .foregroundColor(message.isCurrentUser ? .white : .blue)
        case .file(let attachment):
            FileAttachmentView(attachment: attachment)
        }
    }
    
    // Timestamp
    private var timeStamp: some View {
        HStack(spacing: 4) {
            Text(message.timestamp, style: .time)
                .font(.system(size: 10))
                .foregroundColor(message.isCurrentUser ? .white.opacity(0.8) : .secondary)
            
            if message.isCurrentUser {
                Image(systemName: message.status.icon)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.trailing, 4)
        .padding(.bottom, 2)
    }
    
    // Background
    private var bubbleBackground: some View {
        Group {
            if message.isCurrentUser {
                Color.blue
            } else {
                Color(.windowBackgroundColor).opacity(0.5)
            }
        }
    }
    
    // Bubble Shape
    private var bubbleShape: some View {
        RoundedRectangle(cornerRadius: Constants.cornerRadius)
    }
    
    // Helper
    private func extractUserName() -> String {
        switch message.sender {
        case .internal(let user), .external(let user):
            return user.name
        case .ai:
            return "AI Assistant"
        case .system:
            return ""
        }
    }
}

// File Attachment View
struct FileAttachmentView: View {
    let attachment: FileAttachment
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: attachment.type.icon)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(attachment.name)
                    .font(.system(size: 14))
                Text(formatFileSize(attachment.size))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .padding(8)
        .background(Color(.separatorColor).opacity(0.1))
        .cornerRadius(6)
    }
    
    private func formatFileSize(_ size: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
}

// Preview
struct ChatBubble_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            ChatBubble(message: .preview)
            ChatBubble(message: .previewExternal)
            ChatBubble(message: .previewWithAttachment)
            ChatBubble(message: .previewMixed)
            ChatBubble(message: .previewAI)
            ChatBubble(message: .previewSystem)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.windowBackgroundColor))
    }
}