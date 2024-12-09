import AppKit

/// Utility class for configuring window appearance
enum WindowConfig {
    /// Configure the main window with transparent title bar and proper styling
    static func configureMainWindow() {
        NSWindow.allowsAutomaticWindowTabbing = false
        
        let workItem = DispatchWorkItem {
            if let window = NSApplication.shared.windows.first {
                window.titlebarAppearsTransparent = true
                window.titleVisibility = .hidden
                window.isMovableByWindowBackground = true
                window.styleMask.insert(.fullSizeContentView)
                window.backgroundColor = .clear
                
                // Ensure window buttons are visible and styled
                let buttons: [NSWindow.ButtonType] = [.closeButton, .miniaturizeButton, .zoomButton]
                buttons.forEach { buttonType in
                    if let button = window.standardWindowButton(buttonType) {
                        button.isHidden = false
                        button.wantsLayer = true
                    }
                }
            }
        }
        
        DispatchQueue.main.async(execute: workItem)
    }
} 