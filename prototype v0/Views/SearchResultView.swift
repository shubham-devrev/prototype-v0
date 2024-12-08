//
//  SearchResultView.swift
//  prototype v0
//
//  Created by Shubham Gandhi on 04/12/24.
//

import SwiftUI

struct SearchResultsView: View {
    let results: [ResultItem]
    @Binding var selectedIndex: Int
    @FocusState var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            // Take only first 5 results
            ForEach(Array(results.prefix(5).enumerated()).reversed(), id: \.element.id) { index, item in
                ResultItemView(item: item, isSelected: index == selectedIndex)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedIndex = index
                        item.action()
                    }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedIndex = 0
        
        var body: some View {
            SearchResultsView(
                results: [
                    ResultItem(
                        icon: "doc",
                        title: "Open Document",
                        shortcut: "⏎",
                        action: { print("Opening document") }
                    ),
                    ResultItem(
                        icon: "magnifyingglass",
                        title: "Search on Web",
                        shortcut: "⌘+⏎",
                        action: { print("Searching web") }
                    ),
                    ResultItem(
                        icon: "folder",
                        title: "Browse Files",
                        shortcut: "⌘+B",
                        action: { print("Browsing files") }
                    ),
                    ResultItem(
                        icon: "gear",
                        title: "Settings",
                        shortcut: "⌘+,",
                        action: { print("Opening settings") }
                    ),
                    ResultItem(
                        icon: "star",
                        title: "Favorites",
                        shortcut: "⌘+F",
                        action: { print("Opening favorites") }
                    ),
                    ResultItem(
                        icon: "person",
                        title: "Profile",
                        shortcut: "⌘+P",
                        action: { print("Opening profile") }
                    ),
                    ResultItem(
                        icon: "bell",
                        title: "Notifications",
                        shortcut: "⌘+N",
                        action: { print("Opening notifications") }
                    )
                ],
                selectedIndex: $selectedIndex
            )
        }
    }
    
    return PreviewWrapper()
        .frame(width: 360)
        .padding()
        .background(Color.black.opacity(0.8))
}
