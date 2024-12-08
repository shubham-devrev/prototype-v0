//
//  Message.swift
//  prototype v0
//
//  Created by Shubham Gandhi on 07/12/24.
//

import Foundation
import SwiftUI

// MARK: - Message Types and Enums
enum MessageSender {
    case `internal`(User)
    case external(User)
    case ai
    case system
}

enum MessageStatus: CaseIterable {
    case sending
    case sent
    case delivered
    case read
    case failed
    
    var icon: String {
        switch self {
        case .sending: return "circle.dotted"
        case .sent: return "checkmark"
        case .delivered: return "checkmark.circle"
        case .read: return "checkmark.circle.fill"
        case .failed: return "exclamationmark.circle"
        }
    }
}

enum MessageContentItem {
    case text(String)
    case link(URL, String?) // URL and optional preview text
    case file(FileAttachment)
    
    var isText: Bool {
        if case .text = self { return true }
        return false
    }
}

extension MessageContentItem {
    var text: String? {
        if case .text(let string) = self {
            return string
        }
        return nil
    }
    
    var link: (URL, String?)? {
        if case .link(let url, let preview) = self {
            return (url, preview)
        }
        return nil
    }
    
    var file: FileAttachment? {
        if case .file(let attachment) = self {
            return attachment
        }
        return nil
    }
}

// MARK: - Message Model
struct Message: Identifiable, Codable {
    let id: String
    let contents: [MessageContentItem]
    let sender: MessageSender
    let timestamp: Date
    var status: MessageStatus
    var isEdited: Bool
    
    // Validation error type
    enum ValidationError: Error {
        case emptyContents
        case invalidSender
        case invalidTimestamp
    }
    
    // Coding Keys
    private enum CodingKeys: String, CodingKey {
        case id, contents, sender, timestamp, status, isEdited
    }
    
    // Custom decoder implementation
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        contents = try container.decode([MessageContentItem].self, forKey: .contents)
        sender = try container.decode(MessageSender.self, forKey: .sender)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        status = try container.decode(MessageStatus.self, forKey: .status)
        isEdited = try container.decode(Bool.self, forKey: .isEdited)
        
        // Validate after decoding
        guard !contents.isEmpty else {
            throw ValidationError.emptyContents
        }
        guard timestamp <= Date() else {
            throw ValidationError.invalidTimestamp
        }
    }
    
    // Custom encoder implementation
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(contents, forKey: .contents)
        try container.encode(sender, forKey: .sender)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(status, forKey: .status)
        try container.encode(isEdited, forKey: .isEdited)
    }
    
    // Regular initializer
    init(
        id: String = UUID().uuidString,
        contents: [MessageContentItem],
        sender: MessageSender,
        timestamp: Date = Date(),
        status: MessageStatus = .sending,
        isEdited: Bool = false
    ) throws {
        // Validate contents
        guard !contents.isEmpty else {
            throw ValidationError.emptyContents
        }
        
        // Validate timestamp
        guard timestamp <= Date() else {
            throw ValidationError.invalidTimestamp
        }
        
        self.id = id
        self.contents = contents
        self.sender = sender
        self.timestamp = timestamp
        self.status = status
        self.isEdited = isEdited
    }
    
    // Convenience initializer for text-only messages
    init(
        id: String = UUID().uuidString,
        text: String,
        sender: MessageSender,
        timestamp: Date = Date(),
        status: MessageStatus = .sending,
        isEdited: Bool = false
    ) throws {
        try self.init(
            id: id,
            contents: [.text(text)],
            sender: sender,
            timestamp: timestamp,
            status: status,
            isEdited: isEdited
        )
    }
    
    // Async file attachment handling
    func processAttachments() async throws -> [FileAttachment] {
        let attachments = contents.compactMap { content -> FileAttachment? in
            if case .file(let attachment) = content {
                return attachment
            }
            return nil
        }
        
        // Process attachments asynchronously
        return try await withThrowingTaskGroup(of: FileAttachment.self) { group in
            for attachment in attachments {
                group.addTask {
                    // Validate and process attachment
                    return try await validateAndProcessAttachment(attachment)
                }
            }
            
            var processedAttachments: [FileAttachment] = []
            for try await attachment in group {
                processedAttachments.append(attachment)
            }
            return processedAttachments
        }
    }
    
    private func validateAndProcessAttachment(_ attachment: FileAttachment) async throws -> FileAttachment {
        // Validate file exists
        guard await FileManager.default.fileExists(atPath: attachment.url.path) else {
            throw FileError.fileNotFound
        }
        
        // Validate file size
        let attributes = try await FileManager.default.attributesOfItem(atPath: attachment.url.path)
        guard let fileSize = attributes[.size] as? Int64, fileSize > 0 else {
            throw FileError.invalidFileSize
        }
        
        return attachment
    }
}

