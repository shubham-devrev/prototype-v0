import SwiftUI

public enum ButtonVariant {
    case `default`
    case circular
}

public struct SidebarActionButton<Content: View>: View {
    // MARK: - Properties
    private let isActive: Bool
    private let tooltipText: String
    private let content: Content
    private let action: () -> Void
    private let id: String
    private let shortcuts: [String]
    private let variant: ButtonVariant
    
    @State private var isHovered = false
    @State private var isTooltipVisible = false
    
    // MARK: - Initialization
    public init(
        id: String = UUID().uuidString,
        isActive: Bool = false,
        tooltipText: String,
        shortcuts: [String] = [],
        variant: ButtonVariant = .default,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.id = id
        self.isActive = isActive
        self.tooltipText = tooltipText
        self.shortcuts = shortcuts
        self.variant = variant
        self.action = action
        self.content = content()
    }
    
    // MARK: - Body
    public var body: some View {
        HStack(spacing: 6) {
            // Active indicator
            RoundedRectangle(cornerRadius: 1)
                .fill(Color.white)
                .frame(width: 2, height: 32)
                .opacity(isActive ? 1 : 0)
            
            // Button
            Button(action: action) {
                content
                    .foregroundColor(isActive ? .white : .primary.opacity(0.8))
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .background {
                RoundedRectangle(cornerRadius: variant == .circular ? .infinity : 6)
                    .fill(Color.white.opacity(isHovered ? 0.1 : 0))
                    .padding(variant == .default ? 2 : 0)
            }
            .clipShape(RoundedRectangle(cornerRadius: variant == .circular ? .infinity : 6))
            .tooltip(
                id: id,
                isPresented: $isTooltipVisible,
                config: TooltipConfig(
                    appearance: .init(
                        backgroundColor: .white,
                        textColor: .black
                    ),
                    layout: .init(
                        side: .right,
                        sideOffset: 8,
                        alignment: .center
                    ),
                    behavior: .init(
                        avoidCollisions: false,
                        delayDuration: 0.1
                    )
                )
            ) {
                HStack(spacing: 8) {
                    Text(tooltipText)
                        .font(.system(size: 12))
                        .foregroundColor(.black)
                    
                    if !shortcuts.isEmpty {
                        KeyboardShortcutGroup(shortcuts)
                    }
                }
                .fixedSize(horizontal: true, vertical: false)
            }
            .onHover { hovering in
                isHovered = hovering
                isTooltipVisible = hovering
            }
        }
        .frame(height: 32)
    }
}

// MARK: - Convenience Initializer for Icon-based Button
public extension SidebarActionButton where Content == Image {
    init(
        id: String = UUID().uuidString,
        isActive: Bool = false,
        tooltipText: String,
        shortcuts: [String] = [],
        systemName: String,
        action: @escaping () -> Void
    ) {
        self.init(
            id: id,
            isActive: isActive,
            tooltipText: tooltipText,
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
                    tooltipText: "Add new item",
                    systemName: "plus"
                ) {
                    print("Add tapped")
                }
                
                // Active state with single shortcut
                SidebarActionButton(
                    id: "settings",
                    isActive: true,
                    tooltipText: "Settings",
                    shortcuts: ["⌘"],
                    systemName: "gear"
                ) {
                    print("Settings tapped")
                }
                
                // With keyboard shortcut group
                SidebarActionButton(
                    id: "search",
                    tooltipText: "Search",
                    shortcuts: ["⌘", "F"],
                    systemName: "magnifyingglass"
                ) {
                    print("Search tapped")
                }
                
                // With complex keyboard shortcut
                SidebarActionButton(
                    id: "format",
                    tooltipText: "Format Code",
                    shortcuts: ["⌘", "Shift", "F"],
                    systemName: "chevron.left.forwardslash.chevron.right"
                ) {
                    print("Format tapped")
                }
                
                // With option key
                SidebarActionButton(
                    id: "preview",
                    tooltipText: "Quick Preview",
                    shortcuts: ["⌥", "Space"],
                    systemName: "eye"
                ) {
                    print("Preview tapped")
                }
                
                // With multiple shortcuts
                SidebarActionButton(
                    id: "run",
                    tooltipText: "Run Project",
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
