//
//  ResultItem.swift
//  prototype v0
//
//  Created by Shubham Gandhi on 04/12/24.
//

import SwiftUI

struct ResultItemView: View {
    let item: ResultItem
    let isSelected: Bool
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 8) {
            // Icon
            Image(systemName: item.icon)
                .font(.system(size: 14))
                .foregroundColor(isSelected ? .black : .secondary)
                .frame(width: 24)
            
            // Title
            Text(item.title)
                .font(.system(size: 14))
                .foregroundColor(isSelected ? .black : .primary)
                .lineLimit(1) // Ensure single line
                .truncationMode(.tail) // Add ellipsis at the end
            
            Spacer()
            
            // Keyboard Shortcut
            if isSelected, let shortcut = item.shortcut {
                Text(shortcut)
                    .font(.system(size: 12))
                    .foregroundColor(.black.opacity(0.4))
            }
        }
        .onHover { hovering in
                    isHovered = hovering
                }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .cornerRadius(6)
        .background(
               RoundedRectangle(cornerRadius: 6)
               .fill(backgroundColor)
           )
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .white
        }
        return isHovered ? Color.gray.opacity(0.1) : .clear
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
