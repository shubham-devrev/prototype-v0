//
//  WindowManager.swift
//  prototype v0
//

import SwiftUI
import AppKit

class EmptyWindowController: NSWindowController {
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1200, height: 700),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.toolbar = NSToolbar()
        window.toolbar?.showsBaselineSeparator = false
        window.center()
        window.contentView = NSHostingView(rootView: NewWindowView())
        self.init(window: window)
    }
}

class WindowManager: ObservableObject {
    static let shared = WindowManager()
    private var windowControllers: [EmptyWindowController] = []
    
    func openNewWindow() {
        let windowController = EmptyWindowController()
        windowControllers.append(windowController)
        windowController.showWindow(nil)
    }
} 