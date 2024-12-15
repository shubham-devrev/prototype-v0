// import SwiftUI
// import AppKit


// struct AppNavigationPreview: View {
//     @StateObject private var appState = AppStateManager()
//     @State private var rightPanelWidth: CGFloat = 300
//     private let minRightPanelWidth: CGFloat = 240
    
//     var body: some View {
//         NavigationSplitView(columnVisibility: $appState.columnVisibility) {
//             // Sidebar
//             SidebarContent()
//                 .frame(minWidth: 64, maxWidth: 64)
//                 .background(.ultraThinMaterial)
//         } detail: {
//             // Main Content with Right Panel
//             ZStack(alignment: .trailing) {
//                 // Main Content Area
//                 mainContent
//                     .frame(maxWidth: .infinity, maxHeight: .infinity)
                
//                 // Right Panel
//                 if appState.showRightPanel {
//                     rightPanel
//                         .frame(width: rightPanelWidth)
//                         .background(.ultraThinMaterial)
//                         .clipShape(RoundedRectangle(cornerRadius: 12))
//                         .shadow(color: .black.opacity(0.2), radius: 5)
//                         .transition(.move(edge: .trailing))
//                 }
//             }
//             .toolbar {
//                 ToolbarItem(placement: .automatic) {
//                     if appState.activeSection.showsRightPanel {
//                         Button(action: { appState.toggleRightPanel() }) {
//                             Image(systemName: appState.showRightPanel ? "sidebar.right" : "sidebar.left")
//                         }
//                     }
//                 }
//             }
//         }
//     }
    
//     // Main Content View
//     private var mainContent: some View {
//         VStack {
//             switch appState.activeSection {
//             case .home:
//                 HomeView()
//             case .inbox:
//                 InboxView()
//             case .explore:
//                 ExploreView()
//             case .today:
//                 Text("Today View")
//             case .ai:
//                 Text("AI Assistant")
//             case .messages:
//                 Text("Messages")
//             }
//         }
//     }
    
//     // Right Panel View
//     private var rightPanel: some View {
//         HStack(spacing: 0) {
//             // Resize Handle
//             ResizeHandle(width: $rightPanelWidth, minWidth: minRightPanelWidth)
            
//             // Panel Content
//             VStack {
//                 Text("Right Panel")
//                     .font(.headline)
//                 Spacer()
//             }
//             .frame(maxWidth: .infinity, maxHeight: .infinity)
//             .padding()
//         }
//     }
// }

// // Resize Handle Component
// struct ResizeHandle: View {
//     @Binding var width: CGFloat
//     let minWidth: CGFloat
//     @State private var isHovered = false
//     @GestureState private var isDragging = false
    
//     var body: some View {
//         Rectangle()
//             .fill(Color.gray.opacity(isHovered || isDragging ? 0.5 : 0.0))
//             .frame(width: 4)
//             .onHover { hover in
//                 isHovered = hover
//                 if hover {
//                     NSCursor.resizeLeftRight.push()
//                 } else {
//                     NSCursor.pop()
//                 }
//             }
//             .gesture(
//                 DragGesture()
//                     .updating($isDragging) { _, state, _ in
//                         state = true
//                     }
//                     .onChanged { value in
//                         let newWidth = width - value.translation.width
//                         width = max(minWidth, newWidth)
//                     }
//             )
//     }
// }

// // Sidebar Content
// struct SidebarContent: View {
//     @EnvironmentObject private var appState: AppStateManager
    
//     var body: some View {
//         VStack(spacing: 8) {
//             ForEach([
//                 AppSection.home,
//                 AppSection.inbox,
//                 AppSection.today,
//                 AppSection.explore,
//                 AppSection.ai,
//                 AppSection.messages
//             ], id: \.self) { section in
//                 SidebarActionButton(
//                     id: section.rawValue,
//                     isActive: appState.activeSection == section,
//                     helpText: section.rawValue
//                 ) {
//                     // Action closure
//                     appState.navigateToSection(section)
//                 } content: {
//                     // Content closure
//                     Image(systemName: section.icon)
//                 }
//             }
            
//             Spacer()
//         }
//         .padding(.vertical, 12)
//     }
// }

// // Preview Provider
// #Preview {
//     AppNavigationPreview()
//         .environmentObject(AppStateManager())
//         .frame(width: 1200, height: 800)
//         .preferredColorScheme(.dark)
// }
