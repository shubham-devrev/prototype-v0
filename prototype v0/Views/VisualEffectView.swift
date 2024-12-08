//
//  VisualEffectView.swift
//  prototype v0
//
//  Created by Shubham Gandhi on 04/12/24.
//

import SwiftUI

struct VisualEffectView: NSViewRepresentable {
    var cornerRadius: CGFloat = 10
    var borderWidth: CGFloat = 1
    var borderColor: NSColor = .gray
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        context.coordinator.visualEffectView
    }
    
    func updateNSView(_ view: NSVisualEffectView, context: Context) {
        context.coordinator.update(
            cornerRadius: cornerRadius,
            borderWidth: borderWidth,
            borderColor: borderColor
        )
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        let visualEffectView = NSVisualEffectView()
        
        init() {
            visualEffectView.wantsLayer = true
            
            // Use semantic material
            visualEffectView.material = .windowBackground
            visualEffectView.state = .active
            visualEffectView.isEmphasized = false
            visualEffectView.blendingMode = .withinWindow
            
            // Force dark appearance
            visualEffectView.appearance = NSAppearance(named: .darkAqua)
            
            // Add solid black background
            visualEffectView.layer?.backgroundColor = NSColor.black.cgColor
        }
        
        func update(cornerRadius: CGFloat, borderWidth: CGFloat, borderColor: NSColor) {
            visualEffectView.layer?.cornerRadius = cornerRadius
            visualEffectView.layer?.borderWidth = borderWidth
            visualEffectView.layer?.borderColor = borderColor.cgColor
        }
    }
}
