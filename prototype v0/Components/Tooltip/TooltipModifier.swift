import SwiftUI

// MARK: - Hit Area Shape
private struct TooltipHitArea: Shape {
    let triggerFrame: CGRect
    let tooltipFrame: CGRect
    let padding: CGFloat
    let side: TooltipSide
    let sideOffset: CGFloat
    let position: CGPoint
    let contentSize: CGSize
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Calculate trigger center
        let triggerCenter = CGPoint(
            x: rect.width / 2,
            y: rect.height / 2
        )
        
        // Calculate tooltip point based on side
        var tooltipPoint: CGPoint
        switch side {
        case .top:
            tooltipPoint = CGPoint(
                x: rect.width / 2 + position.x + contentSize.width / 2,
                y: rect.height / 2 + position.y + contentSize.height
            )
        case .bottom:
            tooltipPoint = CGPoint(
                x: rect.width / 2 + position.x + contentSize.width / 2,
                y: rect.height / 2 + position.y
            )
        case .left:
            tooltipPoint = CGPoint(
                x: rect.width / 2 + position.x + contentSize.width,
                y: rect.height / 2 + position.y + contentSize.height / 2
            )
        case .right:
            tooltipPoint = CGPoint(
                x: rect.width / 2 + position.x,
                y: rect.height / 2 + position.y + contentSize.height / 2
            )
        }
        
        // Draw line
        path.move(to: triggerCenter)
        path.addLine(to: tooltipPoint)
        
        return path
    }
}

public struct TooltipModifier<TooltipContent: View>: ViewModifier {
    // MARK: - Properties
    let isPresented: Binding<Bool>?
    let config: TooltipConfig
    let content: TooltipContent
    let id: String
    
    // MARK: - State
    @State private var contentSize: CGSize = .zero
    @State private var isHovered = false
    @State private var isHitAreaHovered = false
    @State private var isTooltipHovered = false
    @State private var showDelayed = false
    @State private var actualSide: TooltipSide
    @State private var actualAlign: TooltipAlignment
    @State private var tooltipFrame: CGRect = .zero
    @State private var triggerFrame: CGRect = .zero
    @StateObject private var tooltipManager = TooltipManager.shared
    
    private var shouldShowTooltip: Bool {
        if let isPresented = isPresented {
            return isPresented.wrappedValue
        }
        return showDelayed && tooltipManager.isTooltipVisible(id: id)
    }
    
    private var isAnyHovered: Bool {
        isHovered || isHitAreaHovered || isTooltipHovered
    }
    
    // MARK: - Initialization
    public init(
        id: String = UUID().uuidString,
        isPresented: Binding<Bool>? = nil,
        config: TooltipConfig = TooltipConfig(),
        @ViewBuilder content: @escaping () -> TooltipContent
    ) {
        self.id = id
        self.isPresented = isPresented
        self.config = config
        self.content = content()
        self._actualSide = State(initialValue: config.layout.side)
        self._actualAlign = State(initialValue: config.layout.alignment)
    }
    
