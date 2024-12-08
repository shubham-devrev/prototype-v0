//
//  ChatBubble.swift
//  prototype v0
//
//  Created by Shubham Gandhi on 07/12/24.
//

import SwiftUI

private enum Constants {
    static let avatarBottomPadding: CGFloat = 16
    static let avatarSize: CGFloat = 32
    static let maxContentWidth: CGFloat = 400
    static let bubblePadding: CGFloat = 12
    static let bubbleSpacing: CGFloat = 8
    static let cornerRadius: CGFloat = 8
    static let fileAttachmentWidth: CGFloat = 160
}

struct ChatBubble: View {
    let message: Message
    let showAvatar: Bool
    let showTimestamp: Bool
    let showUsername: Bool
    let onFileClick: ((FileAttachment) -> Void)?
    let style: ChatBubbleStyle
    
    @State private var isHovering = false
    
    var body: some View {
        Group {
            if case .system = message.sender {
                systemMessage
            } else {
                regularMessage
            }
        }
    }
    
    private var systemMessage: some View {
        Text(message.contents.first?.text ?? "")
            .font(.system(size: 12))
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
    }
    
    private var regularMessage: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if !message.isCurrentUser && showAvatar {
                if case .internal(let user) = message.sender {
                    ChatAvatar(user: user, size: Constants.avatarSize)
                        .padding(.bottom, Constants.avatarBottomPadding)
                } else if case .external(let user) = message.sender {
                    ChatAvatar(user: user, size: Constants.avatarSize)
                        .padding(.bottom, Constants.avatarBottomPadding)
                }
            } else {
                Spacer()
                    .frame(width: showAvatar ? Constants.avatarSize : 0)
            }
            
