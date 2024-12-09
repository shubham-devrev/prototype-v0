//
//  ContentView.swift
//  prototype v0
//
//  Created by Shubham Gandhi on 04/12/24.
//

import SwiftUI
import AppKit

struct ContentView: View {
    @State private var showingPanel = false
    @State private var searchText = ""
    
    var body: some View {
        ZStack {
            EffectView()
                .edgesIgnoringSafeArea(.all)
            
            HStack(spacing: 0) {
                SidebarView()
                
                VStack {
                    Button("Search (⌘K)") {
                        showingPanel.toggle()
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(6)
                    .help("Press to search")
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 800, minHeight: 600)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
        .preferredColorScheme(.dark)
}

