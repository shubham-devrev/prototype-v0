//
//  ResultItem.swift
//  prototype v0
//
//  Created by Shubham Gandhi on 04/12/24.
//

import SwiftUI

struct ResultItem: Identifiable, Equatable {
    let id = UUID()
    let icon: String // SF Symbol name
    let title: String
    let shortcut: String? // Optional keyboard shortcut
    let action: () -> Void
    
    // Implement Equatable (comparing only id since action can't be compared)
    static func == (lhs: ResultItem, rhs: ResultItem) -> Bool {
        lhs.id == rhs.id
    }
}

struct ResultItemView: View {
    let item: ResultItem
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: item.icon)
                .font(.system(size: 16))
                .foregroundColor(isSelected ? .white : .secondary)
                .frame(width: 24)
            
            // Title
            Text(item.title)
                .font(.system(size: 14))
                .foregroundColor(isSelected ? .white : .primary)
            
            Spacer()
            
            // Keyboard Shortcut
            if isSelected, let shortcut = item.shortcut {
                Text(shortcut)
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isSelected ? Color.accentColor : Color.clear)
        .cornerRadius(6)
    }
}

#Preview {
    VStack(spacing: 8) {
        // Selected item
        ResultItemView(
            item: ResultItem(
                icon: "doc",
                title: "Open Document",
                shortcut: "⏎",
                action: {}
            ),
            isSelected: true
        )
        
        // Unselected item with shortcut
        ResultItemView(
            item: ResultItem(
                icon: "magnifyingglass",
                title: "Search on Web",
                shortcut: "⌘+⏎",
                action: {}
            ),
            isSelected: false
        )
        
        // Unselected item without shortcut
        ResultItemView(
            item: ResultItem(
                icon: "folder",
                title: "Browse Files",
                shortcut: nil,
                action: {}
            ),
            isSelected: false
        )
    }
    .frame(width: 360)
    .padding()
    .background(Color.black.opacity(0.8))
}
