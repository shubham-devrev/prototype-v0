//
//  SearchView.swift
//  prototype v0
//
//  Created by Shubham Gandhi on 04/12/24.
//

import SwiftUI
import Combine
import os.log
import AppKit

// MARK: - Search ViewModel
@MainActor
final class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published private(set) var searchResults: [ResultItem] = []
    @Published private(set) var error: Error?
    @Published var shouldFocusInput = false
    @Published private(set) var uploadedFile: FileAttachment?
    @Published private(set) var capturedScreenshot: NSImage?
    @Published private(set) var capturedWindowInfo: [String: Any]?
    
    private var cancellables = Set<AnyCancellable>()
    private let searchManager = SmartSearchManager.shared
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.app", category: "SearchView")
    
    init() {
        setupSearchDebounce()
    }
    
    private func setupSearchDebounce() {
        $searchText
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                Task {
                    await self?.performSearch(query: query)
                }
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        error = nil
        
        searchResults = searchManager.search(query: query) { [weak self] action in
            self?.handleSearchAction(action)
        }
    }
    
    func handleSearchAction(_ action: String) {
        Task {
            do {
                switch true {
                case action.hasPrefix("ai_query:"):
                    try await handleAIQuery(String(action.dropFirst(9)))
                case action.hasPrefix("open_article:"):
                    try await openArticle(String(action.dropFirst(13)))
                case action.hasPrefix("create_article:"):
                    try await createArticle(String(action.dropFirst(15)))
                case action.hasPrefix("create_ticket:"):
                    try await createTicket(String(action.dropFirst(14)))
                default:
                    logger.warning("Unknown action: \(action)")
                }
            } catch {
                self.error = error
            }
        }
    }
    
    func uploadFile(from window: NSWindow?) async throws {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.styleMask.remove(.resizable)
        panel.level = .modalPanel
        
        // Set the panel to be a child window of the floating panel
        if let parentWindow = window {
            panel.parent = parentWindow
            parentWindow.addChildWindow(panel, ordered: .above)
            
            // Make sure the floating panel is key and accessible
            defer {
                parentWindow.makeKeyAndOrderFront(nil)
                shouldFocusInput = true
            }
            
            guard panel.runModal() == .OK,
                  let url = panel.url else {
                return
            }
            
            try await handleFileUpload(url)
        }
    }
    
    private func handleFileUpload(_ url: URL) async throws {
        logger.info("Uploading file: \(url.path)")
        uploadedFile = FileAttachment(url: url)
        try await Task.sleep(nanoseconds: 100_000_000)
    }
    
    func removeUploadedFile() {
        uploadedFile = nil
    }
    
    func showFilters() {
        logger.info("Showing filters")
    }
    
    func browse() {
        logger.info("Browsing")
    }
    
    private func handleAIQuery(_ query: String) async throws {
        logger.info("Handling AI query: \(query)")
    }
    
    private func openArticle(_ articleId: String) async throws {
        logger.info("Opening article: \(articleId)")
    }
    
    private func createArticle(_ title: String) async throws {
        logger.info("Creating article: \(title)")
    }
    
    private func createTicket(_ title: String) async throws {
        logger.info("Creating ticket: \(title)")
    }
    
    func setCapturedScreenshot(_ image: NSImage?, windowInfo: [String: Any]?) {
        capturedScreenshot = image
        capturedWindowInfo = windowInfo
    }
    
    func clearCapturedScreenshot() {
        capturedScreenshot = nil
        capturedWindowInfo = nil
    }
}

