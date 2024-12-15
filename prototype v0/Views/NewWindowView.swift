import SwiftUI
import AppKit

struct NewWindowView: View {
    @StateObject private var appState = AppStateManager()
    
    var sidebarButtons: some View {
        VStack(spacing: 8) {
            // Main navigation
            VStack(spacing: 8) {
                ForEach([AppSection.home, .inbox, .today, .explore], id: \.self) { section in
                    SidebarActionButton(
                        id: section.rawValue.lowercased(),
                        isActive: appState.activeSection == section,
                        helpText: section.rawValue,
                        action: { appState.navigateToSection(section) }
                    ) {
                        Image(systemName: section.icon)
                    }
                }
            }
            
            Spacer()
            
            // Chat section
            VStack(spacing: 8) {
                ForEach([AppSection.ai, .messages], id: \.self) { section in
                    SidebarActionButton(
                        id: section.rawValue.lowercased(),
                        isActive: appState.activeSection == section,
                        helpText: section.rawValue,
                        variant: section == .ai ? .circular : .default,
                        action: { appState.navigateToSection(section) }
                    ) {
                        Image(systemName: section.icon)
                    }
                }
            }
        }
    }
    
    var navigationList: some View {
        List {
            switch appState.activeSection {
            case .ai:
                Text("AI Conversations")
                    .font(.headline)
                    .padding(.vertical, 4)
                ForEach(1...5, id: \.self) { index in
                    Button("AI Chat \(index)") {
                        appState.selectContent(.ai("\(index)"))
                    }
                }
            case .messages:
                Text("Message Threads")
                    .font(.headline)
                    .padding(.vertical, 4)
                ForEach(1...5, id: \.self) { index in
                    Button("Thread \(index)") {
                        appState.selectContent(.messages("\(index)"))
                    }
                }
            case .inbox:
                Text("Inbox Items")
                    .font(.headline)
                    .padding(.vertical, 4)
                ForEach(1...10, id: \.self) { index in
                    Button("Inbox Item \(index)") {
                        appState.selectContent(.inbox("\(index)"))
                    }
                }
            case .today:
                Text("Today's Items")
                    .font(.headline)
                    .padding(.vertical, 4)
                ForEach(1...10, id: \.self) { index in
                    Button("Today Item \(index)") {
                        appState.selectContent(.today("\(index)"))
                    }
                }
            case .explore:
                Text("Explore")
                    .font(.headline)
                    .padding(.vertical, 4)
                ForEach(1...10, id: \.self) { index in
                    Button("Explore Item \(index)") {
                        appState.selectContent(.explore)
                    }
                }
            default:
                EmptyView()
            }
        }
        .navigationTitle(appState.activeSection.rawValue)
        .frame(minWidth: 200)
    }
    
