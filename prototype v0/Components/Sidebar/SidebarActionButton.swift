import SwiftUI

public enum ButtonVariant {
    case `default`
    case circular
}

public struct SidebarActionButton<Content: View>: View {
    // MARK: - Properties
    private let isActive: Bool
    private let helpText: String
    private let content: Content
    private let action: () -> Void
    private let id: String
    private let shortcuts: [String]
    private let variant: ButtonVariant
    
    @State private var isHovered = false
    
    // MARK: - Initialization
    public init(
        id: String = UUID().uuidString,
        isActive: Bool = false,
        helpText: String,
        shortcuts: [String] = [],
        variant: ButtonVariant = .default,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.id = id
        self.isActive = isActive
        self.helpText = helpText
        self.shortcuts = shortcuts
        self.variant = variant
        self.action = action
        self.content = content()
    }
    
    // MARK: - Body
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                // Active indicator
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.white)
                    .frame(width: 2, height: 32)
                    .opacity(isActive ? 1 : 0)
                    .scaleEffect(isActive ? 1 : 0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isActive)
                
                // Content
                content
                    .foregroundColor(isActive ? .white : .primary.opacity(0.8))
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 32, height: 32)
            }
            .frame(height: 32)
            .overlay {
                RoundedRectangle(cornerRadius: variant == .circular ? .infinity : 6)
                    .fill(Color.white.opacity(isHovered ? 0.1 : 0))
                    .frame(width: 32, height: 32)
                    .offset(x: 4) // Offset to align with the content
            }
        }
        .buttonStyle(.plain)
        .help(helpText + (shortcuts.isEmpty ? "" : " (" + shortcuts.joined(separator: " ") + ")"))
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Convenience Initializer for Icon-based Button
public extension SidebarActionButton where Content == Image {
    init(
        id: String = UUID().uuidString,
        isActive: Bool = false,
        helpText: String,
        shortcuts: [String] = [],
        systemName: String,
        action: @escaping () -> Void
    ) {
        self.init(
            id: id,
            isActive: isActive,
            helpText: helpText,
            shortcuts: shortcuts,
            action: action
        ) {
            Image(systemName: systemName)
        }
    }
}

// MARK: - Preview Provider
struct SidebarActionButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.windowBackgroundColor)
            
            VStack(spacing: 20) {
                // Simple tooltip without shortcut
                SidebarActionButton(
                    id: "add",
                    helpText: "Add new item",
                    systemName: "plus"
                ) {
                    print("Add tapped")
                }
                
                // Active state with single shortcut
                SidebarActionButton(
                    id: "settings",
                    isActive: true,
                    helpText: "Settings",
                    shortcuts: ["⌘"],
                    systemName: "gear"
                ) {
                    print("Settings tapped")
                }
                
                // With keyboard shortcut group
                SidebarActionButton(
                    id: "search",
                    helpText: "Search",
                    shortcuts: ["⌘", "F"],
                    systemName: "magnifyingglass"
                ) {
                    print("Search tapped")
                }
                
                // With complex keyboard shortcut
                SidebarActionButton(
                    id: "format",
                    helpText: "Format Code",
                    shortcuts: ["⌘", "Shift", "F"],
                    systemName: "chevron.left.forwardslash.chevron.right"
                ) {
                    print("Format tapped")
                }
                
                // With option key
                SidebarActionButton(
                    id: "preview",
                    helpText: "Quick Preview",
                    shortcuts: ["⌥", "Space"],
                    systemName: "eye"
                ) {
                    print("Preview tapped")
                }
                
                // With multiple shortcuts
                SidebarActionButton(
                    id: "run",
                    helpText: "Run Project",
                    shortcuts: ["⌘", "R"],
                    systemName: "play.fill"
                ) {
                    print("Run tapped")
                }
            }
            .padding()
        }
        .frame(width: 600, height: 400)
    }
} 
