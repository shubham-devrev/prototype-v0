import SwiftUI

public enum TooltipSide {
    case top
    case right
    case bottom
    case left
}

public struct TooltipConfig {
    public struct Appearance {
        let backgroundColor: Color
        let textColor: Color
        let cornerRadius: CGFloat
        let padding: EdgeInsets
        
        public init(
            backgroundColor: Color = .black,
            textColor: Color = .white,
            cornerRadius: CGFloat = 4,
            padding: EdgeInsets = EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8)
        ) {
            self.backgroundColor = backgroundColor
            self.textColor = textColor
            self.cornerRadius = cornerRadius
            self.padding = padding
        }
    }
    
    public struct Layout {
        let side: TooltipSide
        let sideOffset: CGFloat
        let alignment: TooltipAlignment
        let alignOffset: CGFloat
        let minWidth: CGFloat
        let maxWidth: CGFloat
        let keyboardShortcut: String?
        
        public init(
            side: TooltipSide = .top,
            sideOffset: CGFloat = 8,
            alignment: TooltipAlignment = .center,
            alignOffset: CGFloat = 0,
            minWidth: CGFloat = 60,
            maxWidth: CGFloat = 360,
            keyboardShortcut: String? = nil
        ) {
            self.side = side
            self.sideOffset = sideOffset
            self.alignment = alignment
            self.alignOffset = alignOffset
            self.minWidth = minWidth
            self.maxWidth = maxWidth
            self.keyboardShortcut = keyboardShortcut
        }
    }
    
    public struct Behavior {
        let avoidCollisions: Bool
        let collisionPadding: CGFloat
        let hideWhenDetached: Bool
        let delayDuration: TimeInterval
        let skipDelayDuration: TimeInterval
        
        public init(
            avoidCollisions: Bool = true,
            collisionPadding: CGFloat = 8,
            hideWhenDetached: Bool = true,
            delayDuration: TimeInterval = 0.7,
            skipDelayDuration: TimeInterval = 0.3
        ) {
            self.avoidCollisions = avoidCollisions
            self.collisionPadding = collisionPadding
            self.hideWhenDetached = hideWhenDetached
            self.delayDuration = delayDuration
            self.skipDelayDuration = skipDelayDuration
        }
    }
    
    public struct Animation {
        let duration: TimeInterval
        let transition: AnyTransition
        
        public init(
            duration: TimeInterval = 0.15,
            transition: AnyTransition = .opacity
        ) {
            self.duration = duration
            self.transition = transition
        }
    }
    
    let appearance: Appearance
    let layout: Layout
    let behavior: Behavior
    let animation: Animation
    
    public init(
        appearance: Appearance = Appearance(),
        layout: Layout = Layout(),
        behavior: Behavior = Behavior(),
        animation: Animation = Animation()
    ) {
        self.appearance = appearance
        self.layout = layout
        self.behavior = behavior
        self.animation = animation
    }
} 