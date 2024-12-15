import SwiftUI

struct PageIndicator: View {
    let numberOfPages: Int
    @Binding var currentPage: Int
    let icons: [String]
    
    @State private var isShowingIcons: Bool = false
    @State private var hoveredIcon: Int? = nil
    
    private let dotSize: CGFloat = 6
    private let iconSize: CGFloat = 14
    private let spacing: CGFloat = 8
    private let containerHeight: CGFloat = 32
    
    var body: some View {
        ZStack(alignment: .top) {
            // Dots State
            HStack(spacing: spacing) {
                ForEach(0..<numberOfPages, id: \.self) { index in
                    Circle()
                        .fill(currentPage == index ? Color.primary : Color.secondary)
                        .frame(width: dotSize, height: dotSize)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isShowingIcons = true
                            }
                        }
                }
            }
            .frame(height: containerHeight) // Ensure dots are vertically centered
            .opacity(isShowingIcons ? 0 : 1)
            
            // Icons State
            HStack(spacing: spacing - 4) {
                ForEach(0..<numberOfPages, id: \.self) { index in
                    Image(systemName: icons[index])
                        .font(.system(size: iconSize))
                        .foregroundColor(currentPage == index ? .primary : .secondary)
                        .frame(width: containerHeight, height: containerHeight)
                        .background(
                            RoundedRectangle(cornerRadius: containerHeight/2)
                                .fill(hoveredIcon == index ? Color.gray.opacity(0.1) : Color.clear)
                        )
                        .onHover { isHovered in
                            hoveredIcon = isHovered ? index : nil
                        }
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                currentPage = index
                            }
                        }
                }
            }
            .padding(2)
            .background(
                RoundedRectangle(cornerRadius: .infinity)
                    .fill(Color.gray.opacity(0.05))
            )
            .opacity(isShowingIcons ? 1 : 0)
            .scaleEffect(isShowingIcons ? 1 : 0.5)
        }
        .frame(height: containerHeight)
        .onHover { isHovered in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isShowingIcons = isHovered
            }
        }
    }
}

// Preview implementation for macOS
struct PageIndicator_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
}

private struct PreviewWrapper: View {
    @State private var currentPage = 0
    
    var body: some View {
        VStack(spacing: 40) {
            // Example with horizontal ScrollView
            VStack {
                Text("With ScrollView")
                    .font(.headline)
                
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            ForEach(0..<3) { index in
                                Rectangle()
                                    .fill(index == 0 ? Color.red :
                                         index == 1 ? Color.blue : Color.green)
                                    .frame(width: 300, height: 200)
                                    .overlay(Text("Page \(index + 1)")
                                        .foregroundColor(.white))
                                    .id(index)
                            }
                        }
                    }
                    .onChange(of: currentPage) { newValue in
                        withAnimation {
                            proxy.scrollTo(newValue, anchor: .center)
                        }
                    }
                }
                .frame(width: 300)
                
                PageIndicator(
                    numberOfPages: 3,
                    currentPage: $currentPage,
                    icons: ["house.fill", "person.fill", "gear"]
                )
            }
            
            Divider()
            
            // Standalone examples
            VStack(spacing: 20) {
                Text("Standalone Examples")
                    .font(.headline)
                
                PageIndicator(
                    numberOfPages: 3,
                    currentPage: $currentPage,
                    icons: ["star.fill", "heart.fill", "bell.fill"]
                )
                
                PageIndicator(
                    numberOfPages: 4,
                    currentPage: $currentPage,
                    icons: ["1.circle.fill", "2.circle.fill", "3.circle.fill", "4.circle.fill"]
                )
                .tint(.blue)
                
                Text("Current Page: \(currentPage)")
                    .font(.caption)
            }
        }
        .padding()
        .frame(width: 400)
        .previewLayout(.sizeThatFits)
    }
}
