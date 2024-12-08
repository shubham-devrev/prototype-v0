//
//  User.swift
//  prototype v0
//
//  Created by Shubham Gandhi on 05/12/24.
//

import SwiftUI

struct User: Identifiable, Equatable, Codable {
    let id: String
    let name: String
    let email: String
    let avatarUrl: URL?
    let status: UserStatus
    let role: UserRole
    let type: UserType
    let account: Account?
    
    enum UserStatus: String, CaseIterable, Codable {
        case online
        case offline
        case away
        case dnd
        
        var icon: String {
            switch self {
            case .online: return "circle.fill"
            case .offline: return "circle"
            case .away: return "clock"
            case .dnd: return "minus.circle"
            }
        }
        
        var color: Color {
            switch self {
            case .online: return .green
            case .offline: return .gray
            case .away: return .yellow
            case .dnd: return .red
            }
        }
    }
    
    enum UserRole: String, Codable {
        case admin
        case member
    }
    
    enum UserType: String, Codable {
        case `internal`
        case external
        
        var backgroundColor: Color {
            switch self {
            case .internal: return Color(.sRGB, red: 51/360, green: 51/360, blue: 51/360, opacity: 1)
            case .external: return Color(.sRGB, red: 248/360, green: 213/360, blue: 125/360, opacity: 1)
            }
        }
        
        var textColor: Color {
            switch self {
            case .internal: return .white
            case .external: return Color(.sRGB, red: 118/360, green: 83/360, blue: 0/360, opacity: 1)
            }
        }
    }
    
    // Coding keys to ensure proper encoding/decoding
    private enum CodingKeys: String, CodingKey {
        case id, name, email, avatarUrl, status, role, type, account
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        email = try container.decode(String.self, forKey: .email)
        avatarUrl = try container.decodeIfPresent(URL.self, forKey: .avatarUrl)
        status = try container.decode(UserStatus.self, forKey: .status)
        role = try container.decode(UserRole.self, forKey: .role)
        type = try container.decode(UserType.self, forKey: .type)
        account = try container.decodeIfPresent(Account.self, forKey: .account)
        
        // Validate external users must have an account
        if type == .external && account == nil {
            throw DecodingError.dataCorruptedError(
                forKey: .account,
                in: container,
                debugDescription: "External users must have an associated account"
            )
        }
        
        // Validate internal users should not have an account
        if type == .internal && account != nil {
            throw DecodingError.dataCorruptedError(
                forKey: .account,
                in: container,
                debugDescription: "Internal users should not have an associated account"
            )
        }
    }
    
    init(id: String,
         name: String,
         email: String,
         avatarUrl: URL? = nil,
         status: UserStatus,
         role: UserRole,
         type: UserType,
         account: Account? = nil) {
        // Validate that external users must have an account
        precondition(
            !(type == .external && account == nil),
            "External users must have an associated account"
        )
        
        // Validate that internal users should not have an account
        precondition(
            !(type == .internal && account != nil),
            "Internal users should not have an associated account"
        )
        
        self.id = id
        self.name = name
        self.email = email
        self.avatarUrl = avatarUrl
        self.status = status
        self.role = role
        self.type = type
        self.account = account
    }
}

// Updated mock data
extension User {
    static let mockUsers = [
        User(id: "1",
             name: "John Doe",
             email: "john@company.com",
             avatarUrl: nil,
             status: .online,
             role: .admin,
             type: .internal),
        User(id: "2",
             name: "Jane Smith",
             email: "jane@external.com",
             avatarUrl: nil,
             status: .away,
             role: .member,
             type: .external),
    ]
}


// Add this to wherever your User model is defined
extension User {
    static let previewInternal = User(
        id: "1",
        name: "John Internal",
        email: "john@company.com",
        avatarUrl: URL(string: "https://i.pravatar.cc/150?img=1"),
        status: .online,
        role: .member,
        type: .internal
    )
    
    static let previewExternal = User(
        id: "2",
        name: "Jane External",
        email: "jane@external.com",
        avatarUrl: URL(string: "https://i.pravatar.cc/150?img=2"),
        status: .online,
        role: .member,
        type: .external,
        account: Account(
            name: "Acme Corp",
            logoUrl: URL(string: "https://logo.clearbit.com/acme.com")
        )
    )
}
