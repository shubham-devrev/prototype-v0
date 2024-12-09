//
//  ChatBubble.swift
//  prototype v0
//
//  Created by Shubham Gandhi on 07/12/24.
//

import SwiftUI

private enum Constants {
    static let avatarBottomPadding: CGFloat = 16
    static let avatarSize: CGFloat = 24
    static let maxContentWidth: CGFloat = 400
    static let bubblePadding: CGFloat = 12
    static let bubbleSpacing: CGFloat = 8
    static let cornerRadius: CGFloat = 8
    static let fileAttachmentWidth: CGFloat = 160
}

struct ChatBubble<Content: View>: View {
    let content: Content
    let leadingAvatar: AnyView?
    let trailingAvatar: AnyView?
    let alignment: HorizontalAlignment
    let style: ChatBubbleStyle
    let showTimestamp: Bool
    let timestamp: Date?
    let statusIcon: String?
    let username: String?
    let isSystem: Bool
    
    @State private var isHovering = false
    
    init(
        style: ChatBubbleStyle,
        alignment: HorizontalAlignment = .leading,
        showTimestamp: Bool = false,
        timestamp: Date? = nil,
        statusIcon: String? = nil,
        username: String? = nil,
        leadingAvatar: AnyView? = nil,
        trailingAvatar: AnyView? = nil,
        isSystem: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.alignment = alignment
        self.showTimestamp = showTimestamp
        self.timestamp = timestamp
        self.statusIcon = statusIcon
        self.username = username
        self.leadingAvatar = leadingAvatar
        self.trailingAvatar = trailingAvatar
        self.isSystem = isSystem
        self.content = content()
    }
    
    var body: some View {
        Group {
            if isSystem {
                systemMessage
            } else {
                regularMessage
            }
        }
    }
    
    private var systemMessage: some View {
        content
            .font(.system(size: 12))
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
    }
    
    private var regularMessage: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if let leadingAvatar = leadingAvatar {
                leadingAvatar
                    .padding(.bottom, Constants.avatarBottomPadding)
            } else {
                Spacer()
            }
            
            VStack(alignment: alignment, spacing: 4) {
                if let username = username {
                    Text(username)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: alignment, spacing: 2) {
                    content
                        .padding(Constants.bubblePadding)
                        .foregroundColor(style.textColor)
                        .background(
                            RoundedCorner(
                                radius: style.cornerRadius,
                                bottomLeadingRadius: alignment == .trailing ? style.cornerRadius : 4,
                                bottomTrailingRadius: alignment == .trailing ? 4 : style.cornerRadius
                            )
                            .fill(style.backgroundColor)
                        )
                        .frame(maxWidth: Constants.maxContentWidth, alignment: alignment == .trailing ? .trailing : .leading)
                    
                    if showTimestamp {
                        timestampView
                            .opacity(isHovering ? 1 : 0)
                            .animation(.easeInOut(duration: 0.2), value: isHovering)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: alignment == .trailing ? .trailing : .leading)
            .onHover { hovering in
                isHovering = hovering
            }
            
            if let trailingAvatar = trailingAvatar {
                trailingAvatar
                    .padding(.bottom, Constants.avatarBottomPadding)
            } else {
                Spacer()
            }
        }
        .padding(.horizontal)
    }
    
    private var timestampView: some View {
        HStack(spacing: 4) {
            if let timestamp = timestamp {
                Text(timestamp.formatted(.dateTime.hour().minute()))
                    .font(.system(size: 10))
                    .foregroundColor(.secondary.opacity(0.8))
            }
            
            if let statusIcon = statusIcon {
                Image(systemName: statusIcon)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary.opacity(0.8))
            }
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 2)
    }
}

// Convenience initializer for creating bubbles with avatar views
extension ChatBubble {
    init<Avatar: View>(
        style: ChatBubbleStyle,
        alignment: HorizontalAlignment = .leading,
        showTimestamp: Bool = false,
        timestamp: Date? = nil,
        statusIcon: String? = nil,
        username: String? = nil,
        isSystem: Bool = false,
        avatar: Avatar?,
        isAvatarLeading: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            style: style,
            alignment: alignment,
            showTimestamp: showTimestamp,
            timestamp: timestamp,
            statusIcon: statusIcon,
            username: username,
            leadingAvatar: isAvatarLeading ? (avatar != nil ? AnyView(avatar) : nil) : nil,
            trailingAvatar: !isAvatarLeading ? (avatar != nil ? AnyView(avatar) : nil) : nil,
            isSystem: isSystem,
            content: content
        )
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
    
    // Sample users for previews
    private static let internalUser = User(
        id: "1",
        name: "John Internal",
        email: "john@company.com",
        avatarUrl: nil,
        status: .online,
        role: .member,
        type: .internal
    )
    
    private static let externalUser = User(
        id: "2",
        name: "Jane External",
        email: "jane@external.com",
        avatarUrl: nil,
        status: .online,
        role: .member,
        type: .external,
        account: Account(name: "External Corp", logoUrl: nil)
    )
    
