//
//  Avatar.swift
//  prototype v0
//
//  Created by Shubham Gandhi on 05/12/24.
//

import SwiftUI

// 1. Constants
enum AvatarConstants {
    static let defaultSize: CGFloat = 40
    static let accountLogoRatio: CGFloat = 0.4  // Account logo size relative to avatar
    static let clipSizeRatio: CGFloat = 1.2    // Clip size relative to account logo
    static let cornerRadius: CGFloat = 4
    static let clipOffset: CGFloat = -5
    static let statusOffset: CGFloat = 2
    static let borderOpacity: Double = 0.1
}

// 2. Avatar with accessibility
/// A configurable avatar component that displays user information with optional account badge and status indicator
struct Avatar: View {
    /// The user whose information is displayed in the avatar
    let user: User
    
    /// The size of the avatar. Defaults to 40 points
    var size: CGFloat = AvatarConstants.defaultSize
    
    /// Whether to show the status indicator. Defaults to true
    var showStatus: Bool = true
    
    /// Whether to show the account badge for external users. Defaults to true
    var showAccount: Bool = true
    
    private let baseSize: CGFloat = AvatarConstants.defaultSize
    
    private var scale: CGFloat {
        size / baseSize
    }
    
    private var accountLogoSize: CGFloat {
        baseSize * AvatarConstants.accountLogoRatio
    }
    
    private var clipSize: CGFloat {
        accountLogoSize * AvatarConstants.clipSizeRatio
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ClippedAvatarView(
                user: user,
                baseSize: baseSize,
                clipSize: clipSize,
                showStatus: showStatus,
                showAccount: showAccount
            )
            
            if showAccount && user.type == .external, let account = user.account {
                AccountLogo(account: account, size: accountLogoSize)
                    .offset(x: 4, y: 4)
            }
        }
        .frame(width: baseSize, height: baseSize)
        .scaleEffect(scale)
        .frame(width: size, height: size)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }
    
    private var accessibilityLabel: String {
        var label = "\(user.name)"
        if user.type == .external, let account = user.account {
            label += ", from \(account.name)"
        }
        label += ", Status: \(user.status.rawValue)"
        return label
    }
}

// 3. Enhanced AvatarContent with error handling
struct AvatarContent: View {
    let user: User
    let baseSize: CGFloat
    
    var body: some View {
        Group {
            if let avatarUrl = user.avatarUrl {
                AsyncImage(url: avatarUrl) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: baseSize, height: baseSize)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .overlay(userTypeOverlay)
                    case .failure:
                        InitialsView(name: user.name, userType: user.type)
                            .overlay(
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.yellow)
                                    .opacity(0.15)
                            )
                    @unknown default:
                        InitialsView(name: user.name, userType: user.type)
                    }
                }
            } else {
                InitialsView(name: user.name, userType: user.type)
            }
        }
        .frame(width: baseSize, height: baseSize)
        .clipShape(Circle())
        .overlay(
            Circle()
                .strokeBorder(Color.white.opacity(AvatarConstants.borderOpacity), lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private var userTypeOverlay: some View {
        if user.type == .external {
            user.type.backgroundColor.opacity(1).blendMode(.color)
        } else {
            Color.clear
        }
    }
}

// 4. Documented ClippedAvatarView
/// A view that handles the clipping and status indicator for the avatar
struct ClippedAvatarView: View {
    let user: User
    let baseSize: CGFloat
    let clipSize: CGFloat
    let showStatus: Bool
    let showAccount: Bool
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if user.type == .external && showAccount {
                AvatarContent(user: user, baseSize: baseSize)
                    .clipShape(
                        AvatarClipShape(
                            clipSize: clipSize,
                            offset: AvatarConstants.clipOffset,
                            cornerRadius: AvatarConstants.cornerRadius
                        ),
                        style: FillStyle(eoFill: true)
                    )
            } else {
                AvatarContent(user: user, baseSize: baseSize)
            }
            
            if showStatus {
                StatusIndicator(status: user.status)
                    .offset(
                        x: AvatarConstants.statusOffset,
                        y: -AvatarConstants.statusOffset
                    )
            }
        }
    }
}

// Rest of the components remain the same...
struct AvatarClipShape: Shape {
    let clipSize: CGFloat
    let offset: CGFloat
    let cornerRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addEllipse(in: rect)
        
