import SwiftUI

struct SidebarView: View {
    @State private var activeButton: String = "ai"
    
    var body: some View {
        VStack(spacing: 8) {
            // Top action buttons
            VStack(spacing: 4) {
                SidebarActionButton(
                    id: "home",
                    isActive: activeButton == "home",
                    tooltipText: "Home",
                    shortcuts: ["⌘", "1"],
                    action: { activeButton = "home" }
                ) {
                    Image(systemName: "house")
                }
                
                SidebarActionButton(
                    id: "inbox",
                    isActive: activeButton == "inbox",
                    tooltipText: "Inbox",
                    shortcuts: ["⌘", "2"],
                    action: { activeButton = "inbox" }
                ) {
                    Image(systemName: "tray")
                }
                
                SidebarActionButton(
                    id: "explore",
                    isActive: activeButton == "explore",
                    tooltipText: "Explore",
                    shortcuts: ["⌘", "3"],
                    action: { activeButton = "explore" }
                ) {
                    Image(systemName: "safari")
                }
            }
            
            Spacer()
            
            // Bottom action buttons
            VStack(spacing: 4) {
                SidebarActionButton(
                    id: "chat",
                    isActive: activeButton == "chat",
                    tooltipText: "Chat",
                    shortcuts: ["⌘", "C"],
                    action: { activeButton = "chat" }
                ) {
                    Image(systemName: "bubble.left")
                }
                
                // First User Avatar (with status)
                SidebarActionButton(
                    id: "account1",
                    isActive: activeButton == "account1",
                    tooltipText: User.mockUsers[0].name,
                    variant: .circular,
                    action: { activeButton = "account1" }
                ) {
                    Avatar(user: User.mockUsers[0], size: 24, showStatus: true)
                }
                
                // Second User Avatar (no status)
                SidebarActionButton(
                    id: "account2",
                    isActive: activeButton == "account2",
                    tooltipText: User.mockUsers[1].name,
                    variant: .circular,
                    action: { activeButton = "account2" }
                ) {
                    Avatar(user: User.mockUsers[1], size: 24, showStatus: false)
                }
                
                // Third User Avatar (no status)
                SidebarActionButton(
                    id: "account3",
                    isActive: activeButton == "account3",
                    tooltipText: User.mockUsers[2].name,
                    variant: .circular,
                    action: { activeButton = "account3" }
                ) {
                    Avatar(user: User.mockUsers[2], size: 24, showStatus: false)
                }
                
                // AI Assistant Avatar
                SidebarActionButton(
                    id: "ai",
                    isActive: activeButton == "ai",
                    tooltipText: "AI Assistant",
                    variant: .circular,
                    action: { activeButton = "ai" }
                ) {
                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(width: 24, height: 24)
                        Image(systemName: "sparkle")
                            .font(.system(size: 12))
                            .foregroundColor(.black)
                    }
                }
            }
        }
        .frame(width: 48)
        .padding(.vertical, 12)
        .padding(.leading, -3)
        .background(.clear)
        .zIndex(100)
    }
}

// Preview with app-like layout
struct AppPreview: View {
    var body: some View {
        HStack(spacing: 0) {
            SidebarView()
            
            // Empty content area
            VStack {
                Spacer()
                Text("Select an item from the sidebar")
                    .foregroundColor(.secondary)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.ultraThinMaterial)
            .zIndex(1)
        }
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        AppPreview()
            .frame(width: 800, height: 600)
            .preferredColorScheme(.dark)
    }
} 