// MARK: - Error Types
enum FileError: Error {
    case fileNotFound
    case invalidFileSize
    case processingFailed
    case thumbnailGenerationFailed
}

// Make MessageSender Codable
extension MessageSender: Codable {
    private enum CodingKeys: String, CodingKey {
        case type, user
    }
    
    private enum SenderType: String, Codable {
        case `internal`, external, ai, system
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .internal(let user):
            try container.encode(SenderType.internal, forKey: .type)
            try container.encode(user, forKey: .user)
        case .external(let user):
            try container.encode(SenderType.external, forKey: .type)
            try container.encode(user, forKey: .user)
        case .ai:
            try container.encode(SenderType.ai, forKey: .type)
        case .system:
            try container.encode(SenderType.system, forKey: .type)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(SenderType.self, forKey: .type)
        
        switch type {
        case .internal:
            let user = try container.decode(User.self, forKey: .user)
            self = .internal(user)
        case .external:
            let user = try container.decode(User.self, forKey: .user)
            self = .external(user)
        case .ai:
            self = .ai
        case .system:
            self = .system
        }
    }
}

// Make MessageContentItem Codable
extension MessageContentItem: Codable {
    private enum CodingKeys: String, CodingKey {
        case type, content, url, preview, file
    }
    
    private enum ContentType: String, Codable {
        case text, link, file
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .text(let string):
            try container.encode(ContentType.text, forKey: .type)
            try container.encode(string, forKey: .content)
        case .link(let url, let preview):
            try container.encode(ContentType.link, forKey: .type)
            try container.encode(url, forKey: .url)
            try container.encodeIfPresent(preview, forKey: .preview)
        case .file(let attachment):
            try container.encode(ContentType.file, forKey: .type)
            try container.encode(attachment, forKey: .file)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ContentType.self, forKey: .type)
        
        switch type {
        case .text:
            let content = try container.decode(String.self, forKey: .content)
            self = .text(content)
        case .link:
            let url = try container.decode(URL.self, forKey: .url)
            let preview = try container.decodeIfPresent(String.self, forKey: .preview)
            self = .link(url, preview)
        case .file:
            let attachment = try container.decode(FileAttachment.self, forKey: .file)
            self = .file(attachment)
        }
    }
}

extension Message {
    var isCurrentUser: Bool {
        // TODO: Replace with actual current user check
        if case .internal(let user) = sender {
            return user.id == User.previewInternal.id // Replace with actual current user check
        }
        return false
    }
}

// MARK: - Preview Helpers
#if DEBUG
extension Message {
    static let preview: Message = {
        do {
            return try Message(
                id: "1",
                contents: [.text("Hey, just checking in on the project status.")],
                sender: .internal(User.previewInternal),
                status: .sent
            )
        } catch {
            fatalError("Failed to create preview message: \(error)")
        }
    }()
    
    static let previewExternal: Message = {
        do {
            return try Message(
                id: "2",
                contents: [.text("Thanks for reaching out. We're making good progress!")],
                sender: .external(User.previewExternal),
                status: .delivered
            )
        } catch {
            fatalError("Failed to create preview external message: \(error)")
        }
    }()
    
    static let previewWithAttachment: Message = {
        do {
            return try Message(
                id: "3",
                contents: [
                    .text("Here's the latest report"),
                    .file(FileAttachment(
                        id: "1",
                        name: "Q4_Report.pdf",
                        size: 1024 * 1024,
                        mimeType: "application/pdf",
                        url: URL(string: "https://example.com/doc.pdf")!
                    ))
                ],
                sender: .internal(User.previewInternal),
                status: .sent
            )
        } catch {
            fatalError("Failed to create preview attachment message: \(error)")
        }
    }()
    
