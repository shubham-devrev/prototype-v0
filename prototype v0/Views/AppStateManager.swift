import SwiftUI

// MARK: - Navigation Types

enum AppSection: String {
    case home = "Home"
    case inbox = "Inbox"
    case today = "Today"
    case explore = "Explore"
    case ai = "AI Assistant"
    case messages = "Messages"
    
    var icon: String {
        switch self {
        case .home: return "house"
        case .inbox: return "tray"
        case .today: return "calendar"
        case .explore: return "safari"
        case .ai: return "sparkle"
        case .messages: return "bubble.left"
        }
    }
    
    var showsNavigation: Bool {
        switch self {
        case .home: return false
        case .inbox, .today, .explore: return true
        case .ai, .messages: return true
        }
    }
    
    var showsRightPanel: Bool {
        switch self {
        case .explore: return true
        default: return true
        }
    }
}

// MARK: - Content Types

enum ContentType: Equatable {
    case home
    case explore
    case inbox(String)
    case today(String)
    case ai(String)
    case messages(String)
    case empty
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .explore: return "Explore"
        case .inbox(let id): return "Inbox Item \(id)"
        case .today(let id): return "Today Item \(id)"
        case .ai(let id): return "AI Chat \(id)"
        case .messages(let id): return "Message Thread \(id)"
        case .empty: return ""
        }
    }
}

// MARK: - State Manager

class AppStateManager: ObservableObject {
    // Main app state
    @Published var activeSection: AppSection = .home
    @Published var activeContent: ContentType = .home
    
    // View states
    @Published var columnVisibility: NavigationSplitViewVisibility = .all
    @Published var showRightPanel: Bool
    
    
    // Tab management
    @Published var activeTab: String = "Tab 1"
    @Published var rightPanelTabs: [String] = ["Tab 1", "Tab 2", "Tab 3"]
    
    init() {
        self.showRightPanel = false
        updateViewState()
    }
    
    // MARK: - Navigation Actions
    
    func navigateToSection(_ section: AppSection) {
        withAnimation(.easeInOut(duration: 0.2)) {
            // Only update content for home section or when content is empty
            if section == .home || activeContent == .empty {
                activeContent = .home
            }
            activeSection = section
            updateViewState()
        }
    }
    
    func selectContent(_ content: ContentType) {
        withAnimation(.easeInOut(duration: 0.2)) {
            activeContent = content
        }
    }
    
    // MARK: - Panel Actions
    
    func toggleRightPanel() {
        withAnimation(.easeInOut(duration: 0.2)) {
            showRightPanel.toggle()
        }
    }
    
    func openRightPanel() {
        withAnimation(.easeInOut(duration: 0.2)) {
            showRightPanel = true
        }
    }
    
    func closeRightPanel() {
        withAnimation(.easeInOut(duration: 0.2)) {
            showRightPanel = false
        }
    }
    
    // MARK: - Private Helpers
    
    private func updateViewState() {
        // Update navigation visibility
        columnVisibility = activeSection.showsNavigation ? .all : .detailOnly
        
        // Update right panel visibility based on section
        if !activeSection.showsRightPanel {
            showRightPanel = false
        }
    }
    
    func addTab() {
            rightPanelTabs.append("Tab \(rightPanelTabs.count + 1)")
            activeTab = rightPanelTabs.last ?? "Tab 1"
        }
        
    func removeTab(_ tab: String) {
        if let index = rightPanelTabs.firstIndex(of: tab) {
            rightPanelTabs.remove(at: index)
            if tab == activeTab {
                activeTab = rightPanelTabs.last ?? ""
            }
        }
    }
}
