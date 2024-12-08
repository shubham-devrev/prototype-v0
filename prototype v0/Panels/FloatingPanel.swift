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

class FloatingPanel<Content: View>: NSPanel {
    @Binding var isPresented: Bool
    
    init(view: () -> Content,
         contentRect: NSRect,
         backing: NSWindow.BackingStoreType = .buffered,
         defer flag: Bool = false,
         isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        
        super.init(contentRect: contentRect,
                  styleMask: [.nonactivatingPanel, .titled, .resizable, .closable, .fullSizeContentView],
                  backing: backing,
                  defer: flag)
        
        isOpaque = false
        backgroundColor = .clear
        
        isFloatingPanel = true
        level = .floating
        collectionBehavior.insert(.fullScreenAuxiliary)
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        isMovableByWindowBackground = true
        hidesOnDeactivate = true
        
        // Create hosting view with bottom-aligned content
        let hostingView = NSHostingView(rootView:
            VStack {
                Spacer() // Push content to bottom
                view()
            }
            .frame(maxHeight: .infinity) // Take full height
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
        
        
        standardWindowButton(.closeButton)?.isHidden = true
        standardWindowButton(.miniaturizeButton)?.isHidden = true
        standardWindowButton(.zoomButton)?.isHidden = true
        
        animationBehavior = .utilityWindow

        
    }
    
    override func resignMain() {
        super.resignMain()
        close()
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