        let cutoutRect = CGRect(
            x: rect.maxX - clipSize - offset,
            y: rect.maxY - clipSize - offset,
            width: clipSize,
            height: clipSize
        )
        
        let roundedRect = Path(roundedRect: cutoutRect, cornerRadius: cornerRadius)
        path.addPath(roundedRect)
        return path
    }
}

// Add view modifier
extension Avatar {
    func showAccount(_ show: Bool) -> Avatar {
        var avatar = self
        avatar.showAccount = show
        return avatar
    }
}

struct InitialsView: View {
    let name: String
    let userType: User.UserType
    private var initials: String {
        let components = name.components(separatedBy: " ")
        switch userType {
        case .internal:
            // Only first letter for internal users
            return (components.first?.prefix(1) ?? "").uppercased()
        case .external:
            // First and last initials for external users
            let firstInitial = components.first?.prefix(1) ?? ""
            let lastInitial = components.count > 1 ? components.last?.prefix(1) ?? "" : ""
            return (firstInitial + lastInitial).uppercased()
        }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(userType.backgroundColor)
            Text(initials)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(userType.textColor)
        }
    }
}

struct StatusIndicator: View {
    let status: User.UserStatus
    var body: some View {
        Image(systemName: status.icon)
            .foregroundColor(status.color)
            .font(.system(size: 10, weight: .medium))
            .background(
                Circle()
                    .fill(Color(NSColor.black))
                    .frame(width: 14, height: 14)
            )
    }
}

// Preview
// Preview with sample images
struct Avatar_Previews: PreviewProvider {
    static let companies = [
        ("Microsoft", "microsoft.com"),
        ("Twitter", "twitter.com"),
        ("Slack", "slack.com"),
        ("Discord", "discord.com")
    ]
    
    static var sampleUsers: [User] = [
        // Internal user
        User(
            id: "1",
            name: "John Internal",
            email: "john@company.com",
            avatarUrl: URL(string: "https://i.pravatar.cc/150?img=1"),
            status: .online,
            role: .member,
            type: .internal
        ),
        
        // Generate external users with real company logos
        ] + companies.enumerated().map { index, company in
            User(
                id: String(index + 2),
                name: "User \(company.0)",
                email: "user@\(company.1)",
                avatarUrl: URL(string: "https://i.pravatar.cc/150?img=\(index + 2)"),
                status: [.online, .away, .dnd, .offline][index % 4],
                role: .member,
                type: .external,
                account: Account(
                    name: company.0,
                    logoUrl: URL(string: "https://logo.clearbit.com/\(company.1)")
                )
            )
        } + [
        // Internal user - No image
        User(
            id: "7",
            name: "Bob NoImage",
            email: "bob@company.com",
            avatarUrl: nil,
            status: .dnd,
            role: .member,
            type: .internal
        )
    ]
    
    static var previews: some View {
        VStack(spacing: 32) {
            // Account visibility states
           VStack(spacing: 16) {
               Text("Account Visibility").font(.headline)
               HStack(spacing: 24) {
                   VStack {
                       Avatar(user: sampleUsers[1], size: 48)
                           .showAccount(true)
                       Text("With Account")
                           .font(.caption2)
                           .foregroundColor(.secondary)
                   }
                   
                   VStack {
                       Avatar(user: sampleUsers[1], size: 48)
                           .showAccount(false)
                       Text("Without Account")
                           .font(.caption2)
                           .foregroundColor(.secondary)
                   }
               }
           }
            // Size variations
            VStack(spacing: 16) {
                Text("Size Variations").font(.headline)
                HStack(spacing: 16) {
                    ForEach([24, 32, 40, 48, 56], id: \.self) { size in
                        VStack {
                            Avatar(
                                user: sampleUsers[1], // Use external user for size demo
                                size: CGFloat(size)
                            )
                            Text("\(size)pt")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            // Different states
            VStack(spacing: 16) {
                Text("Avatar States").font(.headline)
                HStack(spacing: 24) {
                    ForEach(sampleUsers) { user in
                        VStack {
                            Avatar(user: user, size: 48)
                            Text(user.name.components(separatedBy: " ")[0])
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.sRGB, red: 46/360, green: 46/360, blue: 46/360))
    }
}