    // Sample attachments for previews
    private static let sampleAttachments = [
        FileAttachment(
            id: "1",
            name: "Document.pdf",
            size: 1024 * 1024,
            mimeType: "application/pdf",
            url: URL(string: "https://example.com/doc.pdf")!,
            thumbnail: nil
        ),
        FileAttachment(
            id: "2",
            name: "Image.png",
            size: 512 * 1024,
            mimeType: "image/png",
            url: URL(string: "https://example.com/image.png")!,
            thumbnail: URL(string: "https://example.com/image_preview.png")
        )
    ]
    
    static var previews: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Message Types Section
                PreviewSection("Message Types") {
                    // Internal user message
                    ChatBubble(
                        style: internalStyle,
                        alignment: .trailing,
                        showTimestamp: true,
                        timestamp: Date(),
                        statusIcon: "checkmark",
                        username: "John Internal",
                        avatar: ChatAvatar(user: internalUser, size: Constants.avatarSize),
                        isAvatarLeading: false
                    ) {
                        Text("Internal user message")
                    }
                    
                    // External user message
                    ChatBubble(
                        style: externalStyle,
                        showTimestamp: true,
                        timestamp: Date(),
                        username: "Jane External",
                        avatar: ChatAvatar(user: externalUser, size: Constants.avatarSize)
                    ) {
                        Text("External user message")
                    }
                    
                    // AI message
                    ChatBubble(
                        style: aiStyle,
                        showTimestamp: true,
                        timestamp: Date(),
                        username: "AI Assistant",
                        avatar: AnyView(
                            Circle()
                                .fill(Color(.windowBackgroundColor))
                                .overlay {
                                    Image(systemName: "sparkle")
                                        .foregroundColor(.secondary)
                                }
                                .frame(width: Constants.avatarSize, height: Constants.avatarSize)
                        )
                    ) {
                        Text("AI assistant message")
                    }
                    
                    // System message
                    ChatBubble(
                        style: systemStyle,
                        isSystem: true
                    ) {
                        Text("System message")
                    }
                }
                
                // Content Types Section
                PreviewSection("Content Types") {
                    // Multiple content in single message
                    ChatBubble(
                        style: internalStyle,
                        alignment: .trailing,
                        showTimestamp: true,
                        timestamp: Date(),
                        username: "John Internal",
                        avatar: ChatAvatar(user: internalUser, size: Constants.avatarSize),
                        isAvatarLeading: false
                    ) {
                        VStack(alignment: .trailing, spacing: 8) {
                            Text("Here are the files you requested")
                            
                            FileAttachmentView(
                                attachment: sampleAttachments[0],
                                style: .compact,
                                onRemove: nil
                            )
                            .frame(width: Constants.fileAttachmentWidth)
                            
                            FileAttachmentView(
                                attachment: sampleAttachments[1],
                                style: .compact,
                                onRemove: nil
                            )
                            .frame(width: Constants.fileAttachmentWidth)
                            
                            Text("Let me know if you need anything else!")
                        }
                    }
                    
                    // Mixed content with link
                    ChatBubble(
                        style: externalStyle,
                        showTimestamp: true,
                        timestamp: Date(),
                        username: "Jane External",
                        avatar: ChatAvatar(user: externalUser, size: Constants.avatarSize)
                    ) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Check out this image and the documentation")
                            
                            FileAttachmentView(
                                attachment: sampleAttachments[1],
                                style: .compact,
                                onRemove: nil
                            )
                            .frame(width: Constants.fileAttachmentWidth)
                            
                            Link("View Documentation", destination: URL(string: "https://example.com/docs")!)
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                // Long Messages Section
                PreviewSection("Long Messages") {
                    ChatBubble(
                        style: internalStyle,
                        alignment: .trailing,
                        showTimestamp: true,
                        timestamp: Date()
                    ) {
                        Text("This is a very long message that should demonstrate how the chat bubble handles text wrapping for longer content. It should maintain readability while staying within the maximum width constraints.")
                    }
                    
                    ChatBubble(
                        style: externalStyle,
                        showTimestamp: true,
                        timestamp: Date()
                    ) {
                        Text("This message has\nmultiple lines\nto show how line breaks\nare handled")
                    }
                }
                
                // Consecutive Messages Section
                PreviewSection("Consecutive Messages") {
                    VStack(spacing: 2) {
                        ChatBubble(
                            style: internalStyle,
                            alignment: .trailing,
                            showTimestamp: true,
                            timestamp: Date(),
                            username: "John Internal",
                            avatar: ChatAvatar(user: internalUser, size: Constants.avatarSize),
                            isAvatarLeading: false
                        ) {
                            Text("First message in a consecutive series")
                        }
                        
                        ChatBubble(
                            style: internalStyle,
                            alignment: .trailing,
                            showTimestamp: true,
                            timestamp: Date()
                        ) {
                            Text("Second message, no avatar")
                        }
                        
                        ChatBubble(
                            style: internalStyle,
                            alignment: .trailing,
                            showTimestamp: true,
                            timestamp: Date()
                        ) {
                            Text("Third message in the series")
                        }
                    }
                }
                
                // Status Indicators Section
                PreviewSection("Status Indicators") {
                    ForEach(["checkmark", "checkmark.circle", "exclamationmark.circle"], id: \.self) { icon in
                        ChatBubble(
                            style: internalStyle,
                            alignment: .trailing,
                            showTimestamp: true,
                            timestamp: Date(),
                            statusIcon: icon
                        ) {
                            Text("Message with status: \(icon)")
                        }
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
#endif
