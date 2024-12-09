import SwiftUI
import AppKit
import ScreenCaptureKit

class WindowScreenshotPicker {
    static func checkScreenRecordingPermission() async -> Bool {
        let content = try? await SCShareableContent.current
        return content != nil
    }
    
    static func requestScreenRecordingPermission() {
        let alert = NSAlert()
        alert.messageText = "Screen Recording Permission Required"
        alert.informativeText = "To capture window screenshots, please grant screen recording permission in System Settings > Privacy & Security > Screen Recording."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Cancel")
        
        if alert.runModal() == .alertFirstButtonReturn {
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
                NSWorkspace.shared.open(url)
            }
        }
    }
    
    static func captureWindow(completion: @escaping (NSImage?, [String: Any]?) -> Void) {
        Task {
            // Check for screen recording permission first
            guard await checkScreenRecordingPermission() else {
                DispatchQueue.main.async {
                    requestScreenRecordingPermission()
                }
                return
            }
            
            // Get available windows
            guard let content = try? await SCShareableContent.current else { return }
            let windows = content.windows.filter { window in
                window.isOnScreen && window.title?.isEmpty == false
            }
            
            // Create window selection UI on main thread
            await MainActor.run {
                let panel = NSPanel(
                    contentRect: NSRect(x: 0, y: 0, width: 600, height: 200),
                    styleMask: [.nonactivatingPanel, .fullSizeContentView],
                    backing: .buffered,
                    defer: false
                )
                
                panel.isMovableByWindowBackground = true
                panel.backgroundColor = .clear
                panel.isOpaque = false
                panel.hasShadow = true
                panel.level = .floating
                
                let hostingView = NSHostingView(rootView: WindowSelectionView(
                    windows: windows,
                    onSelect: { selectedWindow in
                        panel.close()
                        Task {
                            if let cgImage = CGWindowListCreateImage(
                                .null,
                                .optionIncludingWindow,
                                CGWindowID(selectedWindow.windowID),
                                [.boundsIgnoreFraming]
                            ) {
                                let screenshot = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
                                let windowInfo: [String: Any] = [
                                    kCGWindowOwnerName as String: selectedWindow.owningApplication?.applicationName ?? "",
                                    "title": selectedWindow.title ?? "Unknown Window"
                                ]
                                completion(screenshot, windowInfo)
                            }
                        }
                    }
                ))
                
                panel.contentView = hostingView
                panel.center()
                panel.makeKeyAndOrderFront(nil)
            }
        }
    }
}

struct WindowSelectionView: View {
    let windows: [SCWindow]
    let onSelect: (SCWindow) -> Void
    @State private var hoveredWindow: SCWindow? = nil
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(windows, id: \.self) { window in
                    WindowPreviewButton(
                        window: window,
                        isHovered: window == hoveredWindow,
                        onSelect: onSelect
                    )
                    .onHover { isHovered in
                        hoveredWindow = isHovered ? window : nil
                    }
                }
            }
            .padding(20)
        }
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

struct WindowPreviewButton: View {
    let window: SCWindow
    let isHovered: Bool
    let onSelect: (SCWindow) -> Void
    @State private var preview: NSImage? = nil
    
    var body: some View {
        Button(action: { onSelect(window) }) {
            VStack(spacing: 8) {
                if let preview = preview {
                    Image(nsImage: preview)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 100)
                        .cornerRadius(6)
                }
                
                Text(window.title ?? "Unknown Window")
                    .font(.system(size: 11))
                    .lineLimit(1)
                    .foregroundColor(.primary)
            }
            .padding(8)
            .background(isHovered ? Color.gray.opacity(0.15) : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .frame(width: 160)
        .task {
            if let cgImage = CGWindowListCreateImage(
                .null,
                .optionIncludingWindow,
                CGWindowID(window.windowID),
                [.boundsIgnoreFraming]
            ) {
                preview = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
            }
        }
    }
} 
