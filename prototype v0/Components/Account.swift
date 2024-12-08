//
//  Account.swift
//  prototype v0
//
//  Created by Shubham Gandhi on 07/12/24.
//

import SwiftUI

struct AccountLogo: View {
    let account: Account
    let size: CGFloat
    let cornerRadius: CGFloat = 6
    
    // Base size for consistency
    private let baseSize: CGFloat = 32
    
    private var scale: CGFloat {
        size / baseSize
    }
    
    var body: some View {
        Group {
            if let logoUrl = account.logoUrl {
                AsyncImage(url: logoUrl) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure(_):
                        // Fallback to account initial
                        Text(account.name.prefix(1).uppercased())
                            .font(.system(size: 16, weight: .medium)) // Fixed font size
                            .foregroundColor(.white)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                // Fallback to account initial
                Text(account.name.prefix(1).uppercased())
                    .font(.system(size: 16, weight: .medium)) // Fixed font size
                    .foregroundColor(.white)
            }
        }
        .frame(width: baseSize, height: baseSize)
        .background(Color.gray)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
        )
        .scaleEffect(scale)
        .frame(width: size, height: size) // Maintain desired frame size
    }
}


struct AccountLogo_Previews: PreviewProvider {
    static let sampleAccounts = [
        Account(
            name: "Microsoft",
            logoUrl: URL(string: "https://logo.clearbit.com/microsoft.com")
        ),
        Account(
            name: "Twitter",
            logoUrl: URL(string: "https://logo.clearbit.com/twitter.com")
        ),
        Account(
            name: "Slack",
            logoUrl: URL(string: "https://logo.clearbit.com/slack.com")
        ),
        Account(
            name: "Unknown",
            logoUrl: nil
        )
    ]
    
    static var previews: some View {
        VStack(spacing: 32) {
            // Size variations
            VStack(spacing: 16) {
                Text("Size Variations").font(.headline)
                HStack(spacing: 16) {
                    ForEach([16, 24, 32, 40, 48], id: \.self) { size in
                        VStack {
                            AccountLogo(
                                account: sampleAccounts[0],
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
                Text("Logo States").font(.headline)
                HStack(spacing: 24) {
                    ForEach(sampleAccounts, id: \.name) { account in
                        VStack {
                            AccountLogo(
                                account: account,
                                size: 32 // Base size
                            )
                            Text(account.name)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: 80)
                                .lineLimit(1)
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
