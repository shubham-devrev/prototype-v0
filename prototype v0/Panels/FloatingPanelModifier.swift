//
//  FloatingPanelModifiers.swift
//  prototype v0
//
//  Created by Shubham Gandhi on 04/12/24.
//

import Foundation

import SwiftUI

extension NSScreen {
    static func bottomLeftPosition(width: CGFloat, height: CGFloat = 720) -> CGRect {
        let screen = NSScreen.main ?? NSScreen.screens[0]
        let screenRect = screen.visibleFrame
        
        // Position from bottom-left
        let x = screenRect.minX + 36
        let y = screenRect.minY + 24
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
}

fileprivate struct FloatingPanelModifier<PanelContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    var contentRect: CGRect
    @ViewBuilder let view: () -> PanelContent
    @State var panel: FloatingPanel<PanelContent>?
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                panel = FloatingPanel(
                    view: view,
                    contentRect: contentRect,
                    isPresented: $isPresented
                )
                if isPresented {
                    present()
                }
            }
            .onDisappear {
                panel?.close()
                panel = nil
            }
            .onChange(of: isPresented) { _, isPresented in
                if isPresented {
                    present()
                } else {
                    panel?.close()
                }
            }
    }
    
    func present() {
        panel?.orderFront(nil)
        panel?.makeKey()
//        panel?.repositionFromBottom() // Ensure bottom positioning
    }
}


extension View {
    func floatingPanel<Content: View>(
        isPresented: Binding<Bool>,
        contentRect: CGRect = NSScreen.bottomLeftPosition(width: 480, height: 320), // Only specify width
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.modifier(FloatingPanelModifier(
            isPresented: isPresented,
            contentRect: contentRect,
            view: content
        ))
    }
}