// MARK: - SearchView
struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @FocusState private var isFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.floatingPanel) private var floatingPanel
    @State private var selectedIndex = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Results - Only show if no screenshot or file is present
            let shouldShowResults = !viewModel.searchResults.isEmpty
            let noScreenshot = viewModel.capturedScreenshot == nil
            let noUploadedFile = viewModel.uploadedFile == nil
            
            if shouldShowResults && noScreenshot && noUploadedFile {
                SearchResultsView(
                    results: viewModel.searchResults,
                    selectedIndex: $selectedIndex,
                    isFocused: _isFocused
                )
                Divider()
                    .background(Color.white.opacity(0.1))
            }
            
            // Screenshot Preview
            if let screenshot = viewModel.capturedScreenshot {
                ScreenshotPreview(
                    screenshot: screenshot,
                    window: viewModel.capturedWindowInfo ?? [:],
                    onRemove: {
                        viewModel.clearCapturedScreenshot()
                    }
                )
                .padding(.horizontal, 8)
                .padding(.top, 8)
            }
            
            // File Preview
            if let file = viewModel.uploadedFile {
                FileAttachmentView(
                    attachment: file,
                    style: .expanded,
                    onRemove: {
                        viewModel.removeUploadedFile()
                    }
                )
                .padding(.horizontal, 8)
                .padding(.top, 8)
            }
            
            // Search bar
            HStack(spacing: 8) {
                TextField("Search across Maple's Knowledge...", text: $viewModel.searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 14))
                    .focused($isFocused)
                    .tint(colorScheme == .dark ? .white : .black)
                    // Handle keyboard navigation
                    .onKeyPress(.upArrow) {
                        moveSelection(up: true)
                        return .handled
                    }
                    .onKeyPress(.downArrow) {
                        moveSelection(up: false)
                        return .handled
                    }
                    .onKeyPress(.return) {
                        if !viewModel.searchResults.isEmpty {
                            viewModel.searchResults[selectedIndex].action()
                        }
                        return .handled
                    }
            }
            .padding(.top, 16)
            .padding(.horizontal, 16)
            
            // Action Buttons
            HStack(spacing: 4) {
                ActionButton(
                    icon: .upload,
                    helpText: "Upload File"
                ) {
                    Task {
                        if let panel = floatingPanel {
                            try? await viewModel.uploadFile(from: panel)
                        }
                    }
                }
                
                ActionButton(
                    icon: .browse,
                    helpText: "Browse Folders"
                ) {
                    viewModel.browse()
                }
                
                ActionButton(
                    icon: .camera,
                    helpText: "Capture Window"
                ) {
                    Task {
                        if await WindowScreenshotPicker.checkScreenRecordingPermission() {
                            WindowScreenshotPicker.captureWindow { screenshot, windowInfo in
                                if let screenshot = screenshot {
                                    viewModel.setCapturedScreenshot(screenshot, windowInfo: windowInfo)
                                    viewModel.searchText = "I have a question about this screenshot: "
                                    isFocused = true
                                }
                            }
                        } else {
                            WindowScreenshotPicker.requestScreenRecordingPermission()
                        }
                    }
                }
                
                Spacer()
                
                if let error = viewModel.error {
                    Text(error.localizedDescription)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                ActionButton(
                    icon: .send,
                    helpText: "Ask",
                    iconColor: .black
                ) {
                    // Send query action is handled by return key
                }
                .background(Color.white)
                .cornerRadius(.infinity)
                .opacity(isFocused && !viewModel.searchText.isEmpty ? 1 : 0.4)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
        }
        .onAppear {
            isFocused = true
        }
        .onChange(of: viewModel.shouldFocusInput) { oldValue, newValue in
            if newValue {
                isFocused = true
                viewModel.shouldFocusInput = false
            }
        }
        .onChange(of: viewModel.searchText) { oldValue, newValue in
            if let panel = floatingPanel as? SearchPanelProtocol {
                panel.updateSearchState(hasText: !newValue.isEmpty)
            }
        }
        .onChange(of: viewModel.capturedScreenshot != nil) { oldValue, newValue in
            updatePanelCloseBehavior()
        }
        .onChange(of: viewModel.uploadedFile != nil) { oldValue, newValue in
            updatePanelCloseBehavior()
        }
        .frame(width: 360)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .background {
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay {
                    Rectangle()
                        .fill(.black)
                        .opacity(0.2)
                }
                .cornerRadius(10)
        }
    }
    
    private func moveSelection(up: Bool) {
        if viewModel.searchResults.isEmpty { return }
        
        if up {
            selectedIndex = selectedIndex >= viewModel.searchResults.count - 1 ? 0 : selectedIndex + 1
        } else {
            selectedIndex = selectedIndex <= 0 ? viewModel.searchResults.count - 1 : selectedIndex - 1
        }
    }
    
    private func updatePanelCloseBehavior() {
        if let panel = floatingPanel as? SearchPanelProtocol {
            // Prevent panel from closing if there's a screenshot or uploaded file
            panel.setPanelCloseBehavior(preventClose: viewModel.capturedScreenshot != nil || viewModel.uploadedFile != nil)
        }
    }
}

// MARK: - Preview
#if DEBUG
struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
#endif
