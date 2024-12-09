//
//  ContentView.swift
//  prototype v0
//
//  Created by Shubham Gandhi on 04/12/24.
//

import SwiftUI

struct ContentView: View {
    @State private var showingPanel = false
    @State private var searchText = ""
    
    var body: some View {
        Button("Search (⌘K)") {
            showingPanel.toggle()
        }
        .tooltip() {
            Text("Press to search")
        }
        .floatingPanel(
            isPresented: $showingPanel,
            contentRect: NSScreen.bottomLeftPosition(width: 360)
        ) {
            SearchView()
        }
        .keyboardShortcut("k", modifiers: .command)
        .onChange(of: showingPanel, initial: false) { oldValue, newValue in
            if !newValue {
                searchText = ""
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}

