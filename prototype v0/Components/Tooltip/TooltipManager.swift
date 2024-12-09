import SwiftUI
import Combine

public class TooltipManager: ObservableObject {
    public static let shared = TooltipManager()
    
    @Published public private(set) var activeTooltipId: String?
    @Published private(set) var previousTooltipId: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let queue = DispatchQueue(label: "com.tooltip.manager", qos: .userInteractive)
    
    private init() {
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        $activeTooltipId
            .dropFirst()
            .sink { [weak self] newId in
                self?.handleTooltipChange(newId: newId)
            }
            .store(in: &cancellables)
    }
    
    private func handleTooltipChange(newId: String?) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            if let currentId = self.previousTooltipId {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if self.previousTooltipId == currentId {
                        self.previousTooltipId = nil
                    }
                }
            }
        }
    }
    
    public func showTooltip(id: String) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            if let currentId = self.activeTooltipId, currentId != id {
                DispatchQueue.main.async {
                    self.previousTooltipId = currentId
                }
            }
            
            DispatchQueue.main.async {
                self.activeTooltipId = id
            }
        }
    }
    
    public func hideTooltip(id: String) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if self.activeTooltipId == id {
                    self.activeTooltipId = nil
                }
                if self.previousTooltipId == id {
                    self.previousTooltipId = nil
                }
            }
        }
    }
    
    public func clearTooltip() {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.activeTooltipId = nil
                self.previousTooltipId = nil
            }
        }
    }
    
    public func isTooltipVisible(id: String) -> Bool {
        queue.sync {
            id == activeTooltipId || id == previousTooltipId
        }
    }
} 