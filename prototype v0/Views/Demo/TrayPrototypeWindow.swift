import SwiftUI

// MARK: - Models
struct TrayItem: Identifiable {
    let id: UUID = UUID()
    let title: String
    let icon: String
    let description: String
    var isExpanded: Bool = false
}

// MARK: - View Model
class TrayViewModel: ObservableObject {
    @Published var trays: [TrayItem] = [
        TrayItem(title: "Ask AI", icon: "sparkle", description: "AI Assistant"),
        TrayItem(title: "Shubham Gandhi", icon: "person", description: "Product Designer"),
        TrayItem(title: "Pedro Pascal", icon: "person", description: "Engineering"),
        TrayItem(title: "Talon", icon: "sparkle", description: "AI Assistant")
    ]
    @Published var expandedTrayId: UUID?
    @Published var expandedFrame: CGRect = .zero
    
    func expandTray(_ id: UUID, from frame: CGRect) {
        expandedFrame = frame
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            expandedTrayId = id
        }
    }
    
    func collapseTray() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            expandedTrayId = nil
        }
    }
}

// MARK: - Collapsed Tray View
struct CollapsedTrayView: View {
    let tray: TrayItem
    let index: Int
    @State private var isHovered = false
    let action: (CGRect) -> Void
    private let baseContentHeight: CGFloat = 200
    
    private var backgroundColor: Color {
        let baseColor = Color(NSColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0))
        let brightnessDecrease = Double(index) * 0.05
        return baseColor.opacity(1.0 - brightnessDecrease)
    }
    
    private var user: User {
        if index == 0 || index == 3 {
            // Internal users (Talon and Ask AI)
            return User(
                id: tray.id.uuidString,
                name: tray.title,
                email: "\(tray.title.lowercased().replacingOccurrences(of: " ", with: "."))@company.com",
                avatarUrl: nil,
                status: .online,
                role: .member,
                type: .internal,
                account: nil
            )
        } else {
            // External users
            return User(
                id: tray.id.uuidString,
                name: tray.title,
                email: "\(tray.title.lowercased().replacingOccurrences(of: " ", with: "."))@external.com",
                avatarUrl: nil,
                status: .online,
                role: .member,
                type: .external,
                account: Account(
                    name: tray.title,
                    logoUrl: nil
                )
            )
        }
    }
    
    var body: some View {
        Button(action: {
            action(CGRect.zero)
        }) {
            VStack(alignment: .leading) {
                HStack(spacing: 16) {
                    Avatar(
                        user: user,
                        size: 24,
                        showStatus: true
                    )
                    
                    Text(tray.title)
                        .font(.headline)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.up")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .opacity(isHovered ? 1 : 0)
                }
                Spacer()
            }
            .padding(16)
            .frame(height: baseContentHeight)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hover in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hover
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Expanded Tray View
struct ExpandedTrayView: View {
    let tray: TrayItem
    let onDismiss: () -> Void
    let initialFrame: CGRect
    let namespace: Namespace.ID
    
    private var backgroundColor: Color {
        Color(NSColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                }
                Text(tray.title)
                    .font(.headline)
                Spacer()
            }
            .padding()
            .background(.ultraThinMaterial)
            
            // Content
            ScrollView {
                VStack(spacing: 20) {
                    Avatar(
                        user: User(
                            id: tray.id.uuidString,
                            name: tray.title,
                            email: "\(tray.title.lowercased())@example.com",
                            avatarUrl: nil,
                            status: .online,
                            role: .member,
                            type: .internal
                        ),
                        size: 80
                    )
                    .padding()
                    
                    Text("Expanded content for \(tray.title)")
                        .font(.title2)
                    
                    Spacer(minLength: 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
        }
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .matchedGeometryEffect(id: tray.id, in: namespace)
    }
}

// MARK: - Tray Container View
struct TrayContainerView: View {
    @StateObject private var viewModel = TrayViewModel()
    @Namespace private var namespace
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                if viewModel.expandedTrayId == nil {
                    ForEach(Array(viewModel.trays.enumerated()), id: \.element.id) { index, tray in
                        CollapsedTrayView(tray: tray, index: index) { frame in
                            viewModel.expandTray(tray.id, from: frame)
                        }
                        .matchedGeometryEffect(id: tray.id, in: namespace)
                        .offset(y: -CGFloat(index) * 60)
                        .zIndex(Double(viewModel.trays.count - index))
                    }
                    .padding(.bottom)
                }
                
                if let expandedId = viewModel.expandedTrayId,
                   let expandedTray = viewModel.trays.first(where: { $0.id == expandedId }) {
                    ExpandedTrayView(
                        tray: expandedTray,
                        onDismiss: { viewModel.collapseTray() },
                        initialFrame: viewModel.expandedFrame,
                        namespace: namespace
                    )
                    .zIndex(100)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }
}

// MARK: - Mock Navigation View
struct MockNavigationView: View {
    @State private var selectedItem: String?
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    @StateObject private var viewModel = TrayViewModel()
    @Namespace private var namespace
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Navigation Content with Tray
            ZStack(alignment: .bottom) {
                if viewModel.expandedTrayId == nil {
                    // Show list and collapsed trays
                    VStack {
                        List(selection: $selectedItem) {
                            Section("Recent") {
                                ForEach(["Project A", "Project B", "Project C"], id: \.self) { item in
                                    NavigationLink(value: item) {
                                        Text(item)
                                    }
                                }
                            }
                            
                            Section("Teams") {
                                ForEach(["Design", "Engineering", "Product"], id: \.self) { item in
                                    NavigationLink(value: item) {
                                        Text(item)
                                    }
                                }
                            }
                        }
                        
                        Spacer(minLength: 400)
                    }
                    
                    // Collapsed Trays
                    TrayContainerView()
                        .frame(maxHeight: .infinity)
                }
                
                // Expanded Tray (full height)
                if let expandedId = viewModel.expandedTrayId,
                   let expandedTray = viewModel.trays.first(where: { $0.id == expandedId }) {
                    ExpandedTrayView(
                        tray: expandedTray,
                        onDismiss: { viewModel.collapseTray() },
                        initialFrame: viewModel.expandedFrame,
                        namespace: namespace
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Projects")
            .frame(minWidth: 300)
            
        } detail: {
            // Empty Detail View
            if let selected = selectedItem {
                Text(selected)
                    .font(.title)
            } else {
                Text("Select a project")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Preview Provider
struct MockNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        MockNavigationView()
            .frame(width: 1200, height: 800)
            .preferredColorScheme(.dark)
    }
}
