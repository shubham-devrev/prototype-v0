import SwiftUI

struct SidebarView: View {
    @Binding var activeButton: String
    @Binding var selectedChatId: String?
    @State private var avatarOrder = ["1", "2", "3", "ai"]
    @State private var animatingId: String? = nil
    @State private var circleProgress: CGFloat = 0
    
    private let defaultAvatarOrder = ["1", "2", "3", "ai"]
    private let strokeWidth: CGFloat = 2
    private var circleSize: CGFloat { 22 + (strokeWidth * 2) }
    private let circleOffset: CGPoint = CGPoint(x: 4, y: 0)
    
    var body: some View {
        VStack(spacing: 8) {
            // Top action buttons
            VStack(spacing: 4) {
                SidebarActionButton(
                    id: "home",
                    isActive: activeButton == "home",
                    helpText: "Today",
                    shortcuts: ["⌘", "1"],
                    action: { 
                        activeButton = "home"
                        resetAvatarOrder()
                    }
                ) {
                    Image(systemName: "calendar")
                }
                
                SidebarActionButton(
                    id: "inbox",
                    isActive: activeButton == "inbox",
                    helpText: "Inbox",
                    shortcuts: ["⌘", "2"],
                    action: { 
                        activeButton = "inbox"
                        resetAvatarOrder()
                    }
                ) {
                    Image(systemName: "tray")
                }
                
                SidebarActionButton(
                    id: "explore",
                    isActive: activeButton == "explore",
                    helpText: "Explore",
                    shortcuts: ["⌘", "3"],
                    action: { 
                        activeButton = "explore"
                        resetAvatarOrder()
                    }
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
                    helpText: "All Chats",
                    shortcuts: ["⌘", "C"],
                    action: { 
                        activeButton = "chat"
                        selectedChatId = "all-chats"
                    }
                ) {
                    Image(systemName: "bubble.left")
                }
                
                ForEach(avatarOrder, id: \.self) { avatarId in
                    Group {
                        if avatarId == "ai" {
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
                        } else if let user = User.mockUsers.first(where: { $0.id == avatarId }) {
                            // User Avatar
                            SidebarActionButton(
                                id: avatarId,
                                isActive: activeButton == avatarId,
                                helpText: user.name,
                                variant: .circular,
                                action: {
                                    animateSelection(avatarId)
                                }
                            ) {
                                Avatar(user: user, size: 24, showStatus: user.status == .online)
                            }
                            .background {
                                if animatingId == avatarId {
                                    Circle()
                                        .trim(from: 0, to: circleProgress)
                                        .stroke(Color.white, lineWidth: strokeWidth)
                                        .frame(width: circleSize, height: circleSize)
                                        .rotationEffect(.degrees(-90))
                                        .offset(x: circleOffset.x, y: circleOffset.y)
                                }
                            }
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
    
    private func resetAvatarOrder() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            avatarOrder = defaultAvatarOrder
        }
    }
    
    private func animateSelection(_ id: String) {
        circleProgress = 0
        
        withAnimation(.easeInOut(duration: 0.2)) {
            animatingId = id
        }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            circleProgress = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                activeButton = id
                selectedChatId = id
                moveActiveToEnd()
            }
        }
        
        // Reset animation after it's complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            animatingId = nil
            circleProgress = 0
        }
    }
    
    private func moveActiveToEnd() {
        if let index = avatarOrder.firstIndex(of: activeButton) {
            avatarOrder.remove(at: index)
            avatarOrder.append(activeButton)
        }
    }
}

#Preview {
    HStack(spacing: 0) {
        SidebarView(activeButton: .constant("home"), selectedChatId: .constant(nil))
        
        VStack {
            Spacer()
            Text("Select an item from the sidebar")
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }
    .frame(width: 800, height: 600)
    .preferredColorScheme(.dark)
} 