    static let previewMixed: Message = {
        do {
            return try Message(
                id: "4",
                contents: [
                    .text("Please review these resources:"),
                    .link(URL(string: "https://example.com")!, "Documentation"),
                    .file(FileAttachment(
                        id: "2",
                        name: "screenshot.png",
                        size: 512 * 1024,
                        mimeType: "image/png",
                        url: URL(string: "https://example.com/image.png")!,
                        thumbnail: URL(string: "https://example.com/image_thumb.png")
                    ))
                ],
                sender: .external(User.previewExternal),
                status: .delivered
            )
        } catch {
            fatalError("Failed to create preview mixed message: \(error)")
        }
    }()
    
    static let previewAI: Message = {
        do {
            return try Message(
                id: "5",
                contents: [.text("I can help you with that. What specific information do you need?")],
                sender: .ai,
                status: .delivered
            )
        } catch {
            fatalError("Failed to create preview AI message: \(error)")
        }
    }()
    
    static let previewSystem: Message = {
        do {
            return try Message(
                id: "6",
                contents: [.text("John joined the conversation")],
                sender: .system,
                status: .delivered
            )
        } catch {
            fatalError("Failed to create preview system message: \(error)")
        }
    }()
    
    // Additional example messages for testing different scenarios
    static let exampleMessages: [Message] = {
        do {
            return [
                try Message(
                    id: "7",
                    contents: [.text("Hi there! How can I help you today?")],
                    sender: .internal(User.previewInternal),
                    status: .read
                ),
                try Message(
                    id: "8",
                    contents: [
                        .text("I found some issues in the latest build"),
                        .file(FileAttachment(
                            id: "3",
                            name: "error_log.txt",
                            size: 1024,
                            mimeType: "text/plain",
                            url: URL(string: "https://example.com/log.txt")!
                        ))
                    ],
                    sender: .external(User.previewExternal),
                    status: .delivered
                )
            ]
        } catch {
            fatalError("Failed to create example messages: \(error)")
        }
    }()
}
#endif

// Make MessageStatus Codable
extension MessageStatus: Codable {
    enum CodingKeys: String, CodingKey {
        case rawValue
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let rawValue: String
        switch self {
        case .sending: rawValue = "sending"
        case .sent: rawValue = "sent"
        case .delivered: rawValue = "delivered"
        case .read: rawValue = "read"
        case .failed: rawValue = "failed"
        }
        try container.encode(rawValue, forKey: .rawValue)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawValue = try container.decode(String.self, forKey: .rawValue)
        switch rawValue {
        case "sending": self = .sending
        case "sent": self = .sent
        case "delivered": self = .delivered
        case "read": self = .read
        case "failed": self = .failed
        default: throw DecodingError.dataCorruptedError(forKey: .rawValue, in: container, debugDescription: "Invalid message status")
        }
    }
}

// MARK: - Preview Data
extension Message {
    static var previewData: [Message] = {
        do {
            return [
                try Message(
                    id: "1",
                    contents: [.text("Hi there! How can I help you today?")],
                    sender: .internal(User.previewInternal),
                    status: .read
                ),
                try Message(
                    id: "2",
                    contents: [
                        .text("I found some issues in the latest build"),
                        .file(FileAttachment(
                            id: "3",
                            name: "error_log.txt",
                            size: 1024,
                            mimeType: "text/plain",
                            url: URL(string: "https://example.com/log.txt")!
                        ))
                    ],
                    sender: .external(User.previewExternal),
                    status: .delivered
                ),
                try Message(
                    id: "3",
                    contents: [
                        .text("Here's the documentation that might help:"),
                        .link(URL(string: "https://docs.example.com")!, "API Documentation"),
                        .file(FileAttachment(
                            id: "4",
                            name: "guide.pdf",
                            size: 2048576,
                            mimeType: "application/pdf",
                            url: URL(string: "https://example.com/guide.pdf")!
                        ))
                    ],
                    sender: .ai,
                    status: .delivered
                ),
                try Message(
                    id: "4",
                    contents: [.text("Team meeting starting in 5 minutes")],
                    sender: .system,
                    status: .delivered
                )
            ]
        } catch {
            fatalError("Failed to create preview messages: \(error)")
        }
    }()
}