    // Then update the rightPanel view:
    var rightPanel: some View {
        VStack(spacing: 0) {
            // Tab bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(appState.rightPanelTabs, id: \.self) { tab in
                        TabButton(
                            title: tab,
                            isActive: appState.activeTab == tab,
                            onSelect: { appState.activeTab = tab },
                            onClose: { appState.removeTab(tab) }
                        )
                    }
                    
                    // Add tab button
                    Button(action: { appState.addTab() }) {
                        Image(systemName: "plus")
                            .font(.system(size: 12))
                            .padding(6)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 4)
                }
                .padding(.horizontal, 8)
            }
            .frame(height: 32)
            .background(.ultraThinMaterial)
            
            Divider()
            
            // Content area
            VStack {
                // Header with close button
                HStack {
                    Text(appState.activeTab)
                        .font(.headline)
                    Spacer()
                    Button(action: { appState.closeRightPanel() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding([.horizontal, .top], 16)
                .padding(.bottom, 8)
                
                // Tab content
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Content for \(appState.activeTab)")
                            .font(.body)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                }
            }
        }
        .frame(minWidth: 280, maxWidth: 400)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.2), radius: 5)
        .padding(.trailing, 16) // Add padding to the right
        .padding(.top, -32)
        .padding(.bottom, 8)// Add padding to the top
    }

    // Add this TabButton component
    struct TabButton: View {
        let title: String
        let isActive: Bool
        let onSelect: () -> Void
        let onClose: () -> Void
        @State private var isHovered = false
        
        var body: some View {
            Button(action: onSelect) {
                HStack(spacing: 4) {
                    Text(title)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    if isHovered || isActive {
                        Button(action: onClose) {
                            Image(systemName: "xmark")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                        .padding(2)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(isActive ? Color.gray.opacity(0.3) : (isHovered ? Color.gray.opacity(0.2) : Color.clear))
                .cornerRadius(6)
            }
            .buttonStyle(.plain)
            .onHover { hover in
                isHovered = hover
            }
        }
    }
    
    var mainContent: some View {
        VStack {
            Text(appState.activeContent.title)
                .font(.title)
                .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Custom icon sidebar
            sidebarButtons
                .padding(.vertical, 12)
                .frame(width: 64)
                .background(.ultraThinMaterial)
            
            // Main content with navigation
            NavigationSplitView(columnVisibility: Binding(
                get: { self.appState.columnVisibility },
                set: { self.appState.columnVisibility = $0 }
            )) {
                navigationList
                    .toolbar {
                        ToolbarItemGroup(placement: .automatic) {
                            navigationToolbarItems()
                        }
                    }
            } detail: {
                ZStack(alignment: .trailing) {
                    // Main content
                    mainContent
                        .navigationTitle(appState.activeContent.title)
                    // Right panel
                    if appState.showRightPanel {
                        rightPanel
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .automatic) {
                        detailToolbarItems()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.clear)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                if appState.activeSection.showsRightPanel {
                    Button(action: { appState.toggleRightPanel() }) {
                        Image(systemName: appState.showRightPanel ? "sidebar.right.fill" : "sidebar.right")
                            .foregroundStyle(appState.showRightPanel ? .blue : .primary)
                    }
                    .help(appState.showRightPanel ? "Hide Panel" : "Show Panel")
                    .keyboardShortcut("\\", modifiers: [.command])
                }
            }
        }
        .toolbarBackground(.clear, for: .windowToolbar)
    }
}

// First, let's create an extension for toolbar items
extension NewWindowView {
    @ViewBuilder
    func navigationToolbarItems() -> some View {
        Group {
            switch appState.activeSection {
            case .home:
                Button(action: {}) {
                    Image(systemName: "plus")
                }
                Button(action: {}) {
                    Image(systemName: "square.grid.2x2")
                }
                
            case .inbox:
                Button(action: {}) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
                Button(action: {}) {
                    Image(systemName: "arrow.up.arrow.down")
                }
                Menu {
                    Button("All Items", action: {})
                    Button("Unread", action: {})
                    Button("Archived", action: {})
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                
            case .today:
                Button(action: {}) {
                    Image(systemName: "calendar")
                }
                Button(action: {}) {
                    Image(systemName: "list.bullet")
                }
                
            case .explore:
                Button(action: {}) {
                    Image(systemName: "magnifyingglass")
                }
                Menu {
                    Button("Most Recent", action: {})
                    Button("Most Popular", action: {})
                    Button("Categories", action: {})
                } label: {
                    Image(systemName: "arrow.up.arrow.down.circle")
                }
                
            case .ai:
                Button(action: {}) {
                    Image(systemName: "plus.circle")
                }
                Button(action: {}) {
                    Image(systemName: "sparkles")
                }
                Menu {
                    Button("New Chat", action: {})
                    Button("Import", action: {})
                    Button("Export", action: {})
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                
            case .messages:
                Button(action: {}) {
                    Image(systemName: "square.and.pencil")
                }
                Button(action: {}) {
                    Image(systemName: "person.2")
                }
                Menu {
                    Button("All Messages", action: {})
                    Button("Unread", action: {})
                    Button("Archive", action: {})
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        }
    }
    
    @ViewBuilder
    func detailToolbarItems() -> some View {
        Group {
            switch appState.activeSection {
            case .home:
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                }
                
            case .inbox:
                Button(action: {}) {
                    Image(systemName: "archivebox")
                }
                Button(action: {}) {
                    Image(systemName: "flag")
                }
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                }
                
            case .today:
                Button(action: {}) {
                    Image(systemName: "checkmark.circle")
                }
                Button(action: {}) {
                    Image(systemName: "calendar.badge.plus")
                }
                
            case .explore:
                Button(action: {}) {
                    Image(systemName: "bookmark")
                }
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                }
                
            case .ai:
                Button(action: {}) {
                    Image(systemName: "arrow.counterclockwise")
                }
                Button(action: {}) {
                    Image(systemName: "doc.on.doc")
                }
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.down")
                }
                
            case .messages:
                Button(action: {}) {
                    Image(systemName: "bell")
                }
                Button(action: {}) {
                    Image(systemName: "phone")
                }
                Button(action: {}) {
                    Image(systemName: "video")
                }
            }
            
            // Right panel toggle (common for all sections that support it)
            if appState.activeSection.showsRightPanel {
                Button(action: { appState.toggleRightPanel() }) {
                    Image(systemName: "sidebar.right")
                        .foregroundStyle(appState.showRightPanel ? .blue : .primary)
                }
            }
        }
    }
}
