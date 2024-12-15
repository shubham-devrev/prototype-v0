import SwiftUI
import AppKit

protocol TwoFingerScrollDelegateProtocol {
    func scrollWheel(with event: NSEvent)
}

class TwoFingerScrollView: NSView {
    var delegate: TwoFingerScrollDelegateProtocol!
    
    override var acceptsFirstResponder: Bool { true }
    
    override func scrollWheel(with event: NSEvent) {
        delegate.scrollWheel(with: event)
    }
}

struct RepresentableTwoFingerScrollView: NSViewRepresentable, TwoFingerScrollDelegateProtocol {
    private var scrollAction: ((NSEvent) -> Void)?
    
    func makeNSView(context: Context) -> TwoFingerScrollView {
        let view = TwoFingerScrollView()
        view.delegate = self
        return view
    }
    
    func updateNSView(_ nsView: TwoFingerScrollView, context: Context) {}
    
    func scrollWheel(with event: NSEvent) {
        if let scrollAction = scrollAction {
            scrollAction(event)
        }
    }
    
    func onScroll(_ action: @escaping (NSEvent) -> Void) -> Self {
        var newSelf = self
        newSelf.scrollAction = action
        return newSelf
    }
}

struct SwipeableNavigationView: View {
    @State private var currentPage: Int = 0
    @State private var scrollOffset: CGFloat = 0
    
    private let pages: [Page]
    private let dragThreshold: CGFloat = 20
    
    struct Page {
        let view: AnyView
        let icon: String
        
        init<V: View>(view: V, icon: String) {
            self.view = AnyView(view)
            self.icon = icon
        }
    }
    
    init(_ pages: [Page]) {
        self.pages = pages
    }
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        pages[index].view
                            .frame(width: geometry.size.width)
                    }
                }
                .offset(x: -CGFloat(currentPage) * geometry.size.width + scrollOffset)
                .overlay(
                    RepresentableTwoFingerScrollView()
                        .onScroll { event in
                            handleScrollWheel(event)
                        }
                )
                .animation(
                    .interpolatingSpring(
                        mass: 1.2,
                        stiffness: 120,
                        damping: 22,
                        initialVelocity: 0
                    ),
                    value: scrollOffset
                )
            }
            
            PageIndicator(
                numberOfPages: pages.count,
                currentPage: $currentPage,
                icons: pages.map { $0.icon }
            )
            .padding(.vertical, 20)
        }
    }
    
    private func handleScrollWheel(_ event: NSEvent) {
        switch event.phase {
        case .began:
            scrollOffset = 0
            
        case .changed:
            if event.hasPreciseScrollingDeltas {
                let proposedOffset = scrollOffset + event.scrollingDeltaX
                if (currentPage == 0 && proposedOffset > 0) ||
                   (currentPage == pages.count - 1 && proposedOffset < 0) {
                    scrollOffset += event.scrollingDeltaX * 0.3
                } else {
                    scrollOffset = proposedOffset
                }
            }
            
        case .ended:
            let finalOffset = scrollOffset
            withAnimation(
                .interpolatingSpring(
                    mass: 1.2,
                    stiffness: 120,
                    damping: 22,
                    initialVelocity: 0
                )
            ) {
                if abs(finalOffset) > dragThreshold {
                    if finalOffset > 0 && currentPage > 0 {
                        currentPage -= 1
                    } else if finalOffset < 0 && currentPage < pages.count - 1 {
                        currentPage += 1
                    }
                }
                scrollOffset = 0
            }
            
        default:
            withAnimation(
                .interpolatingSpring(
                    mass: 1.2,
                    stiffness: 120,
                    damping: 22,
                    initialVelocity: 0
                )
            ) {
                scrollOffset = 0
            }
        }
    }
}
// Preview
#Preview("Swipeable Navigation") {
    SwipeableNavigationView([
        .init(view: FirstView(), icon: "house.fill"),
        .init(view: SecondView(), icon: "person.fill"),
        .init(view: ThirdView(), icon: "gear")
    ])
    .frame(width: 800, height: 600)
}

// Example views remain the same
struct FirstView: View {
    var body: some View {
        ZStack {
            Color.blue.opacity(0.3)
            Text("First View")
                .font(.largeTitle)
        }
    }
}

struct SecondView: View {
    var body: some View {
        ZStack {
            Color.green.opacity(0.3)
            Text("Second View")
                .font(.largeTitle)
        }
    }
}

struct ThirdView: View {
    var body: some View {
        ZStack {
            Color.red.opacity(0.3)
            Text("Third View")
                .font(.largeTitle)
        }
    }
}
