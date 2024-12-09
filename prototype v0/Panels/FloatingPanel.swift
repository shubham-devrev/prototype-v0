//
//  FloatingPanel.swift
//  prototype v0
//
//  Created by Shubham Gandhi on 04/12/24.
//

import SwiftUI

private struct FloatingPanelKey: EnvironmentKey {
    static let defaultValue: NSPanel? = nil
}

extension EnvironmentValues {
    var floatingPanel: NSPanel? {
        get { self[FloatingPanelKey.self] }
        set { self[FloatingPanelKey.self] = newValue }
    }
}

// First, add a protocol to identify our panel
protocol SearchPanelProtocol: AnyObject {
    func updateSearchState(hasText: Bool)
    func setPanelCloseBehavior(preventClose: Bool)
}

class FloatingPanel<Content: View>: NSPanel, SearchPanelProtocol {
    @Binding var isPresented: Bool
    var hasSearchText: Bool = false
    private var preventAutoClose: Bool = false

    init(view: () -> Content,
         contentRect: NSRect,
         backing: NSWindow.BackingStoreType = .buffered,
         defer flag: Bool = false,
         isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        
        super.init(contentRect: contentRect,
                  styleMask: [.borderless, .nonactivatingPanel],
                  backing: backing,
                  defer: flag)
        
        // Set up window appearance
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        
        // Set up window behavior
        isFloatingPanel = true
        level = .floating
        collectionBehavior.insert(.fullScreenAuxiliary)
        isMovableByWindowBackground = true
        hidesOnDeactivate = true
        
        // Create hosting view with bottom-aligned content
        let hostingView = NSHostingView(rootView:
            VStack {
                Spacer()
                view()
            }
            .frame(maxHeight: .infinity)
            .ignoresSafeArea()
            .environment(\.floatingPanel, self)
        )
        
        contentView = hostingView
        
        // Position at bottom left with fixed height
        if let screen = NSScreen.main {
            let x = screen.visibleFrame.minX + 36
            let y = screen.visibleFrame.minY + 24
            
            self.setFrame(NSRect(
                x: x,
                y: y,
                width: contentRect.width,
                height: contentRect.height
            ), display: true)
        }
        
        // Hide standard window buttons
        standardWindowButton(.closeButton)?.isHidden = true
        standardWindowButton(.miniaturizeButton)?.isHidden = true
        standardWindowButton(.zoomButton)?.isHidden = true
        
        // Set window behaviors
        animationBehavior = .utilityWindow
        collectionBehavior = [.fullScreenAuxiliary, .managed, .canJoinAllSpaces]
        isReleasedWhenClosed = false
    }
    
    override func resignMain() {
        // Only close if there's no search text and auto-close is not prevented
        if !hasSearchText && !preventAutoClose {
            super.resignMain()
            close()
        }
    }
    
    func updateSearchState(hasText: Bool) {
        self.hasSearchText = hasText
    }
    
    func setPanelCloseBehavior(preventClose: Bool) {
        self.preventAutoClose = preventClose
    }
    
    override func close() {
        super.close()
        isPresented = false
    }
    
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return true
    }
}
