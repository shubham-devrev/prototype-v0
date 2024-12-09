import SwiftUI

public struct KeyboardShortcutGroup: View {
    private let shortcuts: [String]
    private let backgroundColor: Color
    private let foregroundColor: Color
    
    public init(
        _ shortcuts: [String],
        backgroundColor: Color = Color.black.opacity(0.1),
        foregroundColor: Color = Color.black.opacity(0.8)
    ) {
        self.shortcuts = shortcuts
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }
    
    public init(
        _ shortcuts: String...,
        backgroundColor: Color = Color.black.opacity(0.1),
        foregroundColor: Color = Color.black.opacity(0.8)
    ) {
        self.shortcuts = shortcuts
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }
    
    public var body: some View {
        HStack(spacing: 4) {
            ForEach(shortcuts, id: \.self) { shortcut in
                KeyboardShortcut(
                    shortcut,
                    backgroundColor: backgroundColor,
                    foregroundColor: foregroundColor
                )
            }
        }
    }
}

// MARK: - Preview Provider
struct KeyboardShortcutGroup_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.windowBackgroundColor)
            
            VStack(spacing: 16) {
                // Dark theme
                KeyboardShortcutGroup(
                    "⌘", "Shift", "1",
                    backgroundColor: .white.opacity(0.1),
                    foregroundColor: .white.opacity(0.8)
                )
                
                // Light theme (default)
                KeyboardShortcutGroup(["⌘", "A"])
            }
        }
        .frame(width: 200, height: 200)
    }
} 