//
//  SearchView.swift
//  prototype v0
//
//  Created by Shubham Gandhi on 04/12/24.
//

import SwiftUI


struct SearchView: View {
    @Binding var searchText: String
    @FocusState private var isFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedIndex = 0
    @State private var searchResults: [ResultItem] = []
    
    private let searchManager = SmartSearchManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
//             Search Results
            if !searchResults.isEmpty {
                SearchResultsView(
                    results: searchResults,
                    selectedIndex: $selectedIndex,
                    isFocused: _isFocused
                )
                Divider()
                    .background(Color.white.opacity(0.1))
            }
            
            // Search bar
            HStack(spacing: 8) {
                TextField("Search across Maple's Knowledge...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 14, weight: .medium))
                    .focused($isFocused)
                    .tint(colorScheme == .dark ? .white : .black)
                    // Handle keyboard navigation
                    .onKeyPress(.upArrow) { 
                        moveSelection(up: true)
                        return .handled
                    }
                    .onKeyPress(.downArrow) { 
                        moveSelection(up: false)
                        return .handled
                    }
                    .onKeyPress(.return) { 
                        if !searchResults.isEmpty {
                            searchResults[selectedIndex].action()
                        }
                        return .handled
                    }
            }
            .padding(.top, 16)
            .padding(.trailing, 16)
            .padding(.leading, 16)
            .padding(.bottom, 0)
            
            // Action Buttons
            HStack(spacing: 4) {
                ActionButton(
                    icon: .upload,
                    tooltip: "Upload File"
                ) {
                    uploadFile()
                }
                ActionButton(
                    icon: .browse,
                    tooltip: "Browse Folders"
                ) {
                    browse()
                }
                ActionButton(
                    icon: .filter,
                    tooltip: "Filter"
                ) {
                    showFilters()
                }
                
                Spacer()
                
                ActionButton(
                    icon: .send,
                    tooltip: "Ask",
                    iconColor: .black
                ) {
                    sendQuery()
                }
                .background(Color.white)
                .cornerRadius(.infinity)
                .opacity(isFocused && !searchText.isEmpty ? 1 : 0.4)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            
           
        }
        .onAppear {
            isFocused = true
        }
        .frame(width: 360)
        .background(Color(hue: 0, saturation: 0, brightness: 0.08, opacity: 1))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .onChange(of: searchText) { _, newValue in
           searchResults = searchManager.search(query: newValue) { action in
               handleSearchAction(action)
           }
           selectedIndex = 0
       }
//        .overlay(alignment: .top) {
//            // Results popover
//            if !searchResults.isEmpty {
//                SearchResultsView(
//                    results: searchResults,
//                    selectedIndex: $selectedIndex,
//                    isFocused: _isFocused
//                )
//                .frame(width: 360)
//                .background(Color(hue: 0, saturation: 0, brightness: 0.08, opacity: 1))
//                .cornerRadius(10)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 10)
//                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
//                )
//                .offset(y: -10) // Gap between search box and results
//                .transition(.opacity.combined(with: .move(edge: .bottom)))
//            }
//        }
//        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: searchResults.count)
    }
    
    private func moveSelection(up: Bool) {
        if searchResults.isEmpty { return }
        
        // Invert the up/down logic since the list is reversed
        if up {
            // Moving up in reversed list means decreasing the index
            selectedIndex = selectedIndex >= searchResults.count - 1 ? 0 : selectedIndex + 1
        } else {
            // Moving down in reversed list means increasing the index
            selectedIndex = selectedIndex <= 0 ? searchResults.count - 1 : selectedIndex - 1
        }
    }
    
    private func handleSearchAction(_ action: String) {
        // Handle different actions based on the prefix
        if action.hasPrefix("ai_query:") {
            print("Sending AI query:", action)
        } else if action.hasPrefix("open_article:") {
            print("Opening article:", action)
        } else if action.hasPrefix("create_article:") {
            print("Creating article:", action)
        } else if action.hasPrefix("create_ticket:") {
            print("Creating ticket:", action)
        } else {
            print("Action",action)
        }
    }
    
    // Action functions
    func uploadFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        if panel.runModal() == .OK {
            print("Selected file: \(panel.url?.path ?? "")")
        }
    }
    
    func showFilters() {
        print("Show filters")
    }
    
    func browse() {
        print("Browse")
    }
    
    func sendQuery() {
        if !searchText.isEmpty {
            print("Sending query: \(searchText)")
        }
    }
    
    private func performSearch(query: String) {
            if query.isEmpty {
                searchResults = []
                return
            }
            
            let lowercaseQuery = query.lowercased()
            
            // AI and Knowledge Base results
            searchResults = [
                ResultItem(
                    icon: "sparkle",
                    title: "Ask AI about '\(query)'",
                    shortcut: "⏎",
                    action: { sendQuery() }
                ),
                ResultItem(
                    icon: "doc.text",
                    title: "Search knowledge base",
                    shortcut: "⌘+K",
                    action: { searchKnowledgeBase(query) }
                )
            ]
            
            // Simulated knowledge base matches
            let knowledgeResults = [
                ("How to set up SSO", "Authentication & Security", "lock"),
                ("Deployment best practices", "DevOps", "server.rack"),
                ("Employee onboarding process", "HR", "person.badge.plus"),
                ("Sales pipeline management", "Sales", "chart.xyaxis.line"),
                ("Product roadmap 2024", "Product", "map")
            ]
            
            // Add matching knowledge base articles
            for (title, category, icon) in knowledgeResults {
                if title.lowercased().contains(lowercaseQuery) ||
                   category.lowercased().contains(lowercaseQuery) {
                    searchResults.append(
                        ResultItem(
                            icon: icon,
                            title: title,
                            shortcut: "⏎",
                            action: { openArticle(title) }
                        )
                    )
                }
            }
            
            // Simulated ticket/issue results
            let tickets = [
                ("#1234", "Login issues with SSO", "High", "exclamationmark.triangle"),
                ("#1235", "Update documentation", "Medium", "doc.badge.clock"),
                ("#1236", "API rate limiting", "Low", "network")
            ]
            
            // Add matching tickets
            for (id, title, priority, icon) in tickets {
                if title.lowercased().contains(lowercaseQuery) {
                    searchResults.append(
                        ResultItem(
                            icon: icon,
                            title: "\(id): \(title) (\(priority))",
                            shortcut: nil,
                            action: { openTicket(id) }
                        )
                    )
                }
            }
            
            // Add contextual actions
            if query.count > 2 {
                searchResults.append(
                    ResultItem(
                        icon: "plus.circle",
                        title: "Create new article about '\(query)'",
                        shortcut: "⌘+N",
                        action: { createNewArticle(query) }
                    )
                )
                
                searchResults.append(
                    ResultItem(
                        icon: "ticket",
                        title: "Create ticket for '\(query)'",
                        shortcut: "⌘+T",
                        action: { createNewTicket(query) }
                    )
                )
            }
        }
        
        // Action handlers
        private func searchKnowledgeBase(_ query: String) {
            print("Searching knowledge base for: \(query)")
        }
        
        private func openArticle(_ title: String) {
            print("Opening article: \(title)")
        }
        
        private func openTicket(_ id: String) {
            print("Opening ticket: \(id)")
        }
        
        private func createNewArticle(_ title: String) {
            print("Creating new article: \(title)")
        }
        
        private func createNewTicket(_ title: String) {
            print("Creating new ticket: \(title)")
        }
}

// Preview
#Preview {
    SearchView(searchText: .constant(""))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.windowBackgroundColor))
}
