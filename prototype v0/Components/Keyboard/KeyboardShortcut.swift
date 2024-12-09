import SwiftUI

public struct KeyboardShortcut: View {
    private let text: String
    private let backgroundColor: Color
    private let foregroundColor: Color
    
    public init(
        _ text: String,
        backgroundColor: Color = Color.black.opacity(0.1),
        foregroundColor: Color = Color.black.opacity(0.8)
    ) {
        self.text = text
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }
    
    public var body: some View {
        Text(text)
            .font(.system(size: 12))
            .foregroundColor(foregroundColor)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

// MARK: - Preview Provider
struct KeyboardShortcut_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.windowBackgroundColor)
            
            VStack(spacing: 16) {
                // Dark theme
                KeyboardShortcut("⌘1")
                    .foregroundColor(.white.opacity(0.8))
                    .background(Color.white.opacity(0.1))
                
                // Light theme
                KeyboardShortcut("⌘1")
                    .background(Color.white)
                
                HStack(spacing: 4) {
                    KeyboardShortcut("⌘")
                    KeyboardShortcut("Shift")
                    KeyboardShortcut("A")
                }
            }
        }
        .frame(width: 200, height: 200)
    }
} 