    // MARK: - Helper Methods
    private func calculatePosition(
        targetFrame: CGRect,
        screenSize: CGSize
    ) -> (position: CGPoint, side: TooltipSide, align: TooltipAlignment) {
        var side = config.layout.side
        var align = config.layout.alignment
        
        func positionForSide(_ side: TooltipSide, _ align: TooltipAlignment) -> CGPoint {
            var x: CGFloat
            var y: CGFloat
            
            // Calculate x position based on alignment
            switch align {
            case .start:
                x = 0
            case .center:
                x = (targetFrame.width - contentSize.width) / 2
            case .end:
                x = targetFrame.width - contentSize.width
            }
            
            // Add alignment offset
            x += config.layout.alignOffset
            
            // Calculate y position based on side
            switch side {
            case .top:
                y = -contentSize.height - config.layout.sideOffset
            case .bottom:
                y = targetFrame.height + config.layout.sideOffset
            case .left, .right:
                // Calculate center position
                let buttonCenterY = targetFrame.height / 2
                let tooltipCenterY = contentSize.height / 2
                y = buttonCenterY - tooltipCenterY
                
                if side == .left {
                    x = -contentSize.width - config.layout.sideOffset
                } else {
                    x = targetFrame.width + config.layout.sideOffset
                }
            }
            
            return CGPoint(x: x, y: y)
        }
        
        // Get initial position
        var position = positionForSide(side, align)
        
        if config.behavior.avoidCollisions {
            let padding = config.behavior.collisionPadding
            let globalPosition = CGPoint(
                x: targetFrame.minX + position.x,
                y: targetFrame.minY + position.y
            )
            
            func isOutOfBounds(_ pos: CGPoint) -> Bool {
                pos.x < padding ||
                pos.y < padding ||
                pos.x + contentSize.width > screenSize.width - padding ||
                pos.y + contentSize.height > screenSize.height - padding
            }
            
            if isOutOfBounds(globalPosition) {
                // Try different sides
                let sides: [TooltipSide] = [.top, .bottom, .right, .left]
                for newSide in sides where newSide != side {
                    let newPosition = positionForSide(newSide, align)
                    let newGlobalPosition = CGPoint(
                        x: targetFrame.minX + newPosition.x,
                        y: targetFrame.minY + newPosition.y
                    )
                    if !isOutOfBounds(newGlobalPosition) {
                        position = newPosition
                        side = newSide
                        break
                    }
                }
                
                // If still out of bounds, try different alignments
                let alignments: [TooltipAlignment] = [.center, .start, .end]
                for newAlign in alignments where newAlign != align {
                    let newPosition = positionForSide(side, newAlign)
                    let newGlobalPosition = CGPoint(
                        x: targetFrame.minX + newPosition.x,
                        y: targetFrame.minY + newPosition.y
                    )
                    if !isOutOfBounds(newGlobalPosition) {
                        position = newPosition
                        align = newAlign
                        break
                    }
                }
            }
        }
        
        return (position, side, align)
    }
    
