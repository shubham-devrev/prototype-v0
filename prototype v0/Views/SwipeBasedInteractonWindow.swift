//
//  MainWindow.swift
//  prototype v0
//
//  Created by Shubham Gandhi on 15/12/24.
//

import SwiftUI

struct SwipeBasedInteractonWindow: View {
    @State private var selectedSidebarItem: Int? = 0
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            SwipeableNavigationView([
                .init(view: HomeView(), icon: "house.fill"),
                .init(view: ChatViewV2(), icon: "message.fill"),
                .init(view: SettingsView(), icon: "gear")
            ])            .frame(minWidth: 200)
        } detail: {

            Text("Detail")
        }
    }
}

struct HomeView: View {
    var body: some View {
        VStack {
            Text("Home")
                .font(.largeTitle)
            List {
                ForEach(0..<10) { i in
                    Text("Home Item \(i)")
                }
            }
        }
    }
}

struct ChatViewV2: View {
    var body: some View {
        VStack {
            Text("Chat")
                .font(.largeTitle)
            List {
                ForEach(0..<10) { i in
                    HStack {
                        Image(systemName: "person.circle.fill")
                        Text("Chat \(i)")
                    }
                }
            }
        }
    }
}

struct SettingsView: View {
    @State private var enableNotifications = true
    @State private var darkMode = false
    @State private var autoUpdates = true
    @State private var showSidebar = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Settings")
                    .font(.largeTitle)
                    .padding(.top)
                
                Form {
                    Section("General") {
                        Toggle("Enable Notifications", isOn: $enableNotifications)
                        Toggle("Dark Mode", isOn: $darkMode)
                        Toggle("Auto Updates", isOn: $autoUpdates)
                        Toggle("Send Analytics", isOn: .constant(false))
                        Toggle("Enable Notifications", isOn: $enableNotifications)
                        Toggle("Dark Mode", isOn: $darkMode)
                        Toggle("Auto Updates", isOn: $autoUpdates)
                        Toggle("Send Analytics", isOn: .constant(false))
                        Toggle("Enable Notifications", isOn: $enableNotifications)
                        Toggle("Dark Mode", isOn: $darkMode)
                        Toggle("Auto Updates", isOn: $autoUpdates)
                        Toggle("Send Analytics", isOn: .constant(false))
                        Toggle("Enable Notifications", isOn: $enableNotifications)
                        Toggle("Dark Mode", isOn: $darkMode)
                        Toggle("Auto Updates", isOn: $autoUpdates)
                        Toggle("Send Analytics", isOn: .constant(false))
                    }
                    
                    // ... rest of the sections ...
                }
                .formStyle(.grouped)
                .padding(.horizontal)
            }
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// Preview
#Preview("Main Window") {
    SwipeBasedInteractonWindow()
        .frame(width: 1000, height: 600)
}
