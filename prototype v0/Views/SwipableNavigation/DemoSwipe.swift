//
//  DemoSwipe.swift
//  prototype v0
//
//  Created by Shubham Gandhi on 13/12/24.
//

import SwiftUI
import AppKit

struct EventView: NSViewRepresentable {
    @Binding var message: String

    class Coordinator: NSObject {
        var parent: EventView
        var accumulatedScrollDeltaX: CGFloat = 0
        
        init(parent: EventView) {
            self.parent = parent
        }

        @objc func handleEvent(_ event: NSEvent) {
            if event.type == .scrollWheel {
                accumulatedScrollDeltaX += event.scrollingDeltaX
                if abs(accumulatedScrollDeltaX) > 50 {
                    if accumulatedScrollDeltaX > 0 {
                        parent.message = "Swiped Right!"
                    } else {
                        parent.message = "Swiped Left!"
                    }
                    accumulatedScrollDeltaX = 0 // Reset after detecting a swipe
                }
                print("Scroll delta X: \(event.scrollingDeltaX), accumulated: \(accumulatedScrollDeltaX)")
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        
        NSEvent.addLocalMonitorForEvents(matching: [.scrollWheel]) { event in
            context.coordinator.handleEvent(event)
            return event
        }
        
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        // No updates needed
    }
}

struct ContentDemoView: View {
    @State private var message = "Swipe right to reveal"

    var body: some View {
        VStack {
            Text(message)
                .padding()
                .background(Color.orange)

            EventView(message: $message)
                .frame(height: 200) // Area to capture events
                .background(Color.gray)
        }
        .padding()
    }
}



struct ContentDemoView_Previews: PreviewProvider {
    static var previews: some View {
        ContentDemoView()
    }
}