    // MARK: - Tooltip Content
    @ViewBuilder
    private var tooltipContent: some View {
        content
            .font(.system(size: 13))
            .foregroundColor(config.appearance.textColor)
            .padding(config.appearance.padding)
            .fixedSize(horizontal: true, vertical: false)
            .background(
                config.appearance.backgroundColor
                    .clipShape(RoundedRectangle(cornerRadius: config.appearance.cornerRadius))
            )
            .background {
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: SizePreferenceKey.self,
                        value: geometry.size
                    )
                }
            }
    }
    
    // MARK: - Hit Area
    private struct HitAreaView: View {
        let triggerFrame: CGRect
        let tooltipFrame: CGRect
        let padding: CGFloat
        let side: TooltipSide
        let sideOffset: CGFloat
        let position: CGPoint
        let contentSize: CGSize
        let onHover: (Bool) -> Void
        
        var body: some View {
            // Just draw a circle at trigger center
            Circle()
                .fill(Color.white)
                .frame(width: 6, height: 6)
                .allowsHitTesting(false)
        }
    }
    
    // MARK: - Body
    public func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    Color.clear.onAppear {
                        triggerFrame = geometry.frame(in: .global)
                    }
                    
                    if shouldShowTooltip {
                        let targetFrame = geometry.frame(in: .local)
                        let screenSize = NSScreen.main?.visibleFrame.size ?? .zero
                        let position = calculatePosition(
                            targetFrame: targetFrame,
                            screenSize: screenSize
                        ).position
                        
                        ZStack {
                            // Hit area shape
                            Path { path in
                                switch actualSide {
                                case .top, .bottom:
                                    // Trigger points
                                    let p1 = CGPoint(x: targetFrame.minX, y: targetFrame.midY)
                                    let p2 = CGPoint(x: targetFrame.maxX, y: targetFrame.midY)
                                    // Tooltip points
                                    let p3 = CGPoint(x: targetFrame.minX + position.x + contentSize.width, y: targetFrame.midY + position.y)
                                    let p4 = CGPoint(x: targetFrame.minX + position.x, y: targetFrame.midY + position.y)
                                    
                                    path.move(to: p1)
                                    path.addLine(to: p4)
                                    path.addLine(to: p3)
                                    path.addLine(to: p2)
                                    path.closeSubpath()
                                    
                                case .left, .right:
                                    // Trigger points
                                    let p1 = CGPoint(x: targetFrame.midX, y: targetFrame.minY)
                                    let p2 = CGPoint(x: targetFrame.midX, y: targetFrame.maxY)
                                    // Tooltip points - calculate based on center
                                    let tooltipCenterY = targetFrame.minY + position.y + contentSize.height / 2
                                    let p3 = CGPoint(x: targetFrame.midX + position.x, y: tooltipCenterY + contentSize.height/2)
                                    let p4 = CGPoint(x: targetFrame.midX + position.x, y: tooltipCenterY - contentSize.height/2)
                                    
                                    path.move(to: p1)
                                    path.addLine(to: p4)
                                    path.addLine(to: p3)
                                    path.addLine(to: p2)
                                    path.closeSubpath()
                                }
                            }
                            .fill(Color.clear)
                            .contentShape(Path { path in
                                switch actualSide {
                                case .top, .bottom:
                                    let p1 = CGPoint(x: targetFrame.minX, y: targetFrame.midY)
                                    let p2 = CGPoint(x: targetFrame.maxX, y: targetFrame.midY)
                                    let p3 = CGPoint(x: targetFrame.minX + position.x + contentSize.width, y: targetFrame.midY + position.y)
                                    let p4 = CGPoint(x: targetFrame.minX + position.x, y: targetFrame.midY + position.y)
                                    
                                    path.move(to: p1)
                                    path.addLine(to: p4)
                                    path.addLine(to: p3)
                                    path.addLine(to: p2)
                                    path.closeSubpath()
                                    
                                case .left, .right:
                                    let p1 = CGPoint(x: targetFrame.midX, y: targetFrame.minY)
                                    let p2 = CGPoint(x: targetFrame.midX, y: targetFrame.maxY)
                                    let p3 = CGPoint(x: targetFrame.midX + position.x, y: targetFrame.midY + position.y + contentSize.height/2)
                                    let p4 = CGPoint(x: targetFrame.midX + position.x, y: targetFrame.midY + position.y - contentSize.height/2)
                                    
                                    path.move(to: p1)
                                    path.addLine(to: p4)
                                    path.addLine(to: p3)
                                    path.addLine(to: p2)
                                    path.closeSubpath()
                                }
                            })
                            .allowsHitTesting(true)
                            .onHover { hovering in
                                isHitAreaHovered = hovering
                                if hovering {
                                    tooltipManager.showTooltip(id: id)
                                } else if !isAnyHovered {
                                    withAnimation(.easeInOut(duration: config.animation.duration)) {
                                        showDelayed = false
                                        tooltipManager.hideTooltip(id: id)
                                    }
                                }
                            }
                            
                            // Tooltip content
                            tooltipContent
                                .background(Color.clear)
                                .contentShape(Rectangle())
                                .allowsHitTesting(true)
                                .onHover { hovering in
                                    isTooltipHovered = hovering
                                    if hovering {
                                        tooltipManager.showTooltip(id: id)
                                    } else if !isAnyHovered {
                                        withAnimation(.easeInOut(duration: config.animation.duration)) {
                                            showDelayed = false
                                            tooltipManager.hideTooltip(id: id)
                                        }
                                    }
                                }
                                .onPreferenceChange(SizePreferenceKey.self) { size in
                                    contentSize = size
                                    let (_, side, align) = calculatePosition(
                                        targetFrame: targetFrame,
                                        screenSize: screenSize
                                    )
                                    actualSide = side
                                    actualAlign = align
                                }
                                .offset(
                                    x: position.x,
                                    y: position.y
                                )
                                .animation(
                                    .easeInOut(duration: config.animation.duration),
                                    value: shouldShowTooltip
                                )
                                .transition(config.animation.transition)
                        }
                    }
                }
            )
            .onHover { hovering in
                guard isPresented == nil else { return }
                isHovered = hovering
                if hovering {
                    DispatchQueue.main.asyncAfter(deadline: .now() + config.behavior.delayDuration) {
                        withAnimation(.easeInOut(duration: config.animation.duration)) {
                            showDelayed = hovering
                            if hovering {
                                tooltipManager.showTooltip(id: id)
                            }
                        }
                    }
                } else if !isAnyHovered {
                    withAnimation(.easeInOut(duration: config.animation.duration)) {
                        showDelayed = false
                        tooltipManager.hideTooltip(id: id)
                    }
                }
            }
            .onDisappear {
                tooltipManager.hideTooltip(id: id)
            }
    }
}

// MARK: - View Extension
public extension View {
    func tooltip<Content: View>(
        id: String = UUID().uuidString,
        isPresented: Binding<Bool>? = nil,
        config: TooltipConfig = TooltipConfig(),
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(
            TooltipModifier(
                id: id,
                isPresented: isPresented,
                config: config,
                content: content
            )
        )
    }
} 