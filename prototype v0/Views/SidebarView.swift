import SwiftUI

struct SidebarView: View {
    @State private var activeButton: String = "ai"
    @State private var avatarOrder = ["account1", "account2", "account3", "ai"]
    @State private var animatingId: String? = nil
    @State private var circleProgress: CGFloat = 0
    
    private let strokeWidth: CGFloat = 2
    private var circleSize: CGFloat { 22 + (strokeWidth * 2) } // Avatar size + stroke width on both sides
    private let circleOffset: CGPoint = CGPoint(x: 4, y: 0) // Adjust these values to position the circle
    
    var body: some View {
        VStack(spacing: 8) {
            // Top action buttons
            VStack(spacing: 4) {
                SidebarActionButton(
                    id: "home",
                    isActive: activeButton == "home",
                    helpText: "Home",
                    shortcuts: ["⌘", "1"],
                    action: { activeButton = "home" }
                ) {
                    Image(systemName: "house")
                }
                
                SidebarActionButton(
                    id: "inbox",
                    isActive: activeButton == "inbox",
                    helpText: "Inbox",
                    shortcuts: ["⌘", "2"],
                    action: { activeButton = "inbox" }
                ) {
                    Image(systemName: "tray")
                }
                
                SidebarActionButton(
                    id: "explore",
                    isActive: activeButton == "explore",
                    helpText: "Explore",
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
                    helpText: "Chat",
                    shortcuts: ["⌘", "C"],
                    action: { activeButton = "chat" }
                ) {
                    Image(systemName: "bubble.left")
                }
                
                ForEach(avatarOrder, id: \.self) { avatarId in
                    Group {
                        switch avatarId {
                        case "account1":
                            // First User Avatar (with status)
                            SidebarActionButton(
                                id: "account1",
                                isActive: activeButton == "account1",
                                helpText: User.mockUsers[0].name,
                                variant: .circular,
                                action: {
                                    animateSelection("account1")
                                }
                            ) {
                                Avatar(user: User.mockUsers[0], size: 24, showStatus: true)
                            }
                            .background {
                                if animatingId == "account1" {
                                    Circle()
                                        .trim(from: 0, to: circleProgress)
                                        .stroke(Color.white, lineWidth: strokeWidth)
                                        .frame(width: circleSize, height: circleSize)
                                        .rotationEffect(.degrees(-90))
                                        .offset(x: circleOffset.x, y: circleOffset.y)
                                }
                            }
                        case "account2":
                            // Second User Avatar (no status)
                            SidebarActionButton(
                                id: "account2",
                                isActive: activeButton == "account2",
                                helpText: User.mockUsers[1].name,
                                variant: .circular,
                                action: {
                                    animateSelection("account2")
                                }
                            ) {
                                Avatar(user: User.mockUsers[1], size: 24, showStatus: false)
                            }
                            .background {
                                if animatingId == "account2" {
                                    Circle()
                                        .trim(from: 0, to: circleProgress)
                                        .stroke(Color.white, lineWidth: strokeWidth)
                                        .frame(width: circleSize, height: circleSize)
                                        .rotationEffect(.degrees(-90))
                                        .offset(x: circleOffset.x, y: circleOffset.y)
                                }
                            }
                        case "account3":
                            // Third User Avatar (no status)
                            SidebarActionButton(
                                id: "account3",
                                isActive: activeButton == "account3",
                                helpText: User.mockUsers[2].name,
                                variant: .circular,
                                action: {
                                    animateSelection("account3")
                                }
                            ) {
                                Avatar(user: User.mockUsers[2], size: 24, showStatus: false)
                            }
                            .background {
                                if animatingId == "account3" {
                                    Circle()
                                        .trim(from: 0, to: circleProgress)
                                        .stroke(Color.white, lineWidth: strokeWidth)
                                        .frame(width: circleSize, height: circleSize)
                                        .rotationEffect(.degrees(-90))
                                        .offset(x: circleOffset.x, y: circleOffset.y)
                                }
                            }
                        case "ai":
                            // AI Assistant Avatar
                            SidebarActionButton(
                                id: "ai",
                                isActive: activeButton == "ai",
                                helpText: "AI Assistant",
                                variant: .circular,
                                action: {
                                    animateSelection("ai")
                                }
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
                            .background {
                                if animatingId == "ai" {
                                    Circle()
                                        .trim(from: 0, to: circleProgress)
                                        .stroke(Color.white, lineWidth: strokeWidth)
                                        .frame(width: circleSize, height: circleSize)
                                        .rotationEffect(.degrees(-90))
                                        .offset(x: circleOffset.x, y: circleOffset.y)
                                }
                            }
                        default:
                            EmptyView()
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: animatingId)
                }
            }
        }
        .frame(width: 48)
        .padding(.vertical, 12)
        .padding(.leading, -3)
        .background(.clear)
        .zIndex(100)
        .padding(.top, -6)
    }
    
    private func animateSelection(_ id: String) {
        // Reset circle progress
        circleProgress = 0
        
        // Show circle and animate drawing
        withAnimation(.easeInOut(duration: 0.2)) {
            animatingId = id
        }
        
        // Animate circle drawing
        withAnimation(.easeInOut(duration: 0.3)) {
            circleProgress = 1
        }
        
        // After circle is drawn, move the avatar
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                activeButton = id
                moveActiveToEnd()
            }
        }
    }
    
    private func moveActiveToEnd() {
        if let index = avatarOrder.firstIndex(of: activeButton) {
            avatarOrder.remove(at: index)
            avatarOrder.append(activeButton)
        }
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
