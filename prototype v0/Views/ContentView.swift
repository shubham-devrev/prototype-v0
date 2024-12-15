//
//  ContentView.swift
//  prototype v0
//
//  Created by Shubham Gandhi on 04/12/24.
//

import SwiftUI
import AppKit


struct ContentView: View {
    @StateObject private var windowManager = WindowManager.shared
    @State private var showingPanel = false
    @State private var searchText = ""
    @State private var selectedView = "home"
    @State private var selectedChatId: String? = nil
    
    var body: some View {
        ZStack {
            EffectView()
                .edgesIgnoringSafeArea(.all)
            
            HStack(spacing: 0) {
                SidebarView(activeButton: $selectedView, selectedChatId: $selectedChatId)
                
                // Main content area
                VStack {
                    // Toolbar with new window button
                    HStack {
                        Spacer()
                        Button(action: {
                            windowManager.openNewWindow()
                        }) {
                            Image(systemName: "plus.square")
                            Text("New Window")
                        }
                        .padding(.horizontal)
                    }
                    
                    // Main content view switching
                    Group {
                        switch selectedView {
                        case "home":
                            TodayView()
                        case "inbox":
                            InboxView()
                        case "explore":
                            ExploreView()
                        case "chat":
                            ChatView(chatId: selectedChatId ?? "all-chats", isAIChat: false)
                        case "ai":
                            ChatView(chatId: "ai-assistant", isAIChat: true)
                        case let id where User.mockUsers.contains(where: { $0.id == id }):
                            ChatView(chatId: id, isAIChat: false)
                        default:
                            Text("Select a view")
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .floatingPanel(
                    isPresented: $showingPanel,
                    contentRect: NSScreen.bottomLeftPosition(width: 360)
                ) {
                    SearchView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 800, minHeight: 600)
        .onAppear {
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "k" {
                    showingPanel.toggle()
                    return nil
                }
                return event
            }
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}

