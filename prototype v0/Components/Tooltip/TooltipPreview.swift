import SwiftUI

struct TooltipPreview: PreviewProvider {
    static var previews: some View {
        TooltipExamples()
    }
}

private struct TooltipExamples: View {
    @State private var showTooltip = true
    
    var body: some View {
        VStack(spacing: 60) {
            // Multiple tooltips in a row
            Group {
                Text("Multiple Tooltips")
                    .font(.headline)
                
                HStack(spacing: 40) {
                    // Each button has a unique ID
                    Button("First") {}
                        .tooltip(
                            id: "first",
                            isPresented: $showTooltip,
                            config: TooltipConfig(
                                appearance: .init(backgroundColor: .blue)
                            )
                        ) {
                            Text("First tooltip")
                        }
                    
                    Button("Second") {}
                        .tooltip(
                            id: "second",
                            config: TooltipConfig(
                                appearance: .init(backgroundColor: .green)
                            )
                        ) {
                            Text("Second tooltip")
                        }
                    
                    Button("Third") {}
                        .tooltip(
                            id: "third",
                            config: TooltipConfig(
                                appearance: .init(backgroundColor: .purple)
                            )
                        ) {
                            Text("Third tooltip")
                        }
                }
            }
            
            // Side examples
            Group {
                Text("Side Examples")
                    .font(.headline)
                
                HStack(spacing: 40) {
                    // Top
                    Button("Top") {}
                        .tooltip(
                            id: "top",
                            config: TooltipConfig(
                                appearance: .init(backgroundColor: .blue),
                                layout: .init(side: .top)
                            )
                        ) {
                            Text("Top tooltip")
                        }
                    
                    // Right
                    Button("Right") {}
                        .tooltip(
                            id: "right",
                            config: TooltipConfig(
                                appearance: .init(backgroundColor: .green),
                                layout: .init(side: .right)
                            )
                        ) {
                            Text("Right tooltip")
                        }
                    
                    // Bottom
                    Button("Bottom") {}
                        .tooltip(
                            id: "bottom",
                            config: TooltipConfig(
                                appearance: .init(backgroundColor: .purple),
                                layout: .init(side: .bottom)
                            )
                        ) {
                            Text("Bottom tooltip")
                        }
                    
                    // Left
                    Button("Left") {}
                        .tooltip(
                            id: "left",
                            config: TooltipConfig(
                                appearance: .init(backgroundColor: .orange),
                                layout: .init(side: .left)
                            )
                        ) {
                            Text("Left tooltip")
                        }
                }
            }
            
            // Delay examples
            Group {
                Text("Delay Examples")
                    .font(.headline)
                
                HStack(spacing: 40) {
                    // Instant tooltip
                    Button("Instant") {}
                        .tooltip(
                            id: "instant",
                            config: TooltipConfig(
                                appearance: .init(backgroundColor: .blue),
                                behavior: .init(delayDuration: 0)
                            )
                        ) {
                            Text("Shows instantly")
                        }
                    
                    // Default delay
                    Button("Default") {}
                        .tooltip(
                            id: "default",
                            config: TooltipConfig(
                                appearance: .init(backgroundColor: .purple)
                            )
                        ) {
                            Text("Shows after default delay")
                        }
                    
                    // Long delay
                    Button("Long") {}
                        .tooltip(
                            id: "long",
                            config: TooltipConfig(
                                appearance: .init(backgroundColor: .green),
                                behavior: .init(delayDuration: 1.5)
                            )
                        ) {
                            Text("Shows after long delay")
                        }
                }
            }
            
            // Manual control example
            Group {
                Text("Manual Control")
                    .font(.headline)
                
                HStack(spacing: 40) {
                    Button("Toggle tooltip") {
                        showTooltip.toggle()
                    }
                    .tooltip(
                        id: "manual",
                        isPresented: $showTooltip,
                        config: TooltipConfig(
                            appearance: .init(backgroundColor: .red),
                            layout: .init(keyboardShortcut: "⌘M")
                        )
                    ) {
                        Text("Manually controlled tooltip")
                    }
                }
            }
        }
        .padding(50)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.windowBackgroundColor))
    }
} 