            VStack(alignment: message.isCurrentUser ? .trailing : .leading, spacing: 4) {
                if showUsername {
                    if case .internal(let user) = message.sender {
                        Text(user.name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else if case .external(let user) = message.sender {
                        Text(user.name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                VStack(alignment: message.isCurrentUser ? .trailing : .leading, spacing: 2) {
                    messageContent
                    
                    if showTimestamp {
                        timestampView
                            .opacity(isHovering ? 1 : 0)
                            .animation(.easeInOut(duration: 0.2), value: isHovering)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: message.isCurrentUser ? .trailing : .leading)
            .onHover { hovering in
                isHovering = hovering
            }
            
            if message.isCurrentUser && showAvatar {
                if case .internal(let user) = message.sender {
                    ChatAvatar(user: user, size: Constants.avatarSize)
                        .padding(.bottom, Constants.avatarBottomPadding)
                }
            } else {
                Spacer()
                    .frame(width: showAvatar ? Constants.avatarSize : 0)
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var messageContent: some View {
        VStack(alignment: message.isCurrentUser ? .trailing : .leading, spacing: 8) {
            ForEach(0..<message.contents.count, id: \.self) { index in
                contentView(for: message.contents[index])
            }
        }
    }
    
    @ViewBuilder
    private func contentView(for content: MessageContentItem) -> some View {
        switch content {
        case .file(let attachment):
            FileAttachmentView(attachment: attachment, style: .compact, onRemove: nil)
                .onTapGesture {
                    onFileClick?(attachment)
                }
                .frame(width: Constants.fileAttachmentWidth, alignment: message.isCurrentUser ? .trailing : .leading)
                .help(attachment.name)
        case .text(let text):
            Text(text)
                .padding(Constants.bubblePadding)
                .foregroundColor(style.textColor)
                .background(
                    RoundedCorner(
                        radius: style.cornerRadius,
                        bottomLeadingRadius: message.isCurrentUser ? style.cornerRadius : 4,
                        bottomTrailingRadius: message.isCurrentUser ? 4 : style.cornerRadius
                    )
                    .fill(style.backgroundColor)
                )
                .frame(maxWidth: Constants.maxContentWidth, alignment: message.isCurrentUser ? .trailing : .leading)
        case .link(let url, let preview):
            Link(preview ?? url.absoluteString, destination: url)
                .padding(Constants.bubblePadding)
                .foregroundColor(style.textColor)
                .background(
                    RoundedCorner(
                        radius: style.cornerRadius,
                        bottomLeadingRadius: message.isCurrentUser ? style.cornerRadius : 4,
                        bottomTrailingRadius: message.isCurrentUser ? 4 : style.cornerRadius
                    )
                    .fill(style.backgroundColor)
                )
                .frame(maxWidth: Constants.maxContentWidth, alignment: message.isCurrentUser ? .trailing : .leading)
        }
    }
    
    private var timestampView: some View {
        HStack(spacing: 4) {
            Text(message.timestamp.formatted(.dateTime.hour().minute()))
                .font(.system(size: 10))
                .foregroundColor(.secondary.opacity(0.8))
            
            if message.isCurrentUser {
                Image(systemName: message.status.icon)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary.opacity(0.8))
            }
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 2)
    }
}

#if DEBUG
struct ChatBubble_Previews: PreviewProvider {
    // Preview styles
    private static let internalStyle = ChatBubbleStyle(
        backgroundColor: .blue.opacity(0.15),
        textColor: .primary,
        cornerRadius: 8
    )
    
    private static let externalStyle = ChatBubbleStyle(
        backgroundColor: .yellow.opacity(0.15),
        textColor: .primary,
        cornerRadius: 8
    )
    
    private static let aiStyle = ChatBubbleStyle(
        backgroundColor: .purple.opacity(0.15),
        textColor: .primary,
        cornerRadius: 8
    )
    
    private static let systemStyle = ChatBubbleStyle(
        backgroundColor: .clear,
        textColor: .secondary,
        cornerRadius: 8
    )
    
    static var previews: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Message Types Section
                PreviewSection("Message Types") {
                    ChatBubble(
                        message: Message.preview,
                        showAvatar: true,
                        showTimestamp: true,
                        showUsername: true,
                        onFileClick: nil,
                        style: internalStyle
                    )
                    
                    ChatBubble(
                        message: Message.previewExternal,
                        showAvatar: true,
                        showTimestamp: true,
                        showUsername: true,
                        onFileClick: nil,
                        style: externalStyle
                    )
                    
                    ChatBubble(
                        message: Message.previewAI,
                        showAvatar: true,
                        showTimestamp: true,
                        showUsername: true,
                        onFileClick: nil,
                        style: aiStyle
                    )
                    
                    ChatBubble(
                        message: Message.previewSystem,
                        showAvatar: true,
                        showTimestamp: true,
                        showUsername: true,
                        onFileClick: nil,
                        style: systemStyle
                    )
                }
                
                // Content Types Section
                PreviewSection("Content Types") {
                    ChatBubble(
                        message: Message.previewWithAttachment,
                        showAvatar: true,
                        showTimestamp: true,
                        showUsername: true,
                        onFileClick: { _ in },
                        style: internalStyle
                    )
                    
                    ChatBubble(
                        message: Message.previewMixed,
                        showAvatar: true,
                        showTimestamp: true,
                        showUsername: true,
                        onFileClick: { _ in },
                        style: externalStyle
                    )
                }
                
                // Long Messages Section
                PreviewSection("Long Messages") {
                    ChatBubble(
                        message: Message.previewLongMessage,
                        showAvatar: true,
                        showTimestamp: true,
                        showUsername: true,
                        onFileClick: nil,
                        style: internalStyle
                    )
                    
                    ChatBubble(
                        message: Message.previewMultiline,
                        showAvatar: true,
                        showTimestamp: true,
                        showUsername: true,
                        onFileClick: nil,
                        style: externalStyle
                    )
                }
                
                // Consecutive Messages Section
                PreviewSection("Consecutive Messages") {
                    VStack(spacing: 2) {
                        ChatBubble(
                            message: Message.previewConsecutive1,
                            showAvatar: true,
                            showTimestamp: true,
                            showUsername: true,
                            onFileClick: nil,
                            style: internalStyle
                        )
                        
                        ChatBubble(
                            message: Message.previewConsecutive2,
                            showAvatar: false,
                            showTimestamp: true,
                            showUsername: false,
                            onFileClick: nil,
                            style: internalStyle
                        )
                        
                        ChatBubble(
                            message: Message.previewConsecutive3,
                            showAvatar: false,
                            showTimestamp: true,
                            showUsername: false,
                            onFileClick: nil,
                            style: internalStyle
                        )
                    }
                }
                
                // Status Indicators Section
                PreviewSection("Message Status") {
                    ForEach(MessageStatus.allCases, id: \.self) { status in
                        ChatBubble(
                            message: Message.previewWithStatus(status),
                            showAvatar: true,
                            showTimestamp: true,
                            showUsername: true,
                            onFileClick: nil,
                            style: internalStyle
                        )
                    }
                }
            }
            .padding()
        }
        .frame(width: 500, height: 800)
        .background(Color(.windowBackgroundColor))
    }
}

// Preview Helper Views
private struct PreviewSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 16) {
                content
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// Additional Preview Messages
extension Message {
    static let previewLongMessage: Message = {
        do {
            return try Message(
                id: "long",
                contents: [.text("This is a very long message that should demonstrate how the chat bubble handles text wrapping for longer content. It should maintain readability while staying within the maximum width constraints.")],
                sender: .internal(User.previewInternal),
                status: .sent
            )
        } catch {
            fatalError("Failed to create preview message: \(error)")
        }
    }()
    
    static let previewMultiline: Message = {
        do {
            return try Message(
                id: "multiline",
                contents: [.text("This message has\nmultiple lines\nto show how line breaks\nare handled")],
                sender: .external(User.previewExternal),
                status: .delivered
            )
        } catch {
            fatalError("Failed to create preview message: \(error)")
        }
    }()
    
    static let previewConsecutive1: Message = {
        do {
            return try Message(
                id: "consecutive1",
                contents: [.text("First message in a consecutive series")],
                sender: .internal(User.previewInternal),
                status: .sent
            )
        } catch {
            fatalError("Failed to create preview message: \(error)")
        }
    }()
    
    static let previewConsecutive2: Message = {
        do {
            return try Message(
                id: "consecutive2",
                contents: [.text("Second message, no avatar or username")],
                sender: .internal(User.previewInternal),
                status: .sent
            )
        } catch {
            fatalError("Failed to create preview message: \(error)")
        }
    }()
    
    static let previewConsecutive3: Message = {
        do {
            return try Message(
                id: "consecutive3",
                contents: [.text("Third message in the series")],
                sender: .internal(User.previewInternal),
                status: .sent
            )
        } catch {
            fatalError("Failed to create preview message: \(error)")
        }
    }()
    
    static func previewWithStatus(_ status: MessageStatus) -> Message {
        do {
            return try Message(
                id: "status_\(status)",
                contents: [.text("Message with status: \(String(describing: status))")],
                sender: .internal(User.previewInternal),
                status: status
            )
        } catch {
            fatalError("Failed to create preview message: \(error)")
        }
    }
}
#endif
