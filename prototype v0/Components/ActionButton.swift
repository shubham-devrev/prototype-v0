//
//  ActionButton.swift
//  prototype v0
//
//  Created by Shubham Gandhi on 04/12/24.
//

import SwiftUI

// Enum for type-safe icons
enum ActionButtonIcon: String {
    case upload = "paperclip"
    case filter = "line.3.horizontal.decrease"
    case browse = "globe"
    case voice = "mic"
    case delete = "trash"
    case edit = "pencil"
    case send = "arrow.up"
    case share = "square.and.arrow.up"
    case download = "arrow.down.circle"
    case settings = "gear"
    case search = "magnifyingglass"
    case close = "xmark.circle.fill"
    
    // Add more icons as needed
}

struct ActionButton: View {
    let icon: ActionButtonIcon
    let tooltip: String
    let action: () -> Void
    let iconColor: Color // Add color property
    
    // Add initializer with default color
    init(
        icon: ActionButtonIcon,
        tooltip: String,
        iconColor: Color = .secondary, // Default to primary color
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.tooltip = tooltip
        self.iconColor = iconColor
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon.rawValue)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(iconColor) // Use the color property
                .frame(width: 24, height: 24)
        }
        .buttonStyle(ActionButtonStyle())
        .help(tooltip)
    }
}

struct ActionButtonStyle: ButtonStyle {
    @State private var isHovered = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Group {
                    if configuration.isPressed {
                        Color.gray.opacity(0.4)
                    } else {
                        isHovered ? Color.gray.opacity(0.15) : Color.gray.opacity(0)
                    }
                }
            )
            .cornerRadius(6)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
            .onHover { hover in
                isHovered = hover
            }
    }
}

struct SendButtonStyle: ViewModifier {
    let isEnabled: Bool
    
    func body(content: Content) -> some View {
        content
            .background(Color.white)
            .cornerRadius(.infinity)
            .opacity(isEnabled ? 1 : 0.4)
            .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}

// Preview
struct ActionButton_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            ActionButton(
                icon: .upload,
                tooltip: "Upload File"
            ) {
                print("Upload tapped")
            }
            
            ActionButton(
                icon: .filter,
                tooltip: "Filter"
            ) {
                print("Filter tapped")
            }
        }
        .padding()
    }
}